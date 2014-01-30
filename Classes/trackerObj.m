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

#import "voState.h"
#import "privacyV.h"

#import "togd.h"

#import "dbg-defs.h"
#import "rTracker-resource.h"


@implementation trackerObj


@synthesize trackerDate, valObjTable, reminders, optDict;  //trackerName
@synthesize nextColor, votArray;
@synthesize activeControl,vc, dateFormatter, dateOnlyFormatter, csvReadFlags, csvProblem, togd, goRecalculate; // prevTID  // maxLabel

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
 *     field='graphMaxDays' : max number of days to plot on graph Y axis ; 0 = no limit
 *     field='dfltEmail' : email address to populate to: with
 *	   field='rtdb_version' : database version this tracker created for (these set on load tracker as new with v 1.0.7)
 *	   field='rtfn_version' : function token set version this tracker created for
 *	   field='rt_version':  rTracker version this tracker created for/with
 *	   field='rt_build'  : rTracker build number this tracker created for/with
 *     TODO: field='labelwid'  : max size to print over all valobj values
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
 *    field='exportvalb': bool - in csv, export value assigned to choice instead of button label
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
 *    field='fnddp'     : function display decimal pt: number of digits to show in output format
 *    TODO: field='tbmlc'     : textbox max line count for tbnl
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

// getters and setters

- (NSString*) trackerName {
    if (! trackerName) {
        trackerName = [[self.optDict objectForKey:@"name"] retain];
    }
    return trackerName;
}

- (void) setTrackerName:(NSString *)trackerNameValue {
    if (trackerName != trackerNameValue) {
        [trackerNameValue retain];
        [trackerName release];
        trackerName = trackerNameValue;
        if (trackerNameValue) { // if not nil
            [self.optDict setObject:trackerNameValue forKey:@"name"];
        } else {
            [self.optDict removeObjectForKey:@"name"];
        }
    }
}

- (CGSize) maxLabel {
    if ((! maxLabel.height) || (! maxLabel.width)) {
        CGFloat w = [[self.optDict objectForKey:@"width"] floatValue];
        CGFloat h = [[self.optDict objectForKey:@"height"] floatValue];
        maxLabel = (CGSize) {w,h};
    }
    return maxLabel;
}

- (void) setMaxLabel:(CGSize)maxLabelValue {
    if ((maxLabel.height != maxLabelValue.height) || (maxLabel.width != maxLabelValue.width)) {
        maxLabel = maxLabelValue;
        if (maxLabel.height != 0.0 && maxLabel.width != 0.0) {
            [self.optDict setObject:[NSNumber numberWithFloat:maxLabel.width] forKey:@"width"];
            [self.optDict setObject:[NSNumber numberWithFloat:maxLabel.height] forKey:@"height"];
        } else {
            [self.optDict removeObjectForKey:@"width"];
            [self.optDict removeObjectForKey:@"height"];
        }
    }
}

- (NSInteger) prevTID {
    return [(NSNumber*) [self.optDict objectForKey:@"prevTID"] integerValue];
}

- (void) setPrevTID:(NSInteger)prevTIDvalue {
    if (prevTIDvalue) {
        [self.optDict setObject:[NSNumber numberWithInteger:prevTIDvalue] forKey:@"prevTID"];
    } else {
        [self.optDict removeObjectForKey:@"prevTID"];
    }
}

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
		self.sql = @"create table if not exists trkrData (date int unique on conflict replace, minpriv int);";
		[self toExecSql];
		
	}
	self.sql = nil;
}

- (void) confirmDb {
	dbgNSAssert(self.toid,@"tObj confirmDb toid=0");
	if (! self.dbName) {
		dbName = [[NSString alloc] initWithFormat:@"trkr%d.sqlite3",toid];
		//self.dbName = [[NSString alloc] initWithFormat:@"trkr%d.sqlite3",toid];
		[self getTDb];
		[self initTDb];
	}
}


- (id)init {
	
	if ((self = [super init])) {
		self.trackerDate = nil;

		//self.valObjTable = [[NSMutableArray alloc] init];
		valObjTable = [[NSMutableArray alloc] init];
		nextColor=0;

        /*  move to utc
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(trackerUpdated:) 
													 name:rtValueUpdatedNotification 
												   object:nil];
		*/
		//DBGLog(@"init trackerObj New");
        goRecalculate=NO;
	}
	
	return self;
}

- (id)init:(int) tid {
	if ((self = [self init])) {
		//DBGLog(@"init trackerObj id: %d",tid);
		self.toid = tid;
		[self confirmDb];
		[self loadConfig];
	}
	return self;
}

- (id)initWithDict:(NSDictionary*) dict {
	if ((self = [self init])) {
		//DBGLog(@"init trackerObj from dict id: %d",[dict objectForKey:@"tid"]);
		self.toid = [(NSNumber*) [dict objectForKey:@"tid"] integerValue];
		[self confirmDb];
		[self loadConfigFromDict:dict];
	}
	return self;
}

- (BOOL) mvIfFn:(valueObj*)vo testVT:(NSInteger)tstVT {
    if ((VOT_FUNC != tstVT) || (VOT_FUNC == vo.vtype)) {
        return NO;
    }
    
    // fix it
    [self voUpdateVID:vo newVID:[self getUnique]];
    
    vo.valueName = [vo.valueName stringByAppendingString:@"_data"];
    
    return YES;
}

- (void) sortVoTableByArray:(NSArray*)arr {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSUInteger ndx1=0, ndx2=0, c=0, c2=0;
    valueObj *vo;
    for (vo in self.valObjTable) {
        [dict setObject:[NSNumber numberWithInteger:ndx1] forKey:[NSNumber numberWithInt:vo.vid]];
        ndx1++;
    }
    
    c = [self.valObjTable count];
    c2 = [arr count];
    for (ndx1=0,ndx2=0; ndx1<c && ndx2<c2; ndx1++,ndx2++) {
        int currVid = ((valueObj*)[self.valObjTable objectAtIndex:ndx1]).vid;
        int targVid = ((valueObj*)[arr objectAtIndex:ndx2]).vid;
        //DBGLog(@"ndx2: %d  targVid:%d",ndx2,targVid);
        if (currVid != targVid) {
            NSUInteger targNdx = [((NSNumber*)[dict objectForKey:[NSNumber numberWithInt:targVid]]) unsignedIntegerValue];
            [self.valObjTable exchangeObjectAtIndex:ndx1 withObjectAtIndex:targNdx];
            [dict setObject:[NSNumber numberWithInt:targNdx] forKey:[NSNumber numberWithUnsignedInt:currVid]];
            [dict setObject:[NSNumber numberWithInt:ndx1] forKey:[NSNumber numberWithUnsignedInt:targVid]];

        }
        
    }
    
    [dict release];

}

- (void) voSetFromDict:(valueObj*)vo dict:(NSDictionary*)dict {
    vo.optDict = (NSMutableDictionary*) [dict objectForKey:@"optDict"];
    vo.vpriv = [(NSNumber*) [dict objectForKey:@"vpriv"] integerValue];
    vo.vtype = [(NSNumber*) [dict objectForKey:@"vtype"] integerValue];
    vo.vcolor = [(NSNumber*) [dict objectForKey:@"vcolor"] integerValue];
    vo.vGraphType = [(NSNumber*) [dict objectForKey:@"vGraphType"] integerValue];
}

- (void) rescanVoIds:(NSMutableDictionary*)existingVOs {
    [existingVOs removeAllObjects];
    for (valueObj *vo in self.valObjTable) {
        [existingVOs setObject:vo forKey:[NSNumber numberWithInt:vo.vid]];
    }
}

