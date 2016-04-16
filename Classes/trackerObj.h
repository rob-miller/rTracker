/***************
 trackerObj.h
 Copyright 2010-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

//
//  trackerObj.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "tObjBase.h"
#import "valueObj.h"
#import "rTracker-constants.h"
#import "notifyReminder.h"

// to config checkbutton default states
#define SAVERTNDFLT   YES

// to config textfield default values
// #define PRIVDFLT		0  //note: already in valObj.h

// max days for graph, 0= no limit
#define GRAPHMAXDAYSDFLT 0


@interface trackerObj : tObjBase
/*
 {
	//NSInteger toid;
	NSString *trackerName;
	NSDate *trackerDate;
	NSMutableDictionary *optDict;
    
	NSMutableArray *valObjTable;
    NSMutableArray *reminders;
    NSInteger reminderNdx;
    
	CGSize maxLabel;
	NSInteger nextColor;
	
	//NSArray *colorSet;
	NSArray *votArray;
	
	UIControl *activeControl;	// ugly: track currently active text field so can scroll when keyboard shown, resign on background tap
	UIViewController *vc;		// ugly: vos may need this to present a voEdit page
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateOnlyFormatter;
    
    NSUInteger csvReadFlags;
    NSString *csvProblem;
    
    id togd;                    // tracker obj graph data
    NSInteger prevTID;
    
    BOOL goRecalculate;
    
    int changedDateFrom;
    
    NSMutableDictionary *csvHeaderDict;
}
*/
//@property (nonatomic) int tid;
@property (nonatomic,strong) NSString *trackerName;
@property (nonatomic,strong) NSDate *trackerDate;
@property (nonatomic,strong) NSMutableDictionary *optDict;
@property (nonatomic,strong) NSMutableArray *valObjTable;
@property (nonatomic,strong) NSMutableArray *reminders;
@property (nonatomic) NSInteger reminderNdx;
@property (nonatomic) CGSize maxLabel;
@property (nonatomic) NSInteger nextColor;
//@property (nonatomic,strong) NSArray *votArray;
@property (nonatomic,unsafe_unretained) UIControl *activeControl;
@property (nonatomic,unsafe_unretained) UIViewController *vc;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSDateFormatter *dateOnlyFormatter;
@property (nonatomic) NSUInteger csvReadFlags;
@property (nonatomic,strong) NSString *csvProblem;
@property (nonatomic,strong) id togd;
@property (nonatomic) NSInteger prevTID;
@property (nonatomic) BOOL goRecalculate;
@property (nonatomic) int changedDateFrom;
@property (nonatomic,strong) NSMutableDictionary *csvHeaderDict;

- (id) init:(NSInteger) tid;
- (id) initWithDict:(NSDictionary*)dict;

- (void) confirmTOdict:(NSDictionary*)dict;

- (void) addValObj:(valueObj*)valObj;
- (void) saveConfig;
- (void) saveChoiceConfigs;

- (NSDictionary*) dictFromTO;

//- (void) reloadVOtable;

- (void) loadConfig;
- (void) loadConfigFromDict:(NSDictionary*)dict;
- (void) rescanMaxLabel; 

- (void) setToOptDictDflts;
- (int) getDateCount;
- (BOOL) loadData:(NSInteger)iDate;
- (void) saveData;

- (void) saveTempTrackerData;
- (BOOL) loadTempTrackerData;
- (void) removeTempTrackerData;

- (void) resetData;
- (void) deleteTrackerDB;
- (void) deleteCurrEntry;
- (void) deleteTrackerRecordsOnly;

- (notifyReminder*) loadReminders;
- (void) reminders2db;
- (BOOL) haveNextReminder;
- (notifyReminder*) nextReminder;
- (BOOL) havePrevReminder;
- (notifyReminder*) prevReminder;
- (BOOL) haveCurrReminder;
- (notifyReminder*) currReminder;
- (void) deleteReminder;
- (void) addReminder:(notifyReminder*)newNR;
- (void) saveReminder:(notifyReminder*)saveNR;
- (void) setReminder:(notifyReminder*)nr today:(NSDate*)today gregorian:(NSCalendar*)gregorian;
- (void) setReminders;
- (void) confirmReminders;
- (int) enabledReminderCount;
- (void) clearScheduledReminders;

- (NSInteger) dateNearest:(NSInteger)targ;
- (NSInteger) prevDate;
- (NSInteger) postDate;
- (NSInteger) lastDate;
- (NSInteger) firstDate;

- (valueObj *) copyVoConfig:(valueObj*)srcVO;
- (valueObj *) getValObj:(NSInteger)vid;
- (void) describe;

- (BOOL) voHasData:(NSInteger)vid;
- (BOOL) checkData;
- (BOOL) hasData;
- (int) countEntries;
- (NSString*) voGetNameForVID:(NSInteger)vid;
- (NSInteger) voGetTypeForVID:(NSInteger)vid;

- (BOOL) voVIDisUsed:(NSInteger)vid;
- (void) voUpdateVID:(valueObj*)vo newVID:(NSInteger)newVID;

- (int) noCollideDate:(int)testDate;
- (void) changeDate:(NSDate*)newdate;

- (void) trackerUpdated:(NSNotification*)n;
- (void) recalculateFns;

- (NSString*) getPath:(NSString*)extension;
- (NSString*) rtrkPath;
- (BOOL) writeCSV;
- (BOOL) writeRtrk:(BOOL)withData;

- (BOOL) saveToItunes;
- (void) writeTrackerCSV:(NSFileHandle*)nsfh;

//- (NSDictionary *) genRtrk:(BOOL)withData;

- (void) loadDataDict:(NSDictionary*)dataDict;
@property (atomic)     int32_t recalcFnLock;

//- (void)applicationWillTerminate:(NSNotification *)notification;

- (void)receiveRecord:(NSDictionary *)aRecord;

- (void) setTOGD:(CGRect)inRect;
- (int) getPrivacyValue;


#define CSVNOTIMESTAMP (0x01<<0)
#define CSVNOREADDATE  (0x01<<1)
#define CSVCREATEDVO   (0x01<<2)
#define CSVCONFIGVO    (0x01<<3)
#define CSVLOADRECORD  (0x01<<4)

@end
