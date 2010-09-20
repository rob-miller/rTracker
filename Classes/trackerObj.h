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

@interface trackerObj : tObjBase {
	//int tid;
	NSString *trackerName;
	NSDate *trackerDate;
	NSMutableArray *valObjTable;
}

//@property (nonatomic) int tid;
@property (nonatomic,retain) NSString *trackerName;
@property (nonatomic,retain) NSDate *trackerDate;
@property (nonatomic,retain) NSMutableArray *valObjTable;

//+ (NSString *) makeSafeStr : (NSString *) inStr;

//- (id)init;
- (id) init:(int) tid;
//- (void) dealloc;

//- (bool) updateValObj:(valueObj *) valObj;
- (void) addValObj:(valueObj *) valObj;
- (void) saveConfig;
- (void) loadConfig;
- (BOOL) loadData: (NSInteger) iDate;
- (void) saveData;
- (void) resetData;
- (void) deleteAllData;
- (void) deleteCurrEntry;

- (NSInteger) prevDate;
- (NSInteger) postDate;

- (valueObj *) voConfigCopy: (valueObj *) srcVO;
- (valueObj *) getValObj: (NSInteger) vid;
- (void) describe;

//- (void)applicationWillTerminate:(NSNotification *)notification;


@end
