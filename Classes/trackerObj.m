//
//  trackerObj.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <string.h>
//#import <stdlib.h>
//#import <NSNotification.h>

#import "trackerObj.h"
#import "valueObj.h"
#import "rTracker-constants.h"

#import "voState.h";
#import "privacyV.h";

@implementation trackerObj


@synthesize trackerName, trackerDate, valObjTable, optDict;
@synthesize nextColor, colorSet, votArray;
@synthesize maxLabel,activeControl,vc;

#define f(x) ((CGFloat) (x))


/******************************
 *
 * trackerObj db tables
 *
 *  trkrInfo: field(text,unique) ; val(text)
 *     field='name'      : tracker name
 *	   field='height'
 *     field='width'     : max size over all valobj display widgets (num, text, slider, etc)
 *	   field='privacy'   : user specified privacy value for trackerObj
 *     field='savertn'   : bool - save button returns to tracker list (else reset for new tracker data)
 *
 *  voConfig: id(int,unique) ; rank(int) ; type(int) ; name(text) ; color(int) ; graphtype(int) ; graphVO(int) ; priv(int)
 *         type: rt-types.plist and defs in valueObj.h
 *        color: defs in valueObj.h ; colorSet in trackerObj.m
 *    graphtype: defs in valueObj.h ; graphsForVOTCopy and mapGraphType in valueObj.m
 *         priv: copy from voInfo below
 *
 *  voInfo: id(int) ; field(text) ; val(text)  : unique(id,field)
 *    field='autoscale' : bool - calc number min and max Y-axis val from data
 *    field='ngmin'     :  user specified Y-axis min for number graph
 *    field='ngmax'     :  user specified Y-axis max for number graph
 *    field='nswl'      : bool - number should start with last saved value
 *    field='shrinkb'   : bool - adjust width of choice buttons to match text in each
 *    field='tbnl'      : bool - use number of lines in textbox as number when graphing; add graph opts back to picker if set
 *    field='tbni'      : bool - show names index component in picker for textbox display
 *    field='tbhi'      : bool - show history index component in picker for textbox display
 *    field='graph'     : bool - do graph vo 
 *    field='smin'		: user specified slider minimum
 *    field='smax'		: user specified slider maximum
 *    field='sdflt'		: user specified slider default
 *    field='privacy'	: user specified privacy value for valueObj
 *    field='c%d'		: text string for choice %d
 *    field='cc%d'		: graph color for for choice %d
 *	  field='frep%d'    : function range endpoint 0 or 1: -constant or valobj vid
 *    field='frv%d'     : function range endpoint 0 or 1 value if frep is offset like hours, months, ... (%d=1 not used)
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
	self.sql = @"create table if not exists trkrInfo (field text, val text, unique ( field ) on conflict replace);";
	[self toExecSql];
	self.sql = @"select count(*) from trkrInfo;";
	c = [self toQry2Int];
	if (c == 0) {
		// init clean db
		self.sql = @"create table if not exists voConfig (id int, rank int, type int, name text, color int, graphtype int, priv int, unique (id) on conflict replace);";
		[self toExecSql];
		self.sql = @"create table if not exists voInfo (id int, field text, val text, unique(id, field) on conflict replace);";
		[self toExecSql];
		self.sql = @"create table if not exists voData (id int, date int, val text, unique(id, date) on conflict replace);";
		[self toExecSql];
		self.sql = @"create index if not exists vodndx on voData (date);";
		[self toExecSql];
		self.sql = @"create table if not exists trkrData (date int unique on conflict replace);";
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
		nextColor=0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(trackerUpdated:) 
													 name:rtValueUpdatedNotification 
												   object:nil];
		
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
	
	self.optDict = nil;
	[optDict release];

	self.vc = nil;
	self.activeControl = nil;
	
	//unregister for value updated notices
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:rtValueUpdatedNotification
                                                  object:nil];  
	
	[super dealloc];
}

- (NSMutableDictionary *) optDict
{
	if (optDict == nil) {
		optDict = [[NSMutableDictionary alloc] init];
	}
	return optDict;
}


#pragma mark -
#pragma mark load/save db<->object 

- (void) loadConfig {
	NSLog(@"tObj loadConfig: %d",self.toid);
	NSAssert(self.toid,@"tObj load toid=0");
	
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	NSMutableArray *s2 = [[NSMutableArray alloc] init];
	self.sql = @"select field, val from trkrInfo;";
	[self toQry2ArySS :s1 s2:s2];
	//NSEnumerator *e1 = [s1 objectEnumerator];
	NSEnumerator *e2 = [s2 objectEnumerator];
	
	for ( NSString *key in s1 ) {
		[self.optDict setObject:[e2 nextObject] forKey:key];
	}
	
	self.trackerName = [self.optDict objectForKey:@"name"];
	CGFloat w = [[self.optDict objectForKey:@"width"] floatValue];
	CGFloat h = [[self.optDict objectForKey:@"height"] floatValue];
	self.maxLabel = (CGSize) {w,h};
	
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *i2 = [[NSMutableArray alloc] init];
	[s1 removeAllObjects];
	NSMutableArray *i3 = [[NSMutableArray alloc] init];
	NSMutableArray *i4 = [[NSMutableArray alloc] init];
	//self.sql = @"select id, type, name, color, graphtype from voConfig order by rank;";
	self.sql = [NSString stringWithFormat:@"select id, type, name, color, graphtype from voConfig where priv <= %i order by rank;",
				[privacyV getPrivacyValue]];
	[self toQry2AryIISII :i1 i2:i2 s1:s1 i3:i3 i4:i4];
	
	NSEnumerator *e1 = [i1 objectEnumerator];
	e2 = [i2 objectEnumerator];
	NSEnumerator *e3 = [s1 objectEnumerator];
	NSEnumerator *e4 = [i3 objectEnumerator];
	NSEnumerator *e5 = [i4 objectEnumerator];
	int vid;
	while ( vid = (int) [[e1 nextObject] intValue]) {
		valueObj *vo = [[valueObj alloc] initWithData:(id)self
										in_vid:vid 
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
	[i3 release];
	[i4 release];

	for (valueObj *vo in self.valObjTable) {
		[s1 removeAllObjects];
		[s2 removeAllObjects];
		
		self.sql = [NSString stringWithFormat:@"select field, val from voInfo where id=%d;",vo.vid];
		[self toQry2ArySS :s1 s2:s2];
		//e1 = [s1 objectEnumerator];
		e2 = [s2 objectEnumerator];
		
		for (NSString *key in s1 ) {
			[vo.optDict setObject:[e2 nextObject] forKey:key];
		}
		
		if (vo.vcolor > self.nextColor)
			nextColor = vo.vcolor;
		
		[vo.vos loadConfig];
	}
	
	//[self nextColor];  // inc safely past last used color
	if (nextColor >= [self.colorSet count])
		nextColor=0;
	
	[s1 release];
	[s2 release];

	
	self.sql=nil;
	
	self.trackerDate = nil;
	trackerDate = [[NSDate alloc] init];
}

// delete default settings from vo.optDict to save space

- (void) clearVoOptDict:(valueObj *)vo
{
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	self.sql = [NSString stringWithFormat:@"select field from voInfo where id=%d;",vo.vid];
	[self toQry2AryS:s1];
	
	NSString *key, *val;

	for (key in s1) {
		val = [vo.optDict objectForKey:key];
		self.sql = [NSString stringWithFormat:@"delete from voInfo where id=%d and field='%@';",vo.vid,key];
		
		if (val == nil) {
			[self toExecSql];
		} else if (([key isEqualToString:@"autoscale"] && [val isEqualToString:(AUTOSCALEDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"shrinkb"] && [val isEqualToString:(SHRINKBDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"tbnl"] && [val isEqualToString:(TBNLDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"tbni"] && [val isEqualToString:(TBNIDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"tbhi"] && [val isEqualToString:(TBHIDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"graph"] && [val isEqualToString:(GRAPHDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"nswl"] && [val isEqualToString:(NSWLDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"func"] && [val isEqualToString:@""])
				   ||
				   ([key isEqualToString:@"smin"] && ([val floatValue] == f(SLIDRMINDFLT)))
				   ||
				   ([key isEqualToString:@"smax"] && ([val floatValue] == f(SLIDRMAXDFLT)))
				   ||
				   ([key isEqualToString:@"sdflt"] && ([val floatValue] == f(SLIDRDFLTDFLT)))
				   ||
				   ([key isEqualToString:@"frep0"] && ([val intValue] == f(FREPDFLT)))
				   ||
				   ([key isEqualToString:@"frep1"] && ([val intValue] == f(FREPDFLT)))
				   ||
				   ([key isEqualToString:@"fnddp"] && ([val intValue] == f(FDDPDFLT)))
				   ||
				   ([key isEqualToString:@"privacy"] && ([val floatValue] == f(PRIVDFLT)))) {
			[self toExecSql];
			[vo.optDict removeObjectForKey:key];
		}
	}
	
	[s1 release];
	self.sql=nil;
}

- (void) clearToOptDict {
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	self.sql = @"select field from trkrInfo;";
	[self toQry2AryS:s1];
	
	NSString *key, *val;
	
	for (key in s1) {
		val = [self.optDict objectForKey:key];
		self.sql = [NSString stringWithFormat:@"delete from trkrInfo where field='%@';",key];
		
		if (val == nil) {
			[self toExecSql];
		} else if (([key isEqualToString:@"savertn"] && [val isEqualToString:(SAVERTNDFLT ? @"1" : @"0")])
				   ||
				   ([key isEqualToString:@"privacy"] && ([val floatValue] == f(PRIVDFLT)))) {
			[self toExecSql];
			[self.optDict removeObjectForKey:key];
		}
	}
	
	[s1 release];
	self.sql=nil;
}

- (void) saveToOptDict {

	[self clearToOptDict];
	
	for (NSString *key in self.optDict) {
		self.sql = [NSString stringWithFormat:@"insert or replace into trkrInfo (field, val) values ('%@', '%@');",
					key, [self.optDict objectForKey:key]];
		[self toExecSql];
	}
	
}

- (void) updateVORefs:(NSInteger)newVID old:(NSInteger)oldVID {
	for (valueObj *vo in self.valObjTable) {
		[vo.vos updateVORefs:newVID old:oldVID];
	}
}

- (void) saveConfig {
	NSLog(@"tObj saveConfig: trackerName= %@",trackerName) ;
	
	[self confirmDb];
	
	// trackerName and maxLabel maintained in optDict by routines which set them

	[self saveToOptDict];
	
	// put valobjs in state for saving 
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid <= 0) {
			NSInteger old = vo.vid;
			vo.vid = [self getUnique];
			[self updateVORefs:vo.vid old:old];
		}
	}
	
	// now save
	int i=0;
	for (valueObj *vo in self.valObjTable) {

		NSLog(@"  vo %@  id %d", vo.valueName, vo.vid);
		self.sql = [NSString stringWithFormat:@"insert or replace into voConfig (id, rank, type, name, color, graphtype,priv) values (%d, %d, %d, '%@', %d, %d, %d);",
					vo.vid, i++, vo.vtype, vo.valueName, vo.vcolor, vo.vGraphType, [[vo.optDict objectForKey:@"privacy"] intValue]];
		[self toExecSql];
		
		[self clearVoOptDict:vo];
		
		for (NSString *key in vo.optDict) {
			self.sql = [NSString stringWithFormat:@"insert or replace into voInfo (id, field, val) values (%d, '%@', '%@');",
						vo.vid, key, [vo.optDict objectForKey:key]];
			[self toExecSql];
		}
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
			//NSAssert1(vo,@"tObj loadData no valObj with vid %d",vid);
			if (vo) { // no vo if privacy restricted
				[vo.value setString:(NSString *) [e3 nextObject]];
				vo.retrievedData = YES;
			}
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
	}
	
	NSLog(@" tObj saveData %@ date %@",self.trackerName, self.trackerDate);

	BOOL haveData=NO;
	int tdi = [self.trackerDate timeIntervalSince1970];
	
	for (valueObj *vo in self.valObjTable) {
		
		NSAssert((vo.vid >= 0),@"tObj saveData vo.vid <= 0");
		if (vo.vtype != VOT_FUNC) { // no fn results data kept
			NSLog(@"  vo %@  id %d val %@", vo.valueName, vo.vid, vo.value);
			if ([vo.value isEqualToString:@""]) {
				self.sql = [NSString stringWithFormat:@"delete from voData where id = %d and date = %d;",vo.vid, tdi];
			} else {
				haveData = YES;
				self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d, %d,'%@');",
							vo.vid, tdi, vo.value];
			}
			[self toExecSql];
		} 
	}
	
	if (haveData) {
		self.sql = [NSString stringWithFormat:@"insert or replace into trkrData (date) values (%d);", tdi];
		[self toExecSql];
	} else {
		self.sql = [NSString stringWithFormat:@"select count(*) from voData where date=%d;",tdi];
		int r = [self toQry2Int];
		if (r==0) {
			self.sql = [NSString stringWithFormat:@"delete from trkrData where date=%d;",tdi];
			[self toExecSql];
		}
	}

	self.sql = nil;
}

#pragma mark -
#pragma mark write tracker as xls file

- (void) writeTrackerXLS:(NSFileHandle*)nsfh {
	
	//[nsfh writeData:[self.trackerName dataUsingEncoding:NSUnicodeStringEncoding]];
	[nsfh writeData:[self.trackerName dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (valueObj *vo in self.valObjTable) {
		
		NSAssert((vo.vid >= 0),@"tObj writeTrackerXLS vo.vid <= 0");
		if (vo.vtype != VOT_FUNC) { // no fn results data kept
			NSLog(@"wtxls:  vo %@  id %d val %@", vo.valueName, vo.vid, vo.value);
			//[nsfh writeData:[vo.valueName dataUsingEncoding:NSUnicodeStringEncoding]];
			[nsfh writeData:[vo.valueName dataUsingEncoding:NSUTF8StringEncoding]];
		} 
	}
	
}

#pragma mark -
#pragma mark modify tracker object <-> db 

- (void) resetData {
	self.trackerDate = nil;
	trackerDate = [[NSDate alloc] init];
	
	for (valueObj *vo in self.valObjTable) {
		[vo resetData];
		//[vo.value setString:@""];  
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
	[self.optDict setObject:[NSNumber numberWithFloat:lsize.width] forKey:@"width"];
	[self.optDict setObject:[NSNumber numberWithFloat:lsize.height] forKey:@"height"];
	
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

- (int) lastDate {
	self.sql = @"select date from trkrData order by date desc limit 1;";
	int rslt= (NSInteger) [self toQry2Int];
	self.sql = nil;
	return rslt;
}

- (NSString*) voGetNameForVID:(NSInteger)vid {
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid == vid)
			return vo.valueName;
	}
	NSAssert(0,@"voGetNameForVID failed");
	return [NSString stringWithFormat:@"vid %d not found",vid];
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

- (BOOL) checkData {  // does a contained valObj have stored data?
	for (valueObj *vo in self.valObjTable) {
		if ([self voHasData:vo.vid])
			return YES;
	}
	return NO;
}

- (BOOL) hasData {  // is there a date entry in trkrData matching current trackerDate ?
	self.sql = [NSString stringWithFormat:@"select count(*) from trkrData where date=%d",(int) [self.trackerDate timeIntervalSince1970]];
	int r = [self toQry2Int];
	self.sql = nil;
	return (r!=0);
}

- (int) noCollideDate:(int)testDate {
	BOOL going=YES;
	
	while (going) {
		self.sql = [NSString stringWithFormat:@"select count(*) from trkrData where date=%d",testDate];
		if ([self toQry2Int] == 0)
			going=NO;
		else 
			testDate++;
	}
	self.sql = nil;
	return testDate;
}
	
- (void) changeDate:(NSDate*)newDate {
	int ndi = (int) [self noCollideDate:[newDate timeIntervalSince1970]];
	int odi = (int) [self.trackerDate timeIntervalSince1970];
	
	self.sql = [NSString stringWithFormat:@"update trkrData set date=%d where date=%d;",ndi,odi];
	[self toExecSql];
	self.sql = [NSString stringWithFormat:@"update voData set date=%d where date=%d;",ndi,odi];
	[self toExecSql];
	self.sql=nil;
	self.trackerDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)ndi]; // might have changed to avoid collision
}

#pragma mark tracker data updated event handling

- (void) trackerUpdated:(NSNotification*)n {
	id obj = [n object];
	if ([obj isMemberOfClass:[valueObj class]]) {
		valueObj *vo = (valueObj*) [n object];
		NSLog(@"tracker %@ updated by vo %d : %@ => %@",self.trackerName,vo.vid,vo.valueName, vo.value);
	
	} else {
		voState *vos= (voState*) obj;
		NSLog(@"tracker %@ updated by vo (voState)  %d : %@ => %@",self.trackerName,vos.vo.vid,vos.vo.valueName, vos.vo.value);
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:rtTrackerUpdatedNotification object:self];
}

#pragma mark -
#pragma mark manipulate tracker's valObjs

- (valueObj *) voConfigCopy: (valueObj *) srcVO {
	NSLog(@"voConfigCopy: to= id %d %@ input vid=%d %@", self.toid, self.trackerName, srcVO.vid,srcVO.valueName);
	
	valueObj *newVO = [[valueObj alloc] init];
	newVO.vid = [self getUnique];
	newVO.parentTracker = srcVO.parentTracker;
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

- (NSInteger) nextColor
{
	NSInteger rv = nextColor;
	if (++nextColor >= [self.colorSet count])
		nextColor=0;
	return rv;
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
