//
//  tObjBase.m
//  rTracker
//
//  Created by Robert Miller on 29/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "tObjBase.h"


@implementation tObjBase

@synthesize toid;
@synthesize dbName;
@synthesize sql;

//sqlite3 *tDb;

- (NSString *) trackerDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingPathComponent:dbName];
}

- (void) getTDb {
	NSLog(@"getTDb dbName= %@ id=%d",dbName,toid);
	NSAssert(dbName, @"getTDb called with no dbName set");
	
	if (sqlite3_open([[self trackerDbFilePath] UTF8String], &tDb) != SQLITE_OK) {
		sqlite3_close(tDb);
		NSAssert(0, @"error opening rTracker database");
	} else {
		NSLog(@"opened tDb %@",dbName);
		int c;
		
		sql = @"create table if not exists uniquev (id integer, value integer);";
		[self toExecSql];
		sql = @"select count(*) from uniquev where id=0;";
		c = [self toQry2Int];
		
		if (c == 0) {
			NSLog(@"init uniquev");
			sql = @"insert into uniquev (id, value) values (0, 1);";
			[self toExecSql];
		} else {
			sql= @"select value from uniquev where id=0;";
			c = [self toQry2Int];
			NSLog(@"uniquev= %d",c);
		}
	}
}

- (void) deleteTDb {
	NSLog(@"deleteTDb dbName= %@ id=%d",dbName,toid);
	NSAssert(dbName, @"deleteTDb called with no dbName set");
	sqlite3_close(tDb);
	//[tDb release];
	tDb = nil;
	NSFileManager *fm = [[NSFileManager alloc] init];
	BOOL didRemove = [fm removeItemAtPath:[self trackerDbFilePath] error:NULL];
	[fm release];
	if (! didRemove) {
		NSLog(@"error removing tDb named %@",dbName);
	} else {
		[dbName release];
		dbName = nil;
	}
		
}

- (int) getUnique {
	int i;
	if (tDb == nil) {
		++tuniq;
		i = - tuniq;
		NSLog(@"temp tObj id=%d getUnique returning %d",toid,i);
	} else {
		sql= @"select value from uniquev where id=0;";
		i = [self toQry2Int];
		NSLog(@"id %d getUnique got %d",toid,i);
		sql = [NSString stringWithFormat:@"update uniquev set value = %d where id=0;",i+1];
		[self toExecSql];
		//[sql release];
		sql = nil;
	}
	return i;
}


- (id) init {

	NSLog(@"tObjBase init: db %@",dbName);
	tDb=nil;
	//[self getTDb];
	
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObjBase: %@  id=%d",dbName,toid);
	if (tDb != nil) {
		sqlite3_close(tDb);
		//[tDb release];
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
	
	NSLog(@"toQry2AryS: %@ => _%@_",dbName,sql);
	NSAssert(tDb,@"toQry2AryS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			char *rslts = (char *) sqlite3_column_text(stmt, 0);
			//NSString *tlentry = [[NSString alloc] initWithUTF8String:rslts];
			NSString *tlentry = [NSString stringWithUTF8String:rslts];
			[inAry addObject:(id) tlentry];
			NSLog(@"  rslt: %@",tlentry);
			//[tlentry release];
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

- (void) toQry2AryIS : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 {
	
	
	NSLog(@"toQry2AryIS: %@ => _%@_",dbName,sql);
	NSAssert(tDb,@"toQry2AryIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			NSNumber *i = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 0)];
			//NSNumber *i = [NSNumber numberWithInt: sqlite3_column_int(stmt, 0)];
			[i1 addObject: i];
			[i release];
			
			NSString *tlentry = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
			[s1 addObject:(id) tlentry];
			[tlentry release];
			
			NSLog(@"  rslt: %@ %@",[i1 lastObject], [s1 lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
}


- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1 {

	
	NSLog(@"toQry2AryIIS: %@ => _%@_",dbName,sql);
	NSAssert(tDb,@"toQry2AryIIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			NSNumber *i = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 0)];
			//NSNumber *i = [NSNumber numberWithInt: sqlite3_column_int(stmt, 0)];
			[i1 addObject: i];
			[i release];
			
			NSNumber *j = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 1)];
			//NSNumber *j = [NSNumber numberWithInt: sqlite3_column_int(stmt, 1)];
			[i2 addObject:(id) j];
			[j release];
			
			NSString *tlentry = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 2)];
			//NSString *tlentry = [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, 2)];
			[s1 addObject:(id) tlentry];
			[tlentry release];
			
			NSLog(@"  rslt: %@ %@ %@",[i1 lastObject], [i2 lastObject], [s1 lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	//NSLog(@"  returns %@ : %@ : %@", i1, i2, s1);
	

}

- (int) toQry2Int {
	NSLog(@"toQry2Int: %@ => _%@_",dbName,sql);
	NSAssert(tDb,@"toQry2Int called with no tDb");
	
	sqlite3_stmt *stmt;
	int irslt=0;
	
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

- (NSString *) toQry2StrCopy {
	NSLog(@"toQry2StrCopy: %@ => _%@_",dbName,sql);
	NSAssert(tDb,@"toQry2StrCopy called with no tDb");
	
	sqlite3_stmt *stmt;
	NSString *srslt=@"";
	
	if (sqlite3_prepare_v2(tDb, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		//int rslt;
		if((/*rslt =*/ sqlite3_step(stmt)) == SQLITE_ROW) {
			srslt = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 0)];
			//srslt = [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, 0)];
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
	
	NSLog(@"  returns _%@_",srslt);
	//[srslt autorelease];
	
	return srslt;
}

- (void) toExecSql {
	NSLog(@"toExecSql: %@ => _%@_", dbName, sql);
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
