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


@synthesize trackerName, trackerDate, valObjTable;
@synthesize colorSet, votArray;
@synthesize maxLabel;

- (void) initTDb {
	int c;
	sql = @"create table if not exists trkrInfo (field text unique, val text);";
	[self toExecSql];
	sql = @"select count(*) from trkrInfo;";
	c = [self toQry2Int];
	if (c == 0) {
		// init clean db
		sql = @"create table if not exists voConfig (id int unique, rank int, type int, name text, color int, graphtype int);";
		[self toExecSql];
		sql = @"create table if not exists voData (id int, date int, val text);";
		[self toExecSql];
		sql = @"create table if not exists trkrData (date int unique);";
		[self toExecSql];
		sql = nil;
	}
}

- (void) confirmDb {
	NSAssert(toid,@"tObj confirmDb toid=0");
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
	sql = @"select val from trkrInfo where field='width';";
	maxLabel.width = [self toQry2Float];
	sql = @"select val from trkrInfo where field='height';";
	maxLabel.height = [self toQry2Float];
	
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *i2 = [[NSMutableArray alloc] init];
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	NSMutableArray *i3 = [[NSMutableArray alloc] init];
	NSMutableArray *i4 = [[NSMutableArray alloc] init];
	sql = @"select id, type, name, color, graphtype from voConfig order by rank;";
	[self toQry2AryIISII :i1 i2:i2 s1:s1 i3:i3 i4:i4];
	
	NSEnumerator *e1 = [i1 objectEnumerator];
	NSEnumerator *e2 = [i2 objectEnumerator];
	NSEnumerator *e3 = [s1 objectEnumerator];
	NSEnumerator *e4 = [i3 objectEnumerator];
	NSEnumerator *e5 = [i4 objectEnumerator];
	int vid;
	while ( vid = (int) [[e1 nextObject] intValue]) {
		valueObj *vo = [[valueObj alloc] init :vid 
									  in_vtype:(int)[[e2 nextObject] intValue] 
									  in_vname: (NSString *) [e3 nextObject] 
									 in_vcolor:(int)[[e4 nextObject] intValue] 
								 in_vgraphtype:(int)[[e5 nextObject] intValue] 
						];
		[valObjTable addObject:(id) vo];
		[vo release];
	}

	[i1 release];
	[i2 release];
	[s1 release];
	
	[trackerDate release];
	trackerDate = [[NSDate alloc] init];
}

- (void) saveConfig {
	NSLog(@"tObj saveConfig: trackerName= %@",trackerName) ;
	
	[self confirmDb];
	
	sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('name','%@');", trackerName];
	[self toExecSql];
	//[sql release];
	
	sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('width',%f);",
		self.maxLabel.width];
	[self toExecSql];
	sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('height',%f);",
		self.maxLabel.height];
	[self toExecSql];
	
	int i=0;
	for (valueObj *vo in valObjTable) {

		if (vo.vid <= 0) {
			vo.vid = [self getUnique];
		}
		
		NSLog(@"  vo %@  id %d", vo.valueName, vo.vid);
		sql = [NSString stringWithFormat:@"insert or replace into voConfig (id, rank, type, name, color, graphtype) values (%d, %d, %d, '%@', %d, %d);",
			   vo.vid, i++, vo.vtype, vo.valueName, vo.vcolor, vo.vGraphType];
		[self toExecSql];
		//[sql release];
	}
	
	sql = nil;
}

- (valueObj *) getValObj:(NSInteger) qVid {
	valueObj *rvo=nil;
	
	NSEnumerator *e = [self.valObjTable objectEnumerator];
	valueObj *vo;
	while (vo = (valueObj *) [e nextObject]) {
		if (vo.vid == qVid) {
			rvo = vo;
			break;
		}
	}

	if (vo == nil) {
		NSLog(@"tObj getValObj failed to find vid %d",qVid);
	}
	return rvo;
}

- (BOOL) loadData: (int) iDate {
	
	NSDate *qDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) iDate];
	[self resetData];
	sql = [NSString stringWithFormat:@"select count(*) from trkrData where date = %d;",iDate];
	int c = [self toQry2Int];
	if (c) {
		//[self.trackerDate release];
		//self.trackerDate = nil;
		self.trackerDate = qDate;
		NSMutableArray *i1 = [[NSMutableArray alloc] init];
		NSMutableArray *s1 = [[NSMutableArray alloc] init];
		sql = [NSString stringWithFormat:@"select id, val from voData where date = %d;", iDate];
		[self toQry2AryIS :i1 s1:s1];
		
		NSEnumerator *e1 = [i1 objectEnumerator];
		NSEnumerator *e3 = [s1 objectEnumerator];
		NSInteger vid;
		while ( vid = (NSInteger) [[e1 nextObject] intValue]) {			
			valueObj *vo = [self getValObj:vid];
			NSAssert1(vo,@"tObj loadData no valObj with vid %d",vid);
			[vo.value setString:(NSString *) [e3 nextObject]];
		}
		
		[i1 release];
		[s1 release];
		
		return YES;
		
	} else {
		NSLog(@"tObj loadData: nothing for date %d %@", iDate, qDate);
		return NO;
	}
}