// make self trackerObj conform to incoming dict = trackerObj optdict, valobj array of vid, name
// handle voConfig voInfo; voData to be handled by loadDataDict
- (void) confirmTOdict:(NSDictionary*)dict {
    
    NSDictionary *newOptDict = [dict objectForKey:@"optDict"];
    NSString *key;
    for (key in newOptDict) {               // overwrite options with new input
        [self.optDict setObject:[newOptDict objectForKey:key] forKey:key];  // incoming optDict may be incomplete, assume obsolete optDict entries not a problem
    }
    
    NSArray *newValObjs = [dict objectForKey:@"valObjTable"];  // typo @"valObjTable@" removed 26.v.13
    [rTracker_resource stashProgressBarMax:[newValObjs count]];
    
    NSMutableDictionary *existingVOs = [[NSMutableDictionary alloc] init];
    NSMutableArray *newVOs = [[NSMutableArray alloc]init];
    
    [self rescanVoIds:existingVOs];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^recover\\d+$" options:0 error:NULL];

    for (NSDictionary *voDict in newValObjs) {
        NSNumber *nVidN = [voDict objectForKey:@"vid"];                // new VID
        NSString *nVname = [voDict objectForKey:@"valueName"];
        NSInteger nVtype = [(NSNumber*)[voDict objectForKey:@"vtype"] integerValue];
        BOOL addVO=YES;
        BOOL createdVO=NO;
        
        valueObj *eVO = [existingVOs objectForKey:nVidN];
        if (eVO) {                                          // self has vid;
            NSUInteger recoveredName = [regex numberOfMatchesInString:eVO.valueName options:0 range:NSMakeRange(0, [eVO.valueName length])];
            if ([nVname isEqualToString:eVO.valueName] || (1==recoveredName)) {       // name matches same vid or name is recovered1234
                if ([self mvIfFn:eVO testVT:nVtype]) {          // move out of way if fn-data clash
                    [self rescanVoIds:existingVOs];                     // re-validate
                    eVO = [[valueObj alloc] initWithDict:self dict:voDict]; // create new vo
                    createdVO=YES;
                } else {
                    addVO=NO;     // name and VID match so we overwrite existing vo
                    [self voSetFromDict:eVO dict:voDict];
                }
            } else {                                           // name does not match
                [self voUpdateVID:eVO newVID:[self getUnique]];    // shift eVO to another vid
                [self rescanVoIds:existingVOs];                     // re-validate
                eVO = nil;                                          // scan names below
            }
        }
        
        if (!eVO) { // self does not have vid, or has vid and name does not match and self's vid moved out of way
            BOOL foundMatch=NO;
            for (valueObj *vo in self.valObjTable) {           // now look for any existing vo with same name
                if (! foundMatch) {                            //  (only take first match)
                    if ([nVname isEqualToString:vo.valueName]) {       // name matches different existing vid
                        foundMatch=YES;
                        if ([self mvIfFn:vo testVT:nVtype]) {               // move out of way if fn-data clash
                            [self rescanVoIds:existingVOs];                     // re-validate
                            //eVO = [[valueObj alloc] initWithDict:self dict:voDict];  // create new vo --> do below  (eVO is nil)
                        } else {                                        // did not mv due to fn-data clash - so overwrite
                            [self voUpdateVID:vo newVID:[nVidN integerValue]];        // change self vid to input vid
                            [self rescanVoIds:existingVOs];                     // re-validate
                            eVO = vo;
                            addVO = NO;
                            [self voSetFromDict:eVO dict:voDict];
                        }
                    }
                }
            }
            if ((! foundMatch) || (! eVO)) {
                eVO = [[valueObj alloc] initWithDict:self dict:voDict];    // also confirms uniquev >= nVid
                createdVO=YES;
            }
        }
                  
        if (addVO) {
            [self addValObj:eVO];
            [self rescanVoIds:existingVOs];                     // re-validate
        }
        
        [newVOs addObject:eVO];
        //DBGLog(@"** added eVO vid %d",eVO.vid);
        
        if (createdVO) {
            [eVO release];
        }
        [rTracker_resource bumpProgressBar];
    }
    
    [existingVOs release];
    [self sortVoTableByArray:newVOs];
    [newVOs release];
}

/*
 // version 0 with code duplication
 
 if (eVO) {                                          // self has vid;
     if ([nVname isEqualToString:eVO.valueName]) {       // name matches same vid
         if ([self mvIfFn:eVO testVT:nVtype]) {          // move out of way if fn-data clash
             eVO = [[valueObj alloc] initWithDict:self dict:voDict];  // create new vo
         } else {
             addVO=NO;     // name and VID match so we overwrite existing vo
             [self voSetFromDict:eVO dict:voDict];
         }
     } else {                                           // name does not match
         [self voUpdateVID:eVO newVID:[self getUnique]];    // shift eVO to another vid
         [self rescanVoIds:existingVOs];                     // re-validate
         // code duplication!!!
         BOOL foundMatch=NO;
         for (valueObj *vo in self.valObjTable) {           // now look for any existing vo with same name
             if (! foundMatch) {                            //  (only take first match)
                 if ([nVname isEqualToString:vo.valueName]) {       // name matches different existing vid
                     foundMatch=YES;
                     if ([self mvIfFn:vo testVT:nVtype]) {               // move out of way if fn-data clash
                         //eVO = [[valueObj alloc] initWithDict:self dict:voDict];  // create new vo
                     } else {                                        // did not mv due to fn-data clash - so overwrite
                         [self voUpdateVID:vo newVID:[nVidN integerValue]];        // change self vid to input vid
                         [self rescanVoIds:existingVOs];                     // re-validate
                         eVO = vo;
                         addVO = NO;
                         [self voSetFromDict:eVO dict:voDict];
                     }
                 }
             }
         }
         if (! foundMatch) {
             eVO = [[valueObj alloc] initWithDict:self dict:voDict];    // also confirms uniquev >= nVid
         }
     }
 
 } else {                                            // self does not have vid
     // code duplication!
     BOOL foundMatch=NO;
     for (valueObj *vo in self.valObjTable) {           // now look for any existing vo with same name
         if (! foundMatch) {                            //  (only take first match)
             if ([nVname isEqualToString:vo.valueName]) {       // name matches different existing vid
                 foundMatch=YES;
                 if ([self mvIfFn:vo testVT:nVtype]) {               // move out of way if fn-data clash
                     //eVO = [[valueObj alloc] initWithDict:self dict:voDict];  // create new vo
                 } else {                                        // did not mv due to fn-data clash - so overwrite
                     [self voUpdateVID:vo newVID:[nVidN integerValue]];        // change self vid to input vid
                     [self rescanVoIds:existingVOs];                     // re-validate
                     eVO = vo;
                     addVO = NO;
                     [self voSetFromDict:eVO dict:voDict];
                 }
             }
         }
     }
     if (! foundMatch) {
         eVO = [[valueObj alloc] initWithDict:self dict:voDict];    // also confirms uniquev >= nVid
     }
 }
 
if (addVO) {
    [self addValObj:eVO];
    [self rescanVoIds:existingVOs];                     // re-validate
}
 
*/

/*
 
 NSInteger eVid = -1;
 for (valueObj *vo in self.valObjTable) {
 if ([vo.valueName isEqualToString:nVname]) {
 if ((-1 == eVid) || (vo.vid == nVid)) {         // first matching nVname or matches nVname and nVid
 eVid = vo.vid;
 }
 }
 }
 
 if (-1 == eVid) { // no existing valObj with this name
 
 if ([self voVIDisUsed:nVid]) {  // handle case of existing valObj has same vid
 [self voUpdateVID:nVid new:[self getUnique]];
 }
 [self addValObj:[[valueObj alloc] initWithDict:self dict:voDict]];  // safe to add as specified
 
 } else { // name match .. first or also vid match
 [self voUpdateVID:eVid new:nVid];  // does nothing if same already
 
 //----: what if type changes?  what if changes to function??? need to copy voConfig yes???  do what addValObj does
 // consider updateValObj
 }
 */
/* think done need to test !
 
 rtm working here
 if eVid is 0 then add new valueObj
 else if eVid matches voDict vid then [problem if vtype mismatch ?]
 else if vid does not match then mess to merge ?
 */

/*
 return [NSDictionary dictionaryWithObjectsAndKeys:
 [NSNumber numberWithInteger:self.vid],@"vid",
 [NSNumber numberWithInteger:self.vtype],@"vtype",
 [NSNumber numberWithInteger:self.vpriv],@"vpriv",
 self.valueName,@"valueName",
 [NSNumber numberWithInteger:self.vcolor],@"vcolor",
 [NSNumber numberWithInteger:self.vGraphType],@"vGraphType",
 self.optDict,@"optDict",
 nil];
 */

