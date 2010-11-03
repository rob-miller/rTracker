//
//  trackerObj.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"

#import "tObjBase.h"
#import "valueObj.h"

// to config checkbutton default states
#define SAVERTNDFLT   YES

// to config textfield default values
// #define PRIVDFLT		0  //note: already in valObj.h


@interface trackerObj : tObjBase {
	//int tid;
	NSString *trackerName;
	NSDate *trackerDate;
	NSMutableDictionary *optDict;

	NSMutableArray *valObjTable;
	CGSize maxLabel;
	NSInteger nextColor;
	
	NSArray *colorSet;
	NSArray *votArray;
	
	UIControl *activeControl;  // ugly: track currently active text field so can scroll when keyboard shown, resign on background tap
}

//@property (nonatomic) int tid;
@property (nonatomic,retain) NSString *trackerName;
@property (nonatomic,retain) NSDate *trackerDate;
@property (nonatomic,retain) NSMutableDictionary *optDict;
@property (nonatomic,retain) NSMutableArray *valObjTable;
@property (nonatomic) CGSize maxLabel;
@property (readonly) NSInteger nextColor;
@property (nonatomic,retain) NSArray *colorSet;
@property (nonatomic,retain) NSArray *votArray;
@property (nonatomic,assign) UIControl *activeControl;

- (id) init:(int) tid;

- (void) addValObj:(valueObj*)valObj;
- (void) saveConfig;
- (void) loadConfig;
- (BOOL) loadData:(NSInteger)iDate;
- (void) saveData;
- (void) resetData;
- (void) deleteAllData;
- (void) deleteCurrEntry;

- (NSInteger) prevDate;
- (NSInteger) postDate;
- (NSInteger) lastDate;

- (valueObj *) voConfigCopy:(valueObj*)srcVO;
- (valueObj *) getValObj:(NSInteger)vid;
- (void) describe;

- (BOOL) voHasData:(NSInteger)vid;
- (BOOL) checkData;
- (BOOL) hasData;
- (NSString*) voGetNameForVID:(NSInteger)vid;

- (int) noCollideDate:(int)testDate;
- (void) changeDate:(NSDate*)newdate;

- (void) trackerUpdated:(NSNotification*)n;

//- (void)applicationWillTerminate:(NSNotification *)notification;

@end
