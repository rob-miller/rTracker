//
//  trackerList.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "/usr/include/sqlite3.h"
#import <sqlite3.h>

#import "tObjBase.h"
#import "trackerObj.h"

@interface trackerList : tObjBase
/*{
	
	NSMutableArray *topLayoutNames;
	NSMutableArray *topLayoutIDs;
	NSMutableArray *topLayoutPriv;
    NSMutableArray *topLayoutReminderCount;
	//trackerObj *tObj;
	
}*/


@property (nonatomic,strong) NSMutableArray *topLayoutNames;
@property (nonatomic,strong) NSMutableArray *topLayoutIDs;
@property (nonatomic,strong) NSMutableArray *topLayoutPriv;
@property (nonatomic,strong) NSMutableArray *topLayoutReminderCount;
//@property (nonatomic,retain) trackerObj *tObj;

- (id) init;

- (void)loadTopLayoutTable;
- (void)confirmTopLayoutEntry:(trackerObj *)tObj;
- (void) addToTopLayoutTable:(trackerObj *)tObj;
- (void)reorderFromTLT;
- (void)reloadFromTLT;

- (NSInteger) getTIDfromIndex:(NSUInteger)ndx;
- (int) getPrivFromLoadedTID:(NSInteger)tid;

- (BOOL)checkTIDexists:(NSNumber*)tid;
- (NSInteger) getTIDfromName:(NSString*)str;
- (NSArray*) getTIDFromNameDb:(NSString*)str;

- (void) fixDictTID:(NSDictionary*)tdict;
- (void) updateTLtid:(NSInteger)old new:(NSInteger)new;
- (void) updateTID:(NSInteger)old new:(NSInteger)new;

- (trackerObj *) copyToConfig : (trackerObj *) srcTO;

- (void) deleteTrackerAllRow : (NSUInteger) row;
- (void) deleteTrackerRecordsRow : (NSUInteger) row;
- (void) reorderTLT : (NSUInteger) fromRow toRow:(NSUInteger)toRow;

//- (void) writeTListXLS:(NSFileHandle*)nsfh;
- (void) exportAll;

- (void) deConflict:(trackerObj*)newTracker;
- (void) wipeOrphans;
- (BOOL) recoverOrphans;


@end
