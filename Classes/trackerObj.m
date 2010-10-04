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


/******************************
 *
 * trackerObj db tables
 *
 *  trkrInfo: field(text,unique) ; val(text)
 *     field='name' : tracker name
 *	   field='height','width' : max size over all valobj display widgets (num, text, slider, etc)
 *
 *  voConfig: id(int,unique) ; rank(int) ; type(int) ; name(text) ; color(int) ; graphtype(int)
 *         type: rt-types.plist and defs in valueObj.h
 *        color: defs in valueObj.h ; colorSet in trackerObj.m
 *    graphtype: defs in valueObj.h ; graphsForVOTCopy and mapGraphType in valueObj.m
 *
 *  trkrData: date(int,unique)
 *		entry indicates there will be corresponding voData items
 *
 *  voData: id(int) ; date(int) ; val(text)
 *      valObj.vid value stored at specified timestamp
 *  
 *
 ******************************/
#pragma mark -
#pragma mark core object methods and support

- (void) initTDb {
	int c;
	self.sql = @"create table if not exists trkrInfo (field text unique, val text);";
	[self toExecSql];
	self.sql = @"select count(*) from trkrInfo;";
	c = [self toQry2Int];
	if (c == 0) {
		// init clean db
		self.sql = @"create table if not exists voConfig (id int unique, rank int, type int, name text, color int, graphtype int);";
		[self toExecSql];
		self.sql = @"create table if not exists voData (id int, date int, val text);";
		[self toExecSql];
		self.sql = @"create table if not exists trkrData (date int unique);";
		[self toExecSql];
	}
	self.sql = nil;
}

- (void) confirmDb {
	NSAssert(self.toid,@"tObj confirmDb toid=0");
	if (! self.dbName) {
		dbName = [[NSString alloc] initWithFormat:@"trkr%d.sqlite3",toid];
		//self.dbName = [[NSString alloc] initWithFormat:@"trkr%d.sqlite3",toid];
		[self getTDb];
		[self initTDb];
	}
}


- (id)init {
	
	if (self = [super init]) {
		self.trackerDate = nil;
		//self.valObjTable = [[NSMutableArray alloc] init];
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
	
	self.trackerName = nil;
	[trackerName release];
	self.trackerDate = nil;
	[trackerDate release];
	self.valObjTable = nil;
	[valObjTable release];
	
	self.colorSet = nil;
	[colorSet release];
	self.votArray = nil;
	[votArray release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark load/save db<->object 

- (void) loadConfig {
	NSLog(@"tObj loadConfig: %d",self.toid);
	NSAssert(self.toid,@"tObj load toid=0");
	self.sql = @"select val from trkrInfo where field='name';";
	self.trackerName = nil;
	trackerName = [self toQry2StrCopy];
	self.sql = @"select val from trkrInfo where field='width';";
	maxLabel.width = [self toQry2Float];  // why not self?
	self.sql = @"select val from trkrInfo where field='height';";
	maxLabel.height = [self toQry2Float]; // why not self?
	
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *i2 = [[NSMutableArray alloc] init];
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	NSMutableArray *i3 = [[NSMutableArray alloc] init];
	NSMutableArray *i4 = [[NSMutableArray alloc] init];
	self.sql = @"select id, type, name, color, graphtype from voConfig order by rank;";
	[self toQry2AryIISII :i1 i2:i2 s1:s1 i3:i3 i4:i4];
	
	self.sql=nil;
	
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
		[self.valObjTable addObject:(id) vo];
		[vo release];
	}
	
	[i1 release];
	[i2 release];
	[s1 release];
	[i3 release];
	[i4 release];
	
	//[trackerDate release];
	self.trackerDate = nil;
	trackerDate = [[NSDate alloc] init];
	//self.trackerDate = [[NSDate alloc] init];
	//[trackerDate release];
	
}

- (void) saveConfig {
	NSLog(@"tObj saveConfig: trackerName= %@",trackerName) ;
	
	[self confirmDb];
	
	self.sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('name','%@');", self.trackerName];
	[self toExecSql];
	
	self.sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('width',%f);",
				self.maxLabel.width];
	[self toExecSql];
	self.sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('height',%f);",
				self.maxLabel.height];
	[self toExecSql];
	
	int i=0;
	for (valueObj *vo in self.valObjTable) {
		
		if (vo.vid <= 0) {
			vo.vid = [self getUnique];
		}
		
		NSLog(@"  vo %@  id %d", vo.valueName, vo.vid);
		self.sql = [NSString stringWithFormat:@"insert or replace into voConfig (id, rank, type, name, color, graphtype) values (%d, %d, %d, '%@', %d, %d);",
					vo.vid, i++, vo.vtype, vo.valueName, vo.vcolor, vo.vGraphType];
		[self toExecSql];
	}
	
	self.sql = nil;
}


- (valueObj *) getValObj:(NSInteger) qVid {
	valueObj *rvo=nil;
	
	//NSEnumerator *e = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while (vo = (valueObj *) [e nextObject]) {
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid == qVid) {
			rvo = vo;
			break;
		}
	}

	if (rvo == nil) {
		NSLog(@"tObj getValObj failed to find vid %d",qVid);
	}
	return rvo;
}

