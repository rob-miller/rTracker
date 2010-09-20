//
//  trackerList.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"

#import "tObjBase.h"
#import "trackerObj.h"

@interface trackerList : tObjBase {
	
	NSMutableArray *topLayoutNames;
	//NSMutableArray *topLayoutIDs;
	//trackerObj *tObj;
	
}

@property (nonatomic,retain) NSMutableArray *topLayoutNames;
@property (nonatomic,retain) NSMutableArray *topLayoutIDs;
//@property (nonatomic,retain) trackerObj *tObj;

- (id) init;
- (void) dealloc;

- (void)loadTopLayoutTable;
- (void)confirmTopLayoutEntry:(trackerObj *)tObj;
- (void)reorderFromTLT;
- (void)reloadFromTLT;

- (int) getTIDfromIndex:(NSUInteger)ndx;
- (trackerObj *) toConfigCopy : (trackerObj *) srcTO;

- (void) deleteTrackerAllRow : (NSUInteger) row;
- (void) reorderTLT : (NSUInteger) fromRow toRow:(NSUInteger)toRow;


@end