- (void) dealloc {
	DBGLog(@"dealloc tObj: %@",self.trackerName);
	
	self.trackerName = nil;
	[trackerName release];
	self.trackerDate = nil;
	[trackerDate release];
	self.valObjTable = nil;
	[valObjTable release];
	
	self.votArray = nil;
	[votArray release];
	
	self.optDict = nil;
	[optDict release];

	self.vc = nil;
	self.activeControl = nil;
	
    self.dateFormatter =nil;
    [dateFormatter release];
    self.dateOnlyFormatter =nil;
    [dateOnlyFormatter release];
    
	//unregister for value updated notices
    /* move to utc
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:rtValueUpdatedNotification
                                                  object:nil];
     */
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
/*
 // use loadConfig instead
- (void) reloadVOtable {
    [self.valObjTable removeAllObjects];
    self.sql = @"select count(*) from voConfig";
    int c = [self toQry2Int];
    
    self.sql =[NSString stringWithFormat:@"select id from voConfig where priv <= %i order by rank", [privacyV getPrivacyValue]];
    NSMutableArray *vida = [[NSMutableArray alloc] initWithCapacity:c];
    [self toQry2AryI:vida];
    for (NSNumber *nvid in vida) {
        valueObj *vo = [[valueObj alloc] initFromDB:self in_vid:[nvid integerValue] ];
        [self.valObjTable addObject:(id) vo];
        [vo release];
    }
    [vida release];
}
 */
//
// load tracker configuration incl valObjs from self.tDb, preset self.toid
// self.trackerName from tDb
// 
- (void) loadConfig {
	
	dbgNSAssert(self.toid,@"tObj load toid=0");
	
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	NSMutableArray *s2 = [[NSMutableArray alloc] init];
	self.sql = @"select field, val from trkrInfo;";
	[self toQry2ArySS :s1 s2:s2];
	//NSEnumerator *e1 = [s1 objectEnumerator];
	NSEnumerator *e2 = [s2 objectEnumerator];
	
	for ( NSString *key in s1 ) {
		[self.optDict setObject:([key isEqualToString:@"name"] ? [rTracker_resource fromSqlStr:[e2 nextObject]] : [e2 nextObject])
                         forKey:key];
	}

    [self setTrackerVersion];
    [self setToOptDictDflts];
    
    DBGLog(@"to optdict: %@",self.optDict);
    
	//self.trackerName = [self.optDict objectForKey:@"name"];

    DBGLog(@"tObj loadConfig toid:%d name:%@",self.toid,self.trackerName);
	
    CGFloat w = [[self.optDict objectForKey:@"width"] floatValue];
	CGFloat h = [[self.optDict objectForKey:@"height"] floatValue];
	self.maxLabel = (CGSize) {w,h};
	
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *i2 = [[NSMutableArray alloc] init];
	[s1 removeAllObjects];
	NSMutableArray *i3 = [[NSMutableArray alloc] init];
	NSMutableArray *i4 = [[NSMutableArray alloc] init];
	NSMutableArray *i5 = [[NSMutableArray alloc] init];
	//self.sql = @"select id, type, name, color, graphtype from voConfig order by rank;";
	self.sql = [NSString stringWithFormat:@"select id, type, name, color, graphtype, priv from voConfig where priv <= %i order by rank;",
				[privacyV getPrivacyValue]];
	[self toQry2AryIISIII:i1 i2:i2 s1:s1 i3:i3 i4:i4 i5:i5];
	
	NSEnumerator *e1 = [i1 objectEnumerator];
	e2 = [i2 objectEnumerator];
	NSEnumerator *e3 = [s1 objectEnumerator];
	NSEnumerator *e4 = [i3 objectEnumerator];
	NSEnumerator *e5 = [i4 objectEnumerator];
	NSEnumerator *e6 = [i5 objectEnumerator];
	int vid;
	while ( (vid = (int) [[e1 nextObject] intValue]) ) {
		valueObj *vo = [[valueObj alloc] initWithData:(id)self
										in_vid:vid 
									  in_vtype:(int)[[e2 nextObject] intValue] 
									  in_vname: (NSString *) [e3 nextObject] 
									 in_vcolor:(int)[[e4 nextObject] intValue] 
								 in_vgraphtype:(int)[[e5 nextObject] intValue] 
                                      in_vpriv:(int)[[e6 nextObject] intValue] 
						];
		[self.valObjTable addObject:(id) vo];
		[vo release];
	}
	
	[i1 release];
	[i2 release];
	[i3 release];
	[i4 release];
	[i5 release];
    
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
			self.nextColor = vo.vcolor;
		
        [vo.vos setOptDictDflts];
		[vo.vos loadConfig];
        
        [vo validate];
	}
	
	//[self nextColor];  // inc safely past last used color
	if (self.nextColor >= [[rTracker_resource colorSet] count])
		self.nextColor=0;
	
	[s1 release];
	[s2 release];

	
	self.sql=nil;
	
	self.trackerDate = nil;
	trackerDate = [[NSDate alloc] init];
    [self rescanMaxLabel];
    

}

// 
// load tracker config, valObjs from supplied dictionary
// self.trackerName from dictionary:optDict:trackerName
//
- (void) loadConfigFromDict:(NSDictionary *)dict {
	
	dbgNSAssert(self.toid,@"tObj load from dict toid=0");
	
    self.optDict = [dict objectForKey:@"optDict"];
    
    [self setTrackerVersion];
    [self setToOptDictDflts];  // probably redundant
    
	//self.trackerName = [self.optDict objectForKey:@"name"];
    
    DBGLog(@"tObj loadConfigFromDict toid:%d name:%@",self.toid,self.trackerName);
	
    //CGFloat w = [[self.optDict objectForKey:@"width"] floatValue];
	//CGFloat h = [[self.optDict objectForKey:@"height"] floatValue];
	//self.maxLabel = (CGSize) {w,h};
	
    NSArray *voda = [dict objectForKey:@"valObjTable"];
    for (NSDictionary *vod in voda) {
        valueObj *vo = [[valueObj alloc] initWithDict:(id)self dict:vod];
        DBGLog(@"add vo %@",vo.valueName);
        [self.valObjTable addObject:(id) vo];
		[vo release];
    }

	for (valueObj *vo in self.valObjTable) {

		if (vo.vcolor > self.nextColor)
			nextColor = vo.vcolor;
		
        [vo.vos setOptDictDflts];
		[vo.vos loadConfig];  // loads from vo optDict
	}
	
	//[self nextColor];  // inc safely past last used color
	if (nextColor >= [[rTracker_resource colorSet] count])
		nextColor=0;
	
	self.sql=nil;
	
	self.trackerDate = nil;
	trackerDate = [[NSDate alloc] init];
    DBGLog(@"loadConfigFromDict finished loading %@",self.trackerName);
}

// delete default settings from vo.optDict to save space

- (void) clearVoOptDict:(valueObj *)vo
{
	NSMutableArray *s1 = [[NSMutableArray alloc] init];
	self.sql = [NSString stringWithFormat:@"select field from voInfo where id=%d;",vo.vid];
	[self toQry2AryS:s1];
	
	NSString *key;

	for (key in s1) {
		self.sql = [NSString stringWithFormat:@"delete from voInfo where id=%d and field='%@';",vo.vid,key];

		if (([vo.vos cleanOptDictDflts:key])) {
			[self toExecSql];
		}
	}
	
	[s1 release];
	self.sql=nil;
}



#pragma mark tracker obj default set and vacuum routines together

//  version change for 1.0.7 to include version info with tracker
- (void) setTrackerVersion {
    
    if ((nil == [self.optDict objectForKey:@"rt_build"])) {
        [self.optDict setObject:[NSNumber numberWithInt:RTDB_VERSION] forKey:@"rtdb_version"];
        [self.optDict setObject:[NSNumber numberWithInt:RTFN_VERSION] forKey:@"rtfn_version"];
        [self.optDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"rt_version"];
        [self.optDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"rt_build"];
        [self saveToOptDict];
        
        DBGLog(@"tracker init version info");
    }
}

