//
//  tObjBase.m
//  rTracker
//
//  Created by Robert Miller on 29/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "tObjBase.h"


@implementation tObjBase

@synthesize dbName;
@synthesize sql;

sqlite3 *tDb;

- (NSString *) trackerDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingFormat:dbName];
}

- (void) getTDb {
	if (sqlite3_open([[self trackerDbFilePath] UTF8String], &tDb) != SQLITE_OK) {
		sqlite3_close(tDb);
		NSAssert(0, @"error opening rTracker database tDb");
	} else {
		NSLog(@"opened tDb %@",dbName);
	}
}

- (id) init {

	NSLog(@"tObjBase init: db %@",dbName);

	//[self getTDb];
	
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObjBase: %@",dbName);
	if (tDb != nil) {
		sqlite3_close(tDb);
		tDb = nil;
		NSLog(@"closed tDb: %@", dbName);
	} else {
		NSLog(@"tDb already closed %@", dbName);
	}
	[sql release];
	[super dealloc];
}

- (void) toQry2Ary : (NSMutableArray *) inAry {
	NSLog(@"toQry2Ary: %@", sql);
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			char *rslt = (char *) sqlite3_column_text(stmt, 0);
			NSString *tlentry = [[NSString alloc] initWithUTF8String:rslt];
			[inAry addObject:(id) tlentry];
			NSLog(@"  rslt: %@",tlentry);
			[tlentry release];
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"toQry2Ary done, rslt= %@",inAry);
}

- (void) toExecSql {
	NSLog(@"toExecSql: %@", sql);
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		if (sqlite3_step(stmt) != SQLITE_DONE) {
			NSAssert2(0,@"tob error executing _%@_  : %s", sql, sqlite3_errmsg(tDb));
		}
	}
	sqlite3_finalize(stmt);
}

@end
