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
	
	NSMutableArray *topLayoutTable;
	trackerObj *tObj;
	
}

@property (nonatomic,retain) NSMutableArray *topLayoutTable;
@property (nonatomic,retain) trackerObj *tObj;

- (id) init;
- (void) dealloc;

- (void)loadTopLayoutTable;
- (void)addTopLayoutEntry:(int)rank name:(NSString *)name;
- (void)reorderFromTLT;
- (void)reloadFromTLT;



@end