// setToOptDictDflts
//  fields not stored in db if they are set to default values, so here set set those values in Tobj if not read in from db
- (void) setToOptDictDflts {
    if ((nil == [self.optDict objectForKey:@"savertn"])) {
        [self.optDict setObject:(SAVERTNDFLT ? @"1" : @"0") forKey:@"savertn"];
    }
    if ((nil == [self.optDict objectForKey:@"privacy"])) {
        [self.optDict setObject:[NSString stringWithFormat:@"%d",PRIVDFLT] forKey:@"privacy"];
    }
    if ((nil == [self.optDict objectForKey:@"graphMaxDays"])) {
        [self.optDict setObject:[NSString stringWithFormat:@"%d",GRAPHMAXDAYSDFLT] forKey:@"graphMaxDays"];
    }
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
				   ([key isEqualToString:@"privacy"] && ([val intValue] == PRIVDFLT))
                   ||
				   ([key isEqualToString:@"graphMaxDays"] && ([val intValue] == GRAPHMAXDAYSDFLT))
                   ) {
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
					key, ([key isEqualToString:@"name"] ? [rTracker_resource toSqlStr:[self.optDict objectForKey:key]] : [self.optDict objectForKey:key])];
		[self toExecSql];
	}
	
}

- (void) updateVORefs:(NSInteger)newVID old:(NSInteger)oldVID {
	for (valueObj *vo in self.valObjTable) {
		[vo.vos updateVORefs:newVID old:oldVID];
	}
}

// create minimal valobj in db tables to handle column in CSV data that does not match existing valObj
- (int) createVOinDb:(NSString*)name inVid:(int)inVid {
    NSInteger vid;
    if (0 != inVid) {
        self.sql = [NSString stringWithFormat:@"select count(*) from voConfig where id=%d",inVid];
        if (0 < [self toQry2Int]) {
            self.sql = [NSString stringWithFormat:@"update voConfig set name='%@' where id=%d",name,inVid];
            [self toExecSql];
            return inVid;
        }
        vid = inVid;
        [self minUniquev:inVid];
    } else {
        vid = [self getUnique];
    }
    self.sql = @"select max(rank) from voConfig";
    
    NSInteger rank = [self toQry2Int] +1;
    
    self.sql = [NSString stringWithFormat:@"insert into voConfig (id, rank, type, name, color, graphtype,priv) values (%d, %d, %d, '%@', %d, %d, %d);",
                vid, rank, 0, [rTracker_resource toSqlStr:name], 0, 0, MINPRIV];
    [self toExecSql];
    
    return vid;
}

// set type for valobj in db table if passed vot matches a type
-(BOOL) configVOinDb:(int)valObjID vots:(NSString*)vots vocs:(NSString*)vocs rank:(int)rank {
    BOOL rslt=NO;
    if ([@"" isEqualToString:vots]) return rslt;
    
    NSUInteger vot = [self.votArray indexOfObject:vots];
    if (NSNotFound == vot) return rslt;
    
    //DBGLog(@"vot= %d",vot);
    
    self.sql = [NSString stringWithFormat:@"update voConfig set type=%d where id=%d",vot,valObjID];
    [self toExecSql];
    rslt=YES;
    DBGLog(@"vot= %d",vot);
    if (! vocs) return rslt;
    
    DBGLog(@"search for %@",vocs);
    
    NSUInteger voc = [[rTracker_resource colorNames] indexOfObject:vocs];
    if (NSNotFound == voc) return rslt;

    if (VOT_CHOICE == vot) voc = -1;
    DBGLog(@"voc= %d",voc);
    
    self.sql = [NSString stringWithFormat:@"update voConfig set color=%d where id=%d",voc,valObjID];
    [self toExecSql];
    
    // rank only 0 for timestamp
    self.sql = [NSString stringWithFormat:@"update voConfig set rank=%d where id=%d",rank,valObjID];
    [self toExecSql];
    
    
    self.sql=nil;
    
    return rslt;
}

- (void) saveVoOptdict:(valueObj*) vo {
    [self clearVoOptDict:vo];
    for (NSString *key in vo.optDict) {
        self.sql = [NSString stringWithFormat:@"insert or replace into voInfo (id, field, val) values (%d, '%@', '%@');",
                    vo.vid, key, [vo.optDict objectForKey:key]];
        [self toExecSql];
    }
}
- (void) saveConfig {
	DBGLog(@"tObj saveConfig: trackerName= %@",self.trackerName) ;
	
	[self confirmDb];
	
	// trackerName and maxLabel maintained in optDict by routines which set them

	[self saveToOptDict];
	
    NSMutableArray *vids = [[NSMutableArray alloc] initWithCapacity:[self.valObjTable count]];
	// put valobjs in state for saving 
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid <= 0) {
			NSInteger old = vo.vid;
			vo.vid = [self getUnique];
			[self updateVORefs:vo.vid old:old];
		}
        [vids addObject:[NSString stringWithFormat:@"%d",vo.vid]];
	}
	
    // remove previous data - input rtrk may renumber and then some vids become obsolete -- if reading rtrk have done jumpMaxPriv
    self.sql = [NSString stringWithFormat:@"delete from voConfig where priv <=%d and id not in (%@)",
                [privacyV getPrivacyValue],                 // 10.xii.2013 don't delete privacy hidden items
                [vids componentsJoinedByString:@","]];      // 18.i.2014 don't wipe all in case user quits before we finish
    
    [vids release];
    
    [self toExecSql];
    
    self.sql = @"delete from voInfo where id not in (select id from voConfig)";  // 10.xii.2013 don't delete info for hidden items
    [self toExecSql];
    
	// now save
    
	int i=0;
	for (valueObj *vo in self.valObjTable) {
        
		DBGLog(@"  vo %@  id %d", vo.valueName, vo.vid);
		self.sql = [NSString stringWithFormat:@"insert or replace into voConfig (id, rank, type, name, color, graphtype,priv) values (%d, %d, %d, '%@', %d, %d, %d);",
					vo.vid, i++, vo.vtype, [rTracker_resource toSqlStr:vo.valueName], vo.vcolor, vo.vGraphType, [[vo.optDict objectForKey:@"privacy"] intValue]];
		[self toExecSql];
		
		[self saveVoOptdict:vo];
	}
	
	self.sql = nil;
    
}

- (void) saveChoiceConfigs {  // for csv load, need to update vo optDict if vo is VOT_CHOICE
	DBGLog(@"tObj saveChoiceConfig: trackerName= %@",self.trackerName) ;
	BOOL NeedSave=NO;
	for (valueObj *vo in self.valObjTable) {
        if (VOT_CHOICE == vo.vtype) {
            NeedSave = YES;
            break;
        }
    }
    if (NeedSave)
        [self saveConfig];    
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
		DBGLog(@"tObj getValObj failed to find vid %d",qVid);
	}
	return rvo;
}

- (BOOL) loadData: (int) iDate {
	
	NSDate *qDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) iDate];
    DBGLog(@"trackerObj loadData for date %@",qDate);
	[self resetData];
	self.sql = [NSString stringWithFormat:@"select count(*) from trkrData where date = %d and minpriv <= %d;",iDate, [privacyV getPrivacyValue]];
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
        id tid;
		while ( (tid = [e1 nextObject]) != nil) {	
            vid = (NSInteger) [tid intValue];
            NSString *newVal = (NSString *) [e3 nextObject];  // read csv may gen bad id, keep enumerators even
			valueObj *vo = [self getValObj:vid];
			//dbgNSAssert1(vo,@"tObj loadData no valObj with vid %d",vid);
			if (vo) { // no vo if privacy restricted
                DBGLog(@"vo id %d newValue: %@",vid,newVal);
                
                if ((VOT_CHOICE == vo.vtype) || (VOT_SLIDER == vo.vtype)) {
                    vo.useVO = ([@"" isEqualToString:newVal] ? NO : YES);   // enableVO disableVO
                } else {
                    vo.useVO = YES;
                }
				[vo.value setString:newVal];  // results not saved for func so not in db table to be read
				//vo.retrievedData = YES;
			}
		}
		
		[i1 release];
		[s1 release];
		self.sql = nil;
		
		return YES;
	} else {
		DBGLog(@"tObj loadData: nothing for date %d %@", iDate, qDate);
		return NO;
	}
}


