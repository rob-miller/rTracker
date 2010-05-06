//
//  tObjBase.m
//  rTracker
//
//  Created by Robert Miller on 29/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "tObjBase.h"


@implementation tObjBase

static sqlite3 *tDb;

+ (NSString *) trackerDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingFormat:@"rTracker.sqlite3"];
}

+ (void) getTDb {
	if (sqlite3_open([[tObjBase trackerDbFilePath] UTF8String], &tDb) != SQLITE_OK) {
		sqlite3_close(tDb);
		NSAssert(0, @"error opening rTracker database tDb");
	} else {
		NSLog(@"opened tDb");
	}
}

- (id) init {

	NSLog(@"tObjBase init");
	[tObjBase getTDb];
	
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObjBase");
	if (tDb != nil) {
		sqlite3_close(tDb);
		tDb = nil;
		NSLog(@"closed tDb");
	} else {
		NSLog(@"tDb already closed");
	}

	[super dealloc];
}

- (void) toQry2Ary : (NSString *) inQry inAry: (NSMutableArray *) inAry {
	NSLog(@"toQry2Ary: %@", inQry);
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [inQry UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			char *rslt = (char *) sqlite3_column_text(stmt, 0);
			NSString *tlentry = [[NSString alloc] initWithUTF8String:rslt];
			[inAry addObject:(id) tlentry];
			NSLog(@"  rslt: %@",tlentry);
			[tlentry release];
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", inQry, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", inQry, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"toQry2Ary done, rslt= %@",inAry);
}

- (void) toExecSql : (NSString *) sql {
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