- (void) saveData {

	if (self.trackerDate == nil) {
		self.trackerDate = [[NSDate alloc] init];
	}
	
	sql = [NSString stringWithFormat:@"insert or replace into trkrData (date) values (%d);", 
		   (int) [self.trackerDate timeIntervalSince1970] ];
	[self toExecSql];

	NSLog(@" tObj saveData %@ date %@",self.trackerName, self.trackerDate);
	
	for (valueObj *vo in valObjTable) {
		
		NSAssert((vo.vid >= 0),@"tObj saveData vo.vid <= 0");
		
		NSLog(@"  vo %@  id %d val %@", vo.valueName, vo.vid, vo.value);
		sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d, %d,'%@');",
			   vo.vid, (int) [self.trackerDate timeIntervalSince1970], vo.value];
		[self toExecSql];
	}
	
	sql = nil;
	
}

- (void) resetData {

	//[self.trackerDate release];
	self.trackerDate = [[NSDate alloc] init];

	NSEnumerator *e = [self.valObjTable objectEnumerator];
	valueObj *vo;
	while (vo = (valueObj *) [e nextObject]) {
		[vo.value setString:@""];  // TODO: default values go here
	}

}

- (void) deleteAllData {
	[self deleteTDb];
}

- (void) deleteCurrEntry {
	sql = [NSString stringWithFormat:@"delete from trkrData where date = %d;",(int) [trackerDate timeIntervalSince1970]];
	[self toExecSql];
	sql = [NSString stringWithFormat:@"delete from voData where date = %d;",(int) [trackerDate timeIntervalSince1970]];
	[self toExecSql];
	sql = nil;
}

- (int) prevDate {
	sql = [NSString stringWithFormat:@"select date from trkrData where date < %d order by date desc limit 1;", 
		   (int) [trackerDate timeIntervalSince1970] ];
	int rslt= [self toQry2Int];
	sql = nil;
	return rslt;
}

- (int) postDate {
	sql = [NSString stringWithFormat:@"select date from trkrData where date > %d order by date asc limit 1;", 
		   (int) [trackerDate timeIntervalSince1970] ];
	int rslt= (NSInteger) [self toQry2Int];
	sql = nil;
	return rslt;
}

- (id)init {

	if (self = [super init]) {
		trackerDate = nil;
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
	[trackerDate release];
	[valObjTable release];
	
	[colorSet release];
	[votArray release];
	
	[super dealloc];
}

- (bool) updateValObj:(valueObj *) valObj {

	NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	valueObj *vo;
	while ( vo = (valueObj *) [enumer nextObject]) {
		if (vo.vid == valObj.vid) {
			//*vo = *valObj; // indirection cannot be to an interface in non-fragile ABI
			vo.vtype = valObj.vtype;
			[vo.valueName release];
			vo.valueName = valObj.valueName;
			[vo.value setString:valObj.value];
			[vo.display release];
			vo.display = valObj.display;
			return YES;
		}
	}
	return NO;
}

- (void) setMaxLabel 
{

	CGSize lsize = { 0.0f, 0.0f };
	
	NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	valueObj *vo;
	while ( vo = (valueObj *) [enumer nextObject]) {
		CGSize tsize = [vo.valueName sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
		if (tsize.width > lsize.width) {
			lsize = tsize;
		}
	}
	
	NSLog(@"maxLabel set: width %f  height %f",lsize.width, lsize.height);
	self.maxLabel = lsize;
}


- (void) addValObj:(valueObj *) valObj {
	NSLog(@"addValObj to %@ id= %d : adding _%@_ id= %d, total items now %d",trackerName,toid, valObj.valueName, valObj.vid, [self.valObjTable count]);

	// check if toid already exists, then update
	if (! [self updateValObj: valObj]) {
		[self.valObjTable addObject:valObj];
	}
	
	[self setMaxLabel];
}

- (valueObj *) voConfigCopy: (valueObj *) srcVO {
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

- (NSArray *) colorSet {
	if (colorSet == nil) {
		colorSet = [[NSArray alloc] initWithObjects:
					[UIColor redColor], [UIColor greenColor], [UIColor blueColor],
					[UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor],
					[UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], 
					[UIColor whiteColor], [UIColor lightGrayColor], [UIColor darkGrayColor], nil];
		
	}
	return colorSet;
}

- (NSArray *) votArray {
	if (votArray == nil) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath= [bundle pathForResource:@"rt-types" ofType:@"plist"];
		votArray = [[NSArray alloc] initWithContentsOfFile:plistPath]; 

	}
	
	return votArray;
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