- (void) saveData {

	if (self.trackerDate == nil) {
		trackerDate = [[NSDate alloc] init];
	}
	
	DBGLog(@" tObj saveData %@ date %@",self.trackerName, self.trackerDate);

	BOOL haveData=NO;
	int tdi = (int) [self.trackerDate timeIntervalSince1970];  // scary! added (int) cast 6.ii.2013 !!!
	NSInteger minPriv=BIGPRIV;
    
	for (valueObj *vo in self.valObjTable) {
		
		dbgNSAssert((vo.vid >= 0),@"tObj saveData vo.vid <= 0");
		//if (vo.vtype != VOT_FUNC) { // no fn results data kept
        DBGLog(@"  vo %@  id %d val %@", vo.valueName, vo.vid, vo.value);
        if ([vo.value isEqualToString:@""]) {
            self.sql = [NSString stringWithFormat:@"delete from voData where id = %d and date = %d;",vo.vid, tdi];
        } else {
            haveData = YES;
            minPriv = MIN(vo.vpriv,minPriv);
            self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d, %d,'%@');",
                        vo.vid, tdi, [rTracker_resource toSqlStr:vo.value]];
        }
        [self toExecSql];
                        
		//} 
	}
	
	if (haveData) {
		self.sql = [NSString stringWithFormat:@"insert or replace into trkrData (date,minpriv) values (%d,%d);", tdi,minPriv];
		[self toExecSql];
	} else {
		self.sql = [NSString stringWithFormat:@"select count(*) from voData where date=%d;",tdi];
		int r = [self toQry2Int];
		if (r==0) {
			self.sql = [NSString stringWithFormat:@"delete from trkrData where date=%d;",tdi];
			[self toExecSql];
		}
	}

    // cleanup empty values added 28 jan 2014
    self.sql = @"select count(*) from voData where val=''";
    int ndc = [self toQry2Int];
    if (0<ndc) {
        DBGWarn(@"deleting %d empty values from tracker %d",ndc,self.toid);
        self.sql = @"delete from voData where val=''";
        [self toExecSql];
    }
    
	self.sql = nil;
}

#pragma mark -
#pragma write tracker as rtrk or plist+csv for iTunes

- (NSString*) getPath:(NSString*)extension {
    NSString *fpatho = [rTracker_resource ioFilePath:@"outbox" access:NO];
    [[NSFileManager defaultManager] createDirectoryAtPath:fpatho withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *fname = [self.trackerName stringByAppendingString:extension];
    NSString *fpath = [fpatho stringByAppendingPathComponent:fname];
    return fpath;
}

- (NSString*) csvPath {
    return [self getPath:@".csv"];
}

- (NSString*) rtrkPath {
    return [self getPath:@".rtrk"];
}

- (BOOL) writeCSV {
    BOOL result=YES;
	NSString *fpath = [self getPath:CSVext];
	[[NSFileManager defaultManager] createFileAtPath:fpath contents:nil attributes:nil];
	NSFileHandle *nsfh = [NSFileHandle fileHandleForWritingAtPath:fpath];
	[self writeTrackerCSV:nsfh];
	[nsfh closeFile];
    
    return result;
}

- (BOOL) writeRtrk:(BOOL)withData {
    BOOL result=YES;
    //NSDictionary *rtrk = [self genRtrk:withData];
    
    NSMutableDictionary *tData = [[NSMutableDictionary alloc] init];
    
    if (withData) {
        // save current trackerDate (NSDate->int)
        int currDate = (int) [self.trackerDate timeIntervalSince1970];
        int nextDate = [self firstDate];
        
        float ndx = 1.0;
        float all = [self getDateCount];
        
        do {
            [self loadData:nextDate];
            NSMutableDictionary *vData = [[NSMutableDictionary alloc] init];
            for (valueObj *vo in self.valObjTable) {
                [vData setValue:vo.value forKey:[NSString stringWithFormat:@"%d",vo.vid]];
                //DBGLog(@"genRtrk data: %@ for %@",vo.value,[NSString stringWithFormat:@"%d",vo.vid]);
            }
            [tData setObject:[[NSDictionary alloc] initWithDictionary:vData copyItems:YES] forKey:[NSString stringWithFormat:@"%d", (int) [self.trackerDate timeIntervalSinceReferenceDate]] ];
            //DBGLog(@"genRtrk vData: %@ for %@",vData,self.trackerDate);
            [vData release];    // analyzer complains but released below
            //DBGLog(@"genRtrk: tData= %@",tData);
            [rTracker_resource setProgressVal:(ndx/all)];
            ndx += 1.0;
        } while ((nextDate = [self postDate]));    // iterate through dates
        
        // restore current date
        [self loadData:currDate];
        
    }
    // configDict not optional -- always need tid for load of data
    NSDictionary *rtrkDict = [NSDictionary dictionaryWithObjectsAndKeys:   // think this does not need release as is not alloc'd?
                              [NSString stringWithFormat:@"%d",self.toid],@"tid",     // changed from 'toid' key 10 july
                              self.trackerName,@"trackerName",
                              [self dictFromTO],@"configDict",
                              tData,@"dataDict",
                              //[[NSDictionary alloc] initWithDictionary:tData copyItems:YES],@"dataDict",
                              nil];
    
    
    NSString *fp = [self getPath:RTRKext];
    if(! ([rtrkDict writeToFile:fp atomically:YES])) {
        DBGErr(@"problem writing file %@",fp);
        result=NO;
    }
    
    for (NSString *k in tData) {
        NSDictionary *vData = [tData objectForKey:k];
        [vData release];
    }

    [tData release];
    // rtrkDict sub-dictionaries not alloc'd so autoreleased

    return result;
}


- (BOOL) saveToItunes {
    BOOL result=YES;
    NSString *fname = [NSString stringWithFormat:@"%@_out.csv",self.trackerName];
    
	NSString *fpath = [rTracker_resource ioFilePath:fname access:YES];
	[[NSFileManager defaultManager] createFileAtPath:fpath contents:nil attributes:nil];
	NSFileHandle *nsfh = [NSFileHandle fileHandleForWritingAtPath:fpath];
	
	//[nsfh writeData:[@"hello, world." dataUsingEncoding:NSUTF8StringEncoding]];
    
	[self writeTrackerCSV:nsfh];
	[nsfh closeFile];
    
    
    fname = [NSString stringWithFormat:@"%@_out.plist",self.trackerName];
    fpath = [rTracker_resource ioFilePath:fname access:YES];
    if (! ([[self dictFromTO] writeToFile:fpath atomically:YES])) {
        DBGErr(@"problem writing file %@",fname);
        result=NO;
    }
    
	//[nsfh release];
    return result;
}

- (NSDictionary*) dictFromTO {
    NSMutableArray *vodma = [[NSMutableArray alloc] init];
	for (valueObj *vo in self.valObjTable) {
        [vodma addObject:[vo dictFromVO]];
	}
    NSArray *voda = [NSArray arrayWithArray:vodma];
    [vodma release];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:self.toid],@"tid",
            self.optDict, @"optDict",
            voda,@"valObjTable",
            nil];
    
}

// import data for a tracker -- direct in db so privacy not observed
- (void) loadDataDict:(NSDictionary*)dataDict {
    NSString *dateIntStr;
    [rTracker_resource stashProgressBarMax:[dataDict count]];
    
    for (dateIntStr in dataDict) {
        NSDate *tdate= [NSDate dateWithTimeIntervalSinceReferenceDate:[dateIntStr doubleValue]];
        int tdi = [tdate timeIntervalSince1970];
        NSDictionary *vdata = [dataDict objectForKey:dateIntStr];
        NSString *vids;
        int mp = BIGPRIV;
        for (vids in vdata) {
            NSInteger vid = [vids integerValue];
            valueObj *vo = [self getValObj:vid];
            //NSString *val = [vo.vos mapCsv2Value:[vdata objectForKey:vids]];
            NSString *val = [vdata objectForKey:vids];
            self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d,%d,'%@');",
                        vid,tdi,[rTracker_resource toSqlStr:val]];
            [self toExecSql];
            
            if (vo.vpriv < mp) {
                mp = vo.vpriv;
            }
        }
        self.sql = [NSString stringWithFormat:@"insert or replace into trkrData (date, minpriv) values (%d,%d);",tdi,mp];
        [self toExecSql];
        [rTracker_resource bumpProgressBar];
    }
}

