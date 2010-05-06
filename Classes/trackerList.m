//
//  trackerList.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "trackerList.h"



@implementation trackerList

@synthesize topLayoutTable;

#pragma mark -
#pragma mark Local Utilities


#pragma mark -
#pragma mark object core 

- (id) init {
	NSLog(@"init trackerList");
	
	if (self = [super init]) {
		/*
		UIApplication *app = [UIApplication sharedApplication];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillTerminate:) 
													 name:UIApplicationWillTerminateNotification
												   object:app];
		 */
		topLayoutTable = [[NSMutableArray alloc] init];
		
		//NSString *createTLTable = @"create table if not exists toplevel (rank integer primary key, name text);";
		NSString *createTLTable = @"create table if not exists toplevel (rank integer, name text);";
		[self toExecSql:createTLTable];

		//[self loadTopLayoutTable];
	} 
	return self;
}

- (void) dealloc {
	NSLog(@"trackerlist dealloc");
	
	[topLayoutTable release];
	[super dealloc];
}

#pragma mark -
#pragma mark External DB Access 

- (void) loadTopLayoutTable {
	[self.topLayoutTable removeAllObjects];
	NSString *qry = @"select name from toplevel order by rank;";
	[self toQry2Ary :qry inAry:self.topLayoutTable];
	NSLog(@"loadTopLayoutTable finished, tlt= %@",self.topLayoutTable);
}

- (void) addTopLayoutEntry:(int)rank name: (NSString *)name {
	int maxc = [topLayoutTable count];
	if (rank < 0) {
		NSLog(@"addTLE: rank is %d, setting to 0",rank);
		rank = 0;
	} else if (rank > maxc) {
		NSLog(@"addTLE: rank %d greater than %d, limiting", rank, maxc);
		rank = maxc;
	}
	NSString *update = [[NSString alloc]
						initWithFormat:@"insert or replace into toplevel (rank, name) values (%i, \"%@\");",rank,name];
	[self toExecSql :update];
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
	int nrank=0;
	for (NSString *tracker in topLayoutTable) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		NSString *sql = [[NSString alloc] 
						 initWithFormat:@"update toplevel set rank = %d where name = \"%@\";",nrank,tracker];
		nrank++;
		[self toExecSql:sql];  // better if used bind vars, but this keeps access in tObjBase
	}
}

#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"trackerList: notified app will terminate");
	
	//[topLayoutTable release];  // do this here or is it too early?
}

@end
