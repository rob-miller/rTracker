//
//  trackerObj.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <string.h>
//#import <stdlib.h>

#import "trackerObj.h"
#import "valueObj.h"


@implementation trackerObj


//@synthesize tid;
@synthesize trackerName;
//@synthesize trackerDate;
@synthesize valObjTable;

/*
+ (NSString *) makeSafeStr : (NSString *) inStr {
	NSString *outStr;
	
	//NSLog(@"enter makeSafeStr: %@",inStr);
	
	char *newp = strdup([inStr UTF8String]);
	char *outp = newp;
	
	while (*newp) {
		if ((*newp >= 'a' && *newp <= 'z') ||
			(*newp >= 'A' && *newp <= 'Z') ||
			(*newp >= '0' && *newp <= '1')) {
		} else {
			*newp = '_';
		}
		newp++;
	}
	
	//NSLog(@" processed: %s",outp);
	
	outStr = [ NSString stringWithUTF8String :outp];
	
	NSLog(@"makeSafeStr finished: .%@. -> .%@.",inStr,outStr);
	free( outp );
	
	return outStr;
}


- (void) setTrackerName:(NSString *) newValue {
	if (newValue != trackerName) {
		[trackerName release];
		trackerName = [trackerObj makeSafeStr :newValue];
	}
}
*/

- (void) initTDb {
	int c;
	sql = @"create table if not exists trkrInfo (field text unique, val text);";
	[self toExecSql];
	sql = @"select count(*) from trkrInfo;";
	c = [self toQry2Int];
	if (c == 0) {
		// init clean db
		sql = @"create table if not exists voConfig (id int unique, rank int, type int, name text);";
		[self toExecSql];
		sql = @"create table if not exists voData (id int, date int, val text);";
		[self toExecSql];
		sql = nil;
	}
}

- (void) confirmDb {
	NSAssert(toid,@"tObj saveConfig toid=0");
	if (! dbName) {
		dbName = [[NSString alloc] initWithFormat:@"trkr%d.sqlite3",toid];
		[self getTDb];
		[self initTDb];
	}
}

- (void) loadConfig {
	NSLog(@"tObj loadConfig: %d",toid);
	NSAssert(toid,@"tObj load toid=0");
	[trackerName release];
	sql = @"select val from trkrInfo where field='name';";
	trackerName = [self toQry2StrCopy];
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *i2 = [[NSMutableArray alloc] init];
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	sql = @"select id, type, name from voConfig order by rank;";
	[self toQry2AryIIS :i1 i2:i2 s1:s1];
	
	NSEnumerator *e1 = [i1 objectEnumerator];
	NSEnumerator *e2 = [i2 objectEnumerator];
	NSEnumerator *e3 = [s1 objectEnumerator];
	int vid;
	while ( vid = (int) [[e1 nextObject] intValue]) {
		valueObj *vo = [[valueObj alloc] init :vid 
									  in_vtype:(int)[[e2 nextObject] intValue] 
									  in_vname: (NSString *) [e3 nextObject] ];
		[valObjTable addObject:(id) vo];
		[vo release];
	}
	//[e1 release];
	//[e2 release];
	//[e3 release];
	[i1 release];
	[i2 release];
	[s1 release];
}

- (void) saveConfig {
	NSLog(@"tObj saveConfig: trackerName= %@",trackerName) ;
	
	[self confirmDb];
	
	sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('name','%@');", trackerName];
	[self toExecSql];
	//[sql release];
	
	int i=0;
	for (valueObj *vo in valObjTable) {

		if (vo.vid <= 0) {
			vo.vid = [self getUnique];
		}
		
		NSLog(@"  vo %@  id %d", vo.valueName, vo.vid);
		sql = [NSString stringWithFormat:@"insert or replace into voConfig (id, rank, type, name) values (%d, %d, %d, '%@');",
			   vo.vid, i++, vo.vtype, vo.valueName];
		[self toExecSql];
		//[sql release];
	}
	
	sql = nil;
}


- (id)init {

	if (self = [super init]) {
		valObjTable = [[NSMutableArray alloc] init];
		NSLog(@"init trackerObj New");
	}
	
	return self;
}

- (id)init:(int) tid {
	if (self = [self init]) {
		NSLog(@"configure trackerObj id: %d",tid);
		self.toid = tid;
		[self confirmDb];
		[self loadConfig];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObj: %@",trackerName);

	[trackerName release];
	[valObjTable release];
	[super dealloc];
}

- (bool) updateValObj:(valueObj *) valObj {

	NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	valueObj *vo;
	while ( vo = (valueObj *) [enumer nextObject]) {
		if (vo.vid == valObj.vid) {
			*vo = *valObj;
			return YES;
		}
	}
	return NO;
}

- (void) addValObj:(valueObj *) valObj {
	NSLog(@"addValObj to %@ id= %d : adding _%@_ id= %d, total items now %d",trackerName,toid, valObj.valueName, valObj.vid, [self.valObjTable count]);

	// check if toid already exists, then update
	if (! [self updateValObj: valObj]) {
		[self.valObjTable addObject:valObj];
	}
}

- (valueObj *) voDeepCopy: (valueObj *) srcVO {
	NSLog(@"voDeepCopy: to= id %d %@ input vid=%d %@", toid, trackerName, srcVO.vid,srcVO.valueName);
	
	valueObj *newVO = [[valueObj alloc] init];
	newVO.vid = [self getUnique];
	newVO.vtype = srcVO.vtype;
	newVO.valueName = [[NSString alloc] initWithString:srcVO.valueName];  
	
	return newVO;
}

- (void) describe {
	NSLog(@"tracker id %d name %@ dbName %@", toid, trackerName, dbName);

	NSEnumerator *enumer = [valObjTable objectEnumerator];
	valueObj *vo;
	while ( vo = (valueObj *) [enumer nextObject]) {
		[vo describe];
	}
}

/*
- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"trackerObj: notified app will terminate");
	if (dbValues != nil) {
		sqlite3_close(dbValues);
		dbValues = nil;
		NSLog(@"closed dbValues");
	}
}
*/

@end