/*
 - (void) rcvRtrk:(NSDictionary *)rTrk {
 rtm working here -- this needs to be in rvc, merge with load plist files
 }
 */

#pragma mark -
#pragma mark read & write tracker data as csv

- (NSString*) csvSafe:(NSString*)instr {
    //instr = [instr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    instr = [instr stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"];
    instr = [instr stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    instr = [NSString stringWithFormat:@"\"%@\"",instr];
    if ([@"\"(null)\"" isEqualToString:instr]) {
        instr = @"\"\"";
    }
    return instr;
}


- (NSDateFormatter*) dateFormatter {
    if (nil == dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];  
    }
    return dateFormatter;
}

- (NSDateFormatter*) dateOnlyFormatter {
    if (nil == dateOnlyFormatter) {
        dateOnlyFormatter = [[NSDateFormatter alloc] init];
        [dateOnlyFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateOnlyFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    return dateOnlyFormatter;
}

- (NSDate*) strToDate:(NSString*)str {
        
    return [self.dateFormatter dateFromString:str];
        
}

- (NSDate*) strToDateOnly:(NSString*)str {
    
    return [self.dateOnlyFormatter dateFromString:str];
    
}

- (NSString*) dateToStr:(NSDate*)dat {
    
    return [self.dateFormatter stringFromDate:dat ];
    
}

- (int) getDateCount {
    self.sql = [NSString stringWithFormat:@"select count(*) from trkrData where minpriv <= %d;",[privacyV getPrivacyValue]];
    int rv = [self toQry2Int];
    self.sql = nil;
    return rv;
}

- (void) writeTrackerCSV:(NSFileHandle*)nsfh {
	
	//[nsfh writeData:[self.trackerName dataUsingEncoding:NSUTF8StringEncoding]];

    // write column titles
	
    NSString *outString= [NSString stringWithFormat:@"\"%@\"",TIMESTAMP_LABEL];
	for (valueObj *vo in self.valObjTable) {
		dbgNSAssert((vo.vid >= 0),@"tObj writeTrackerCSV vo.vid <= 0");
        //DBGLog(@"wtxls:  vo %@  id %d val %@", vo.valueName, vo.vid, vo.value);
        //[nsfh writeData:[vo.valueName dataUsingEncoding:NSUnicodeStringEncoding]];
        outString = [outString stringByAppendingFormat:@",%@",[self csvSafe:vo.valueName]];
	}
    outString = [outString stringByAppendingString:@"\n"];
    [nsfh writeData:[outString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if ([rTracker_resource getRtcsvOutput]){
        outString = @"";
        for (valueObj *vo in self.valObjTable) {
            NSString *voStr = [NSString stringWithFormat:@"%@:%@:%d",[self.votArray objectAtIndex:vo.vtype],[[rTracker_resource colorNames] objectAtIndex:vo.vcolor],vo.vid];
            outString = [outString stringByAppendingFormat:@",%@",[self csvSafe:voStr]];
        }
        outString = [outString stringByAppendingString:@"\n"];
        [nsfh writeData:[outString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    // save current trackerDate (NSDate->int)
    int currDate = (int) [self.trackerDate timeIntervalSince1970];
    int nextDate = [self firstDate];
    
    float ndx = 1.0;
    float all = [self getDateCount];
    
    do {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self loadData:nextDate];
        // write data - each vo gets routine to write itself -- function results too
        outString = [NSString stringWithFormat:@"\"%@\"",[self dateToStr:self.trackerDate]];
        for (valueObj *vo in self.valObjTable) {
            outString = [outString stringByAppendingString:@","];
            //if (VOT_CHOICE == vo.vtype) {
                outString = [outString stringByAppendingString:[self csvSafe:vo.csvValue]];
            //} else {
                //outString = [outString stringByAppendingString:[self csvSafe:vo.value]];
            //}
        }
        outString = [outString stringByAppendingString:@"\n"];
        [nsfh writeData:[outString dataUsingEncoding:NSUTF8StringEncoding]];
        [rTracker_resource setProgressVal:(ndx/all)];
        ndx += 1.0;
        [pool drain];
    } while ((nextDate = [self postDate]));    // iterate through dates
    
    // restore current date
	[self loadData:currDate];
}

#pragma mark -
#pragma mark read in from export

- (void)receiveRecord:(NSDictionary *)aRecord
{
    NSString *tsStr = [aRecord objectForKey:TIMESTAMP_KEY];
    if (nil == tsStr) {
        self.csvReadFlags |= CSVNOTIMESTAMP;
        return;
    }
    
    NSDate *ts=nil;
    int its=0;
    
    if (! [@"" isEqualToString:tsStr]) {
        ts = [self strToDate:tsStr];
        if (nil == ts) {  // try without time spec
            ts = [self strToDateOnly:[aRecord objectForKey:TIMESTAMP_KEY]];
        }
        if (nil == ts) {
            self.csvReadFlags |= CSVNOREADDATE;
            if (nil == self.csvProblem) {
                self.csvProblem = tsStr;
            }
            DBGLog(@"failed reading timestamp %@",tsStr);
            return;
        }
        self.trackerDate = ts;
        DBGLog(@"ts str: %@   ts read: %@",[aRecord objectForKey:TIMESTAMP_KEY],ts);
        its = [ts timeIntervalSince1970];
    }
    
    int mp = BIGPRIV;
	for (NSString *key in aRecord)   // need min used privacy this record, collect ids
	{
        DBGLog(@"processing csv record: key= %@ value= %@", key, [aRecord objectForKey:key]);
        if (! [key isEqualToString:TIMESTAMP_KEY]) { // not timestamp
            
            NSRange splitPos = [key rangeOfString:@":" options:NSBackwardsSearch];
            NSString *voName = [key substringToIndex:splitPos.location];
            NSInteger voRank = [[key substringFromIndex:(splitPos.location+splitPos.length)] integerValue];
            
            self.sql = [NSString stringWithFormat:@"select id, priv, type from voConfig where name='%@';",[rTracker_resource toSqlStr:voName]];
            int valobjID,valobjPriv,valobjType;
            [self toQry2IntIntInt:&valobjID i2:&valobjPriv i3:&valobjType];
            DBGLog(@"name=%@ rank=%d val=%@ id=%d priv=%d type=%d",voName,voRank,[aRecord objectForKey:key], valobjID,valobjPriv,valobjType);
            
            BOOL configuredValObj=NO;
            if (!its) { // no timestamp for tracker config data
                // voType : color : vid
                NSArray *valComponents = [(NSString*)[aRecord objectForKey:key] componentsSeparatedByString:@":"];
                int c = [valComponents count];
                int inVid=0;
                if (c>2) {
                    inVid = [[valComponents objectAtIndex:2] integerValue];
                }
                
                if ((0 == valobjID) || (inVid == valobjID))  {  // no vo exists with this name or we match the specified ID
                    valobjID = [self createVOinDb:voName inVid:inVid];
                    DBGLog(@"created new / updated valObj with id=%d",valobjID);
                    self.csvReadFlags |= CSVCREATEDVO;
                    
                    configuredValObj = [self configVOinDb:valobjID vots:[valComponents objectAtIndex:0] vocs:(c>1 ? [valComponents objectAtIndex:1]:nil) rank:voRank];
                    if (configuredValObj)
                        self.csvReadFlags |= CSVCONFIGVO;
                    
                    valueObj *vo = [[valueObj alloc] initFromDB:self in_vid:valobjID ];
                    [self.valObjTable addObject:(id) vo];
                    [vo release];
                }
            }
            //[idDict setObject:[NSNumber numberWithInt:valobjID] forKey:key];
            
            if (!configuredValObj) {
                NSString *val2Store = [rTracker_resource toSqlStr:[aRecord objectForKey:key]];
                
                if (![@"" isEqualToString:val2Store]) {  // could still be config data, timestamp not needed
                    if ((VOT_CHOICE == valobjType)
                        || (VOT_BOOLEAN == valobjType)
                    ) {
                        valueObj *vo = [self getValObj:valobjID];
                        val2Store = [vo.vos mapCsv2Value:val2Store];  // updates dict val for bool; for choice maps to choice number, adds choice to dict if needed
                        [self saveVoOptdict:vo];
                    }
                }
                if (its) { // if have date - then not config data
                    if ([@"" isEqualToString:val2Store]) {
                        self.sql = [NSString stringWithFormat:@"delete from voData where id=%d and date=%d",valobjID,its];  // added jan 2014
                    } else {
                        if (valobjPriv < mp)
                            mp = valobjPriv;   // only fields with data
                        self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d,%d,'%@');",valobjID,its,val2Store];
                    }
                    [self toExecSql];
                
                    self.csvReadFlags |= CSVLOADRECORD;
                }
            }
        }
    }
    
    /*  replacing data for this date, minpriv is what we saw...
     
    self.sql = [NSString stringWithFormat:@"select minpriv from trkrData where date = %d;",its];
    int currMinPriv = [self toQry2Int];
    
    if (0 == currMinPriv) { // so minpriv starts at 1, else don't know if this is minpriv or not found
        // assume not found, new entry minpriv is mp for this record
    } else if (currMinPriv < mp) {
        mp = currMinPriv;   // data already present and < mp
    }
    // default mp < currMinPriv
    */
    
    if (its) {
        self.sql = [NSString stringWithFormat:@"insert or replace into trkrData (date, minpriv) values (%d,%d);",its,mp];
        [self toExecSql];
    }
    
    [rTracker_resource bumpProgressBar];
}


/* first try...
 
- (void)receiveRecord:(NSDictionary *)aRecord
{
    
    NSDate *ts = [self strToDate:[aRecord objectForKey:TIMESTAMP_LABEL]];
    if (nil == ts) {
        for (NSString *key in aRecord)
        {
            DBGLog(@"key= %@  value=%@",key,[aRecord objectForKey:key]);
        }
        DBGErr(@"skipping record as failed reading %@ key",TIMESTAMP_LABEL);
        return;
    } else {
        DBGLog(@"ts str: %@   ts read: %@",[aRecord objectForKey:TIMESTAMP_LABEL],ts);
    }
    
    NSMutableDictionary *idDict = [[NSMutableDictionary alloc] init];
    // NSMutableDictionary *typDict = [[NSMutableDictionary alloc] init];
    
    int mp = BIGPRIV;
	for (NSString *key in aRecord)   // need min used privacy this record, collect ids
	{
        DBGLog(@"pass1 key= %@", key);
        if ((! [key isEqualToString:TIMESTAMP_LABEL]) // not timestamp 
             && (![@"" isEqualToString:[aRecord objectForKey:key]]) ) {   // only fields with data
            
            //self.sql = [NSString stringWithFormat:@"select id, priv from voConfig where name='%@';",key];
            //int valobjID,valobjPriv;
            //[self toQry2IntInt:&valobjID i2:&valobjPriv];
            //DBGLog(@"name=%@ val=%@ id=%d priv=%d",key,[aRecord objectForKey:key], valobjID,valobjPriv);

            self.sql = [NSString stringWithFormat:@"select id, priv, type from voConfig where name='%@';",key];
            int valobjID,valobjPriv,valobjTyp;
            [self toQry2IntIntInt:&valobjID i2:&valobjPriv i3:&valobjTyp];
            DBGLog(@"name=%@ val=%@ id=%d priv=%d typ=%d",key,[aRecord objectForKey:key], valobjID,valobjPriv,valobjTyp);
            
            [idDict setObject:[NSNumber numberWithInt:valobjID] forKey:key];
            //[typDict setObject:[NSNumber numberWithInt:valobjTyp] forKey:key];
            if (valobjPriv < mp)
                mp = valobjPriv;
        }
    }
    
    
    int its = [ts timeIntervalSince1970];
    //NSNumber *vtf = [NSNumber numberWithInt:VOT_FUNC];
    
	for (NSString *key in aRecord)
	{
        DBGLog(@"pass2 key= %@", key);
        if ((! [key isEqualToString:TIMESTAMP_LABEL]) //{ // not timestamp 
            // && ( ! ((nil != [typDict objectForKey:key]) && [vtf isEqualToNumber:[typDict objectForKey:key]]))  // ignore calculated function value 
            ) { 
            //&& (nil != [aRecord objectForKey:key])) {    // accept fields without data if updating

            // update value data
            self.sql = [NSString stringWithFormat:@"insert or replace into voData (id, date, val) values (%d,%d,'%@');",
                        [[idDict objectForKey:key] intValue],its,[rTracker_resource toSqlStr:[aRecord objectForKey:key]]];
            [self toExecSql];
            
            // update trkrData - date easy, need minpriv
            self.sql = [NSString stringWithFormat:@"select minpriv from trkrData where date = %d;",its];
            int currMinPriv = [self toQry2Int];
            
            if (0 == currMinPriv) { // so minpriv starts at 1, else don't know if this is minpriv or not found
                // assume not found, new entry minpriv is mp for this record
            } else if (currMinPriv < mp) {
                mp = currMinPriv;   // data already present and < mp
            }
            // default mp < currMinPriv
            
            self.sql = [NSString stringWithFormat:@"insert or replace into trkrData (date, minpriv) values (%d,%d);",its,mp];  
            [self toExecSql];
            
           // self.sql = [NSString stringWithFormat:@"select date from trkrData where minpriv <= %d order by date desc limit 1;",(int) [privacyV getPrivacyValue]];
           // int rslt= (NSInteger) [self toQry2Int];
            
        }
        
	}
    [idDict release];
    //[typDict release];
    
}
*/


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

- (void) rescanMaxLabel {

	CGSize lsize = { 0.0f, 0.0f };
	
	//NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in self.valObjTable) {
		CGSize tsize = [vo.valueName sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
        //DBGLog(@"rescanMaxLabel: name= %@ w=%f  h= %f",vo.valueName,tsize.width,tsize.height);
		if (tsize.width > lsize.width) {
			lsize = tsize;
            // bug in xcode 4.2
            if (lsize.width == lsize.height) {
                lsize.height = 18.0f;
            }
        }
	}
	
	DBGLog(@"maxLabel set: width %f  height %f",lsize.width, lsize.height);
	//[self.optDict setObject:[NSNumber numberWithFloat:lsize.width] forKey:@"width"];
	//[self.optDict setObject:[NSNumber numberWithFloat:lsize.height] forKey:@"height"];
	
	self.maxLabel = lsize;
}


- (void) addValObj:(valueObj *) valObj {
	DBGLog(@"addValObj to %@ id= %d : adding _%@_ id= %d, total items now %d",self.trackerName,toid, valObj.valueName, valObj.vid, [self.valObjTable count]);
	
	// check if toid already exists, then update
	if (! [self updateValObj: valObj]) {
		[self.valObjTable addObject:valObj];
	}
	
	[self rescanMaxLabel];
}


- (void) deleteTrackerDB {
	[self deleteTDb];
}

- (void) deleteTrackerRecordsOnly {
    self.sql = @"delete from trkrData;";
    [self toExecSql];
    self.sql = @"delete from voData;";
    [self toExecSql];
	self.sql = nil;
}

- (void) deleteCurrEntry {
    int eDate = (int) [self.trackerDate timeIntervalSince1970];
	self.sql = [NSString stringWithFormat:@"delete from trkrData where date = %d;", eDate];
	[self toExecSql];
	self.sql = [NSString stringWithFormat:@"delete from voData where date = %d;", eDate];
	[self toExecSql];
    
	self.sql = nil;
}

#pragma mark -
#pragma mark query tracker methods

- (NSInteger) dateNearest:(int)targ {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where date <= %d and minpriv <= %d order by date desc limit 1;", 
                targ, (int) [privacyV getPrivacyValue] ];
	int rslt= [self toQry2Int];
    if (0 == rslt) {
        self.sql = [NSString stringWithFormat:@"select date from trkrData where date > %d and minpriv <= %d order by date desc limit 1;", 
                    targ, (int) [privacyV getPrivacyValue] ];
        rslt= [self toQry2Int];

    }
	self.sql = nil;
	return rslt;
}

- (int) prevDate {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where date < %d and minpriv <= %d order by date desc limit 1;", 
		   (int) [self.trackerDate timeIntervalSince1970], (int) [privacyV getPrivacyValue] ];
	int rslt= [self toQry2Int];
	self.sql = nil;
	return rslt;
}

- (int) postDate {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where date > %d and minpriv <= %d order by date asc limit 1;", 
                (int) [self.trackerDate timeIntervalSince1970],(int) [privacyV getPrivacyValue]  ];
	int rslt= (NSInteger) [self toQry2Int];
	self.sql = nil;
	return rslt;
}

- (int) lastDate {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where minpriv <= %d order by date desc limit 1;",(int) [privacyV getPrivacyValue]];
	int rslt= (NSInteger) [self toQry2Int];
	self.sql = nil;
	return rslt;
}

- (int) firstDate {
	self.sql = [NSString stringWithFormat:@"select date from trkrData where minpriv <= %d order by date asc limit 1;",(int) [privacyV getPrivacyValue]];
	int rslt= (NSInteger) [self toQry2Int];
	self.sql = nil;
	return rslt;
}


- (NSString*) voGetNameForVID:(NSInteger)vid {
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid == vid)
			return vo.valueName;
	}
	DBGLog(@"voGetNameForVID %d failed", vid);
	//return [NSString stringWithFormat:@"vid %d not found",vid];
    return @"not configured yet";
}

