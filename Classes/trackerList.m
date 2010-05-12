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
@synthesize tObj;

#pragma mark -
#pragma mark Local Utilities


#pragma mark -
#pragma mark object core 

- (id) init {
	NSLog(@"init trackerList");
	
	dbName=@"topLevel.sqlite3";
	
	if (self = [super init]) {
		/*
		UIApplication *app = [UIApplication sharedApplication];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillTerminate:) 
													 name:UIApplicationWillTerminateNotification
												   object:app];
		 */
		topLayoutTable = [[NSMutableArray alloc] init];

		[self getTDb];
		//NSString *createTLTable = @"create table if not exists toplevel (rank integer primary key, name text);";
		sql = @"create table if not exists toplevel (rank integer, name text);";
		[self toExecSql];

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
	sql = @"select name from toplevel order by rank;";
	[self toQry2Ary :self.topLayoutTable];
	sql = nil;
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

	sql = [[NSString alloc] initWithFormat: @"insert or replace into toplevel (rank, name) values (%i, \"%@\");",rank,name ];
	[self toExecSql];
	[sql release];
	sql = nil;
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
	int nrank=0;
	for (NSString *tracker in topLayoutTable) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		sql = [[NSString alloc] initWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		[sql release];
		nrank++;
	}
}

- (void) reloadFromTLT {
	int nrank=0;
	sql = @"delete from toplevel;";
	[self toExecSql];
	for (NSString *tracker in topLayoutTable) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		sql = [[NSString alloc] initWithFormat: @"insert into toplevel (rank, name) values (%i, \"%@\");",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		[sql release];  // this seems quite gross...
		nrank++;
		}
}


/*
#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"trackerList: notified app will terminate");
	
	//[topLayoutTable release];  // do this here or is it too early?
}
*/

@end
