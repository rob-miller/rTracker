//
//  trackerList.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "trackerList.h"

@implementation trackerList

@synthesize topLayoutNames, topLayoutIDs;
//@synthesize tObj;

/******************************
 *
 * trackerList db tables
 *
 *   toplevel: rank(int) ; id(int) ; name(text)
 *      primarily for entry listbox of tracker names
 *
 ******************************/ 

#pragma mark -
#pragma mark core object methods and support

- (void) initTDb {
	int c;
	
	NSLog(@"Initializing top level dtabase!");
	self.dbName=@"topLevel.sqlite3";
	[self getTDb];
	
	self.sql = @"create table if not exists toplevel (rank integer, id integer unique, name text);";
	[self toExecSql];
	self.sql = @"select count(*) from toplevel;";
	c = [self toQry2Int];
	NSLog(@"toplevel at open contains %d entries",c);
	
	self.sql = nil;	
}	

- (id) init {
	NSLog(@"init trackerList");
	
	if (self = [super init]) {
		topLayoutNames = [[NSMutableArray alloc] init];
		//self.topLayoutNames = [[NSMutableArray alloc] init];
		topLayoutIDs = [[NSMutableArray alloc] init];
		//self.topLayoutIDs = [[NSMutableArray alloc] init];
		[self initTDb];
	} 
	return self;
}

- (void) dealloc {
	NSLog(@"trackerlist dealloc");
	self.topLayoutNames = nil;
	[topLayoutNames release];
	self.topLayoutIDs = nil;
	[topLayoutIDs release];
	[super dealloc];
}

#pragma mark -
#pragma mark TopLayoutTable <-> db support 

- (void) loadTopLayoutTable {
	[self.topLayoutNames removeAllObjects];
	[self.topLayoutIDs removeAllObjects];

	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
	
	self.sql = @"select id, name from toplevel order by rank;";
	[self toQry2AryIS :(NSMutableArray *)self.topLayoutIDs s1: self.topLayoutNames];
	self.sql = nil;
	NSLog(@"loadTopLayoutTable finished, tlt= %@",self.topLayoutNames);
}

- (void) confirmTopLayoutEntry:(trackerObj *) tObj {
	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
	
	self.sql = [NSString stringWithFormat:@"select rank from toplevel where id=%d;",tObj.toid];
	int rank = [self toQry2Int];  // returns 0 if not found
	if (rank == 0) {
		rank = [self.topLayoutNames count] +1;  // so put at end
	}
	NSAssert(tObj.toid,@"confirmTLE: toid=0");
	self.sql = [NSString stringWithFormat: @"insert or replace into toplevel (rank, id, name) values (%i, %i, \"%@\");",
		   rank, tObj.toid, tObj.trackerName ];
	[self toExecSql];
	self.sql = nil;
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
	int nrank=0;
	for (NSString *tracker in self.topLayoutNames) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		self.sql = [NSString stringWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		nrank++;
	}
	self.sql = nil;
}

- (void) reloadFromTLT {
	int nrank=0;
	self.sql = @"delete from toplevel;";
	[self toExecSql];
	for (NSString *tracker in self.topLayoutNames) {
		NSInteger tid = [[self.topLayoutIDs objectAtIndex:nrank] intValue];

		NSLog(@" %@ id %d to rank %d",tracker,tid,nrank);
		self.sql = [NSString stringWithFormat: @"insert into toplevel (rank, id, name) values (%i, %d, \"%@\");",nrank,tid,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		self.sql = nil;
		nrank++;
	}
}

- (int) getTIDfromIndex:(NSUInteger)ndx {
	return [[self.topLayoutIDs objectAtIndex:ndx] intValue];
}

- (void) reorderTLT : (NSUInteger) fromRow toRow:(NSUInteger)toRow
{
	
	id tName = [[self.topLayoutNames objectAtIndex:fromRow] retain];
	id tID = [[self.topLayoutIDs objectAtIndex:fromRow] retain];
	
	[self.topLayoutNames removeObjectAtIndex:fromRow];
	[self.topLayoutIDs removeObjectAtIndex:fromRow];
	
	[self.topLayoutNames insertObject:tName atIndex:toRow];
	[self.topLayoutIDs insertObject:tID atIndex:toRow];
	
	[tName release];
	[tID release];
}

#pragma mark -
#pragma mark tracker manipulation methods

- (trackerObj *) toConfigCopy : (trackerObj *) srcTO {
	NSLog(@"toConfigCopy: src id= %d %@",srcTO.toid,srcTO.trackerName);
	trackerObj *newTO = [trackerObj alloc];
	newTO.toid = [self getUnique];
	newTO = [newTO init];
	
	NSString *oTN = srcTO.trackerName;
	//NSString *nTN = [[NSString alloc] initWithString:oTN];
	//newTO.trackerName = nTN;
	// release as well
	newTO.trackerName = [NSString stringWithString:oTN];
	
	//NSEnumerator *enumer = [srcTO.valObjTable objectEnumerator];
	//valueObj *vo;
	//while (vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in srcTO.valObjTable) {
		valueObj *newVO = [newTO voConfigCopy:vo];
		[newTO addValObj:newVO];
		[newVO release];
	}
	
	[newTO saveConfig];
	NSLog(@"toConfigCopy: copy id= %d %@",newTO.toid,newTO.trackerName);
	
	return newTO;
}

- (void) deleteTrackerAllRow:(NSUInteger)row
{
	int toid = [[self.topLayoutIDs objectAtIndex:row] intValue];
	trackerObj *to = [[trackerObj alloc] init:toid];
	[to deleteAllData];
	[to release];
	[self.topLayoutNames removeObjectAtIndex:row];
	[self.topLayoutIDs removeObjectAtIndex:row];
}

@end