/*  precludes musltiple vo with same name
- (NSInteger) voGetVIDforName:(NSString *)vname {
	for (valueObj *vo in self.valObjTable) {
		if ([vo.valueName isEqualToString:vname])
			return vo.vid;
	}
	DBGLog(@"voGetVIDNameForName failed for name %@",vname);
	//return [NSString stringWithFormat:@"vid %d not found",vid];
    return 0;
}<#(NSUInteger)#>
*/

- (void) updateVIDinFns:(NSInteger)old new:(NSInteger)new {
    NSString *oldstr = [NSString stringWithFormat:@"%d",old];
    NSString *newstr = [NSString stringWithFormat:@"%d",new];
    for (valueObj *vo in self.valObjTable) {
		if (VOT_FUNC == vo.vtype) {
            NSString *fnstr = [vo.optDict objectForKey:@"func"];
            
            NSMutableArray *fMarray = [NSMutableArray arrayWithArray:[fnstr componentsSeparatedByString:@" "]];
            NSInteger i,c;
            c = [fMarray count];
            for (i=0;i<c;i++) {
                if ([oldstr isEqualToString:[fMarray objectAtIndex:i]]) {
                    [fMarray replaceObjectAtIndex:i withObject:newstr];
               }
            }
            fnstr = [fMarray componentsJoinedByString:@" "];
            [vo.optDict setObject:fnstr forKey:@"func"];

            
            self.sql = [NSString stringWithFormat:@"update voInfo set val='%@' where id=%d and field='func'",fnstr,vo.vid]; // keep consistent
            [self toExecSql];
            
        }

	}
    
}

