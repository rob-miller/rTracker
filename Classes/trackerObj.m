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

@synthesize tid;
@synthesize trackerName;
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
	
	outStr = [[ NSString alloc] initWithUTF8String :outp];
	
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
	sql = @"create table if not exists trkrInfo (field text unique, val text);";
	[self toExecSql];
	sql = @"create table if not exists voConfig (id int unique, rank int, type int, name text);";
	[self toExecSql];
	sql = @"create table if not exists voData (id int, date int, val text);";
	[self toExecSql];
	sql = nil;
}

- (void) loadConfig {
	NSLog(@"tObj loadConfig: %d",tid);
	NSAssert(tid,@"tObj load tid=0");
	[trackerName release];
	sql = @"select val from trkrInfo where field='name';";
	trackerName = [self toQry2Str];
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *i2 = [[NSMutableArray alloc] init];
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	sql = @"select id, type, name from voConfig order by rank;";
	[self toQry2AryIIS :i1 i2:i2 s1:s1];
	
	NSEnumerator *e1 = [i1 objectEnumerator];
	NSEnumerator *e2 = [i2 objectEnumerator];
	NSEnumerator *e3 = [s1 objectEnumerator];
	int vid;
	while ( vid = (int) [e1 nextObject]) {
		[valObjTable addObject:(id) [[valueObj alloc] init :vid in_vtype:(int)[e2 nextObject] in_vname: (NSString *) [e3 nextObject]]];
	}
	[e1 release];
	[e2 release];
	[e3 release];
	[i1 release];
	[i2 release];
	[s1 release];
}

- (void) saveConfig {
	NSLog(@"tObj saveConfig: trackerName= %@",trackerName) ;
											   
	NSAssert(tid,@"tObj saveConfig tid=0");
	if (! dbName) {
		dbName = [[NSString alloc] initWithFormat:@"trkr%d.sqlite3",tid];
		[self getTDb];
		[self initTDb];
	}
	sql = [[NSString alloc] initWithFormat:@"insert or replace into trkrInfo (field, val) values ('name','%@');", trackerName];
	[self toExecSql];
	[sql release];
	
	int i=0;
	for (valueObj *vo in valObjTable) {
		NSLog(@"  vo %@", vo.valueName);
		sql = [[NSString alloc] initWithFormat:@"insert or replace into voConfig (id, rank, type, name) values (%d, %d, %d, '%@');",
			   vo.vid, i++, vo.valueType, vo.valueName];
		[self toExecSql];
		[sql release];
	}
	
	sql = nil;
}


- (id)init {

	if (self = [super init]) {
		valObjTable = [[NSMutableArray alloc] init];

		if (tid) {
			NSLog(@"init trackerObj id: %d",tid);
			[self loadConfig];
		} else {
			NSLog(@"init trackerObj New");
		}
	}
	
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObj: %@",trackerName);

	[trackerName release];
	[super dealloc];
}

- (void) addValObj:(valueObj *) valObj {
	NSLog(@"addValObj to %@: adding _%@_, total items now %d",trackerName, valObj.valueName,[self.valObjTable count]);
	[self.valObjTable addObject:valObj];
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