- (BOOL) loadData: (int) iDate {
	
	NSDate *qDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) iDate];
	[self resetData];
	self.sql = [NSString stringWithFormat:@"select count(*) from trkrData where date = %d;",iDate];
	int c = [self toQry2Int];
	if (c) {
		self.trackerDate = qDate; // from convenience method above, so do the retain
		NSMutableArray *i1 = [[NSMutableArray alloc] init];
		NSMutableArray *s1 = [[NSMutableArray alloc] init];
		self.sql = [NSString stringWithFormat:@"select id, val from voData where date = %d;", iDate];
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
		self.sql = nil;
		
		return YES;
	} else {
		NSLog(@"tObj loadData: nothing for date %d %@", iDate, qDate);
		return NO;
	}
}

- (void) saveData {

	if (self.trackerDate == nil) {
		trackerDate = [[NSDate alloc] init];
		//self.trackerDate = [[NSDate alloc] init];
		//[trackerDate release];
	}
	
	self.sql = [NSString stringWithFormat:@"insert or replace into trkrData (date) values (%d);", 
		   (int) [self.trackerDate timeIntervalSince1970] ];
	[self toExecSql];

	NSLog(@" tObj saveData %@ date %@",self.trackerName, self.trackerDate);
	
	for (valueObj *vo in self.valObjTable) {
		
		NSAssert((vo.vid >= 0),@"tObj saveData vo.vid <= 0");
		
		NSLog(@"  vo %@  id %d val %@", vo.valueName, vo.vid, vo.value);
		if ([vo.value isEqualToString:@""]) {
			//self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d, %d,NULL);",
			//			vo.vid, (int) [self.trackerDate timeIntervalSince1970]];
			self.sql = [NSString stringWithFormat:@"delete from voData where id = %d and date = %d;",
						vo.vid, (int) [self.trackerDate timeIntervalSince1970]];
		} else {
			self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d, %d,'%@');",
						vo.vid, (int) [self.trackerDate timeIntervalSince1970], vo.value];
		}
		[self toExecSql];
	}
	
	self.sql = nil;
}

#pragma mark -
#pragma mark modify tracker object <-> db 

- (void) resetData {
	self.trackerDate = nil;
	trackerDate = [[NSDate alloc] init];
	//self.trackerDate = [[NSDate alloc] init];
	//[trackerDate release];
	
	//NSEnumerator *e = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while (vo = (valueObj *) [e nextObject]) {
	for (valueObj *vo in self.valObjTable) {
		[vo.value setString:@""];  // TODO: default values go here
	}
}

- (bool) updateValObj:(valueObj *) valObj {
	
	//NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid == valObj.vid) {
			//*vo = *valObj; // indirection cannot be to an interface in non-fragile ABI
			vo.vtype = valObj.vtype;
			vo.valueName = valObj.valueName;     // property retain should keep these all ok w/o leaks
			//[vo.valueName setString:valObj.valueName];  // valueName not mutableString
			[vo.value setString:valObj.value];
			vo.display = valObj.display;
			return YES;
		}
	}
	return NO;
}

- (void) setMaxLabel 
{
	
	CGSize lsize = { 0.0f, 0.0f };
	
	//NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in self.valObjTable) {
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


- (void) deleteAllData {
	[self deleteTDb];
}

- (void) deleteCurrEntry {
	self.sql = [NSString stringWithFormat:@"delete from trkrData where date = %d;",
				(int) [self.trackerDate timeIntervalSince1970]];
	[self toExecSql];
	self.sql = [NSString stringWithFormat:@"delete from voData where date = %d;",
				(int) [self.trackerDate timeIntervalSince1970]];
	[self toExecSql];
	self.sql = nil;
}

#pragma mark -
#pragma mark query tracker methods

- (int) prevDate {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where date < %d order by date desc limit 1;", 
		   (int) [self.trackerDate timeIntervalSince1970] ];
	int rslt= [self toQry2Int];
	self.sql = nil;
	return rslt;
}

- (int) postDate {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where date > %d order by date asc limit 1;", 
		   (int) [self.trackerDate timeIntervalSince1970] ];
	int rslt= (NSInteger) [self toQry2Int];
	self.sql = nil;
	return rslt;
}

- (BOOL) voHasData:(NSInteger) vid
{
	self.sql = [NSString stringWithFormat:@"select count(*) from voData where id=%d;", (int) vid];
	int rslt= (NSInteger) [self toQry2Int];
	self.sql = nil;

	if (rslt == 0)
		return NO;
	return YES;
}
#pragma mark -
#pragma mark manipulate tracker's valObjs

- (valueObj *) voConfigCopy: (valueObj *) srcVO {
	NSLog(@"voConfigCopy: to= id %d %@ input vid=%d %@", self.toid, self.trackerName, srcVO.vid,srcVO.valueName);
	
	valueObj *newVO = [[valueObj alloc] init];
	newVO.vid = [self getUnique];
	newVO.vtype = srcVO.vtype;
	newVO.valueName = [NSString stringWithString:srcVO.valueName];
	//newVO.valueName = [[NSString alloc] initWithString:srcVO.valueName];  
	//[newVO.valueName release];  
	
	return newVO;
}

#pragma mark -
#pragma mark utility methods

- (void) describe {
	NSLog(@"tracker id %d name %@ dbName %@", self.toid, self.trackerName, self.dbName);

	//NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in self.valObjTable) {
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

// TODO: dump plist, votArray could be encoded as colorSet above (?)

- (NSArray *) votArray {
	if (votArray == nil) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath= [bundle pathForResource:@"rt-types" ofType:@"plist"];
		votArray = [[NSArray alloc] initWithContentsOfFile:plistPath]; 

	}
	
	return votArray;
}

@end