- (BOOL) voVIDisUsed:(NSInteger)vid {
	for (valueObj *vo in self.valObjTable) {
		if (vo.vid == vid)
			return YES;
	}
    return NO;
}


- (void) voUpdateVID:(valueObj*)vo newVID:(NSInteger)newVID {
    
    if (vo.vid == newVID) return;
    
    for (valueObj *tvo in self.valObjTable) {
		if (tvo.vid == newVID) {
            [self voUpdateVID:tvo newVID:[self getUnique]];
        }
    }

    // need to update at least voData, will write voInfo, voConfing out later but lets stay consistent
    self.sql= [NSString stringWithFormat: @"update voData set id=%d where id=%d", newVID, vo.vid];
    [self toExecSql];
    self.sql= [NSString stringWithFormat: @"update voInfo set id=%d where id=%d", newVID, vo.vid];
    [self toExecSql];
    self.sql= [NSString stringWithFormat: @"update voConfig set id=%d where id=%d", newVID, vo.vid];
    [self toExecSql];

    self.sql = nil;
    
    
    [self updateVIDinFns:vo.vid new:newVID];
    DBGLog(@"changed %d to %d",vo.vid,newVID);
    vo.vid = newVID;
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

- (int) countEntries {
	self.sql = @"select count(*) from trkrData;";
	int r = [self toQry2Int];
	self.sql = nil;
	return (r);
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

#pragma mark value data updated event handling

// handle rtValueUpdatedNotification
// sends rtTrackerUpdatedNotification

- (void) trackerUpdated:(NSNotification*)n {
#if DEBUGLOG        
	id obj = [n object];
	if ([obj isMemberOfClass:[valueObj class]]) {
		valueObj *vo = (valueObj*) [n object];
		DBGLog(@"trackerObj %@ updated by vo %d : %@ => %@",self.trackerName,vo.vid,vo.valueName, vo.value);
	
	} else {
		voState *vos= (voState*) obj;
		DBGLog(@"trackerObj %@ updated by vo (voState)  %d : %@ => %@",self.trackerName,vos.vo.vid,vos.vo.valueName, vos.vo.value);
	}
#endif
    
	[[NSNotificationCenter defaultCenter] postNotificationName:rtTrackerUpdatedNotification object:self];
}

#pragma mark -
#pragma mark manipulate tracker's valObjs

- (valueObj *) copyVoConfig: (valueObj *) srcVO {
	DBGLog(@"copyVoConfig: to= id %d %@ input vid=%d %@", self.toid, self.trackerName, srcVO.vid,srcVO.valueName);
	
	valueObj *newVO = [[valueObj alloc] init];
	newVO.vid = [self getUnique];
	newVO.parentTracker = srcVO.parentTracker;
	newVO.vtype = srcVO.vtype;
	newVO.valueName = [NSString stringWithString:srcVO.valueName];
	//newVO.valueName = [[NSString alloc] initWithString:srcVO.valueName];  
	//[newVO.valueName release];
    
    NSString *key;
    for (key in srcVO.optDict) {
        [newVO.optDict setObject:[srcVO.optDict objectForKey:key] forKey:key];
    }
	
	return newVO;
}

#pragma mark -
#pragma mark utility methods

- (void) describe {
	DBGLog(@"tracker id %d name %@ dbName %@", self.toid, self.trackerName, self.dbName);
    DBGLog(@"db ver %@ fn ver %@ created by rt ver %@ build %@",
           [self.optDict objectForKey:@"rtdb_version"],[self.optDict objectForKey:@"rtfn_version"],
           [self.optDict objectForKey:@"rt_version"],[self.optDict objectForKey:@"rt_build"]
           );
	//NSEnumerator *enumer = [self.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in self.valObjTable) {
		[vo describe:false];
	}
    

}

- (void) recalculateFns {
	DBGLog(@"tracker id %d name %@ dbname %@ recalculateFns", self.toid, self.trackerName, self.dbName);
    
	for (valueObj *vo in self.valObjTable) {
        if (self.goRecalculate && (VOT_FUNC == vo.vtype)) {
            [rTracker_resource setProgressVal:0.0f];
            [vo.vos recalculate];
        }
	}
    
    if (self.goRecalculate) {
        [self.optDict removeObjectForKey:@"dirtyFns"];
        self.sql = @"delete from trkrInfo where field='dirtyFns';";
        [self toExecSql];
        self.sql = nil;
        
        self.goRecalculate = NO;
    }
    
}

- (NSInteger) nextColor
{
	NSInteger rv = nextColor;
	if (++nextColor >= [[rTracker_resource colorSet] count])
		nextColor=0;
	return rv;
}

/*
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
*/

// TODO: dump plist, votArray could be encoded as colorSet above (?)

- (NSArray *) votArray {
	if (votArray == nil) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath= [bundle pathForResource:@"rt-types" ofType:@"plist"];
		votArray = [[NSArray alloc] initWithContentsOfFile:plistPath]; 

	}
	
	return votArray;
}

- (void) setTOGD:(CGRect)inRect {  // note TOGD not Togd -- so self.togd still automatically retained/released
    id ttogd = [[togd alloc] initWithData:self rect:inRect];
    self.togd = ttogd;
    [ttogd release];
    [self.togd fillVOGDs];
    //[self.togd release];  // rtm 05 feb 2012 +1 alloc, +1 self.togd retain
}

- (int) getPrivacyValue {
    return [[self.optDict objectForKey:@"privacy"] intValue];
}

@end
