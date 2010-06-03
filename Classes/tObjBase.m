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

//sqlite3 *tDb;

- (NSString *) trackerDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingFormat:dbName];
}

- (void) getTDb {
	NSLog(@"getTDb dbName= %@",dbName);
	NSAssert(dbName, @"getTDb called with no dbName set");
	
	if (sqlite3_open([[self trackerDbFilePath] UTF8String], &tDb) != SQLITE_OK) {
		sqlite3_close(tDb);
		NSAssert(0, @"error opening rTracker database");
	} else {
		NSLog(@"opened tDb %@",dbName);
	}
}

- (id) init {

	NSLog(@"tObjBase init: db %@",dbName);
	tDb=nil;
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
	[dbName release];
	[super dealloc];
}

- (void) toQry2AryS : (NSMutableArray *) inAry {
	
	NSLog(@"toQry2AryS: sql _%@_",sql);
	NSAssert(tDb,@"toQry2AryS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			char *rslts = (char *) sqlite3_column_text(stmt, 0);
			NSString *tlentry = [[NSString alloc] initWithUTF8String:rslts];
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
	NSLog(@"  returns %@", inAry);
}

- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1 {

	
	NSLog(@"toQry2AryIIS: sql _%@_",sql);
	NSAssert(tDb,@"toQry2AryIIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject: (id) sqlite3_column_int(stmt, 0)];
			[i2 addObject: (id) sqlite3_column_int(stmt, 1)];
			char *rslts = (char *) sqlite3_column_text(stmt, 2);
			NSString *tlentry = [[NSString alloc] initWithUTF8String:rslts];
			[s1 addObject:(id) tlentry];
			NSLog(@"  rslt: %d %d %@",[i1 lastObject], [i2 lastObject], tlentry);
			[tlentry release];
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	NSLog(@"  returns %@ : %@ : %@", i1, i2, s1);
	

}

- (int) toQry2Int {
	NSLog(@"toQry2Int: sql _%@_",sql);
	NSAssert(tDb,@"toQry2Int called with no tDb");
	
	sqlite3_stmt *stmt;
	int irslt;
	
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			irslt = sqlite3_column_int(stmt, 0);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"  returns %d",irslt);

	return irslt;
}

- (NSString *) toQry2Str {
	NSLog(@"toQry2Str: sql _%@_",sql);
	NSAssert(tDb,@"toQry2Int called with no tDb");
	
	sqlite3_stmt *stmt;
	NSString *srslt = [NSString alloc];
	
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		if((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[srslt initWithUTF8String: (char *) sqlite3_column_text(stmt, 0)];
		} else {
			NSLog(@"tob error executing . %@ . : %s", sql, sqlite3_errmsg(tDb));
		}
		//if (rslt != SQLITE_DONE) {
		//	NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		//}
	} else {
		NSLog(@"tob error preparing . %@ . : %s", sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"  returns %@",srslt);
	
	// no retain, no release
	return srslt;
}

- (void) toExecSql {
	NSLog(@"toExecSql: _%@_", sql);
	NSAssert(tDb,@"toExecSql called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		if (sqlite3_step(stmt) != SQLITE_DONE) {
			NSAssert2(0,@"tob error executing _%@_  : %s", sql, sqlite3_errmsg(tDb));
		}
	}
	sqlite3_finalize(stmt);
}

@end
