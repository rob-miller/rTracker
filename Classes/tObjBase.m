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

#pragma mark -
#pragma mark core object methods and support

- (id) init {
	
	NSLog(@"tObjBase init: db %@",self.dbName);
	tDb=nil;
	//[self getTDb];
	
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObjBase: %@  id=%d",self.dbName,self.toid);
	
	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:UIApplicationWillTerminateNotification
											   object:app];
		
	[self closeTDb];
	self.sql = nil;
	[sql release];
	self.dbName = nil;
	[dbName release];
	
	[super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"tObjBase: app will terminate: toid= %d",self.toid);
	[self closeTDb];
}


#pragma mark -
#pragma mark total db methods 

- (NSString *) trackerDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingPathComponent:self.dbName];
}

static int col_str_flt (void *udp, int lenA, const void *strA, int lenB, const void *strB) 
{
	// strAm strB not guaranteed to be null-terminated
	
	//double va = atof(strA);
	//double vb = atof(strB);
	char *astr = (char *) strA;
	char *bstr = (char *) strB;
	char *ta = &(astr[lenA-1]);
	char *tb = &(bstr[lenB-1]);
	double va = strtod(strA,&ta);
	double vb = strtod(strB,&tb);
	int r=0;
	if (va>vb)
		r= 1;
	if (va<vb) 
		r= -1;
	//NSLog(@"a= %f  b= %f  r= %d",va,vb,r);

	return r;
}


- (void) getTDb {
	NSLog(@"getTDb dbName= %@ id=%d",self.dbName,self.toid);
	NSAssert(self.dbName, @"getTDb called with no dbName set");
	
	if (sqlite3_open([[self trackerDbFilePath] UTF8String], &tDb) != SQLITE_OK) {
		sqlite3_close(tDb);
		NSAssert(0, @"error opening rTracker database");
	} else {
		NSLog(@"opened tDb %@",self.dbName);
		int c;
		
		self.sql = @"create table if not exists uniquev (id integer, value integer);";
		[self toExecSql];
		self.sql = @"select count(*) from uniquev where id=0;";
		c = [self toQry2Int];
		
		if (c == 0) {
			NSLog(@"init uniquev");
			self.sql = @"insert into uniquev (id, value) values (0, 1);";
			[self toExecSql];
		} else {
			self.sql = @"select value from uniquev where id=0;";
			c = [self toQry2Int];
			NSLog(@"uniquev= %d",c);
		}
		self.sql = nil;

		
		sqlite3_create_collation(tDb,"CMPSTRDBL",SQLITE_UTF8,NULL,col_str_flt);
		
		UIApplication *app = [UIApplication sharedApplication];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillTerminate:) 
													 name:UIApplicationWillTerminateNotification
												   object:app];
		
		
	}
}

- (void) deleteTDb {
	NSLog(@"deleteTDb dbName= %@ id=%d",self.dbName,self.toid);
	NSAssert(self.dbName, @"deleteTDb called with no dbName set");
	sqlite3_close(tDb);
	tDb = nil;
	NSFileManager *fm = [[NSFileManager alloc] init];
	BOOL didRemove = [fm removeItemAtPath:[self trackerDbFilePath] error:NULL];
	[fm release];
	if (! didRemove) {
		NSLog(@"error removing tDb named %@",dbName);
	} else {
		self.dbName = nil;
	}
}

- (void) closeTDb 
{
	if (tDb != nil) {
		sqlite3_close(tDb);
		tDb = nil;
		NSLog(@"closed tDb: %@", self.dbName);
	} else {
		NSLog(@"tDb already closed %@", self.dbName);
	}
}

#pragma mark -
#pragma mark tObject support utilities

- (int) getUnique {
	int i;
	if (tDb == nil) {
		++tuniq;
		i = -tuniq;
		NSLog(@"temp tObj id=%d getUnique returning %d",self.toid,i);
	} else {
		self.sql = @"select value from uniquev where id=0;";
		i = [self toQry2Int];
		NSLog(@"id %d getUnique got %d",self.toid,i);
		self.sql = [NSString stringWithFormat:@"update uniquev set value = %d where id=0;",i+1];
		[self toExecSql];
		self.sql = nil;
	}
	return i;
}

#pragma mark -
#pragma mark sql query execute methods

- (void) toQry2AryS : (NSMutableArray *) inAry {
	
	NSLog(@"toQry2AryS: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2AryS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			char *rslts = (char *) sqlite3_column_text(stmt, 0);
			NSString *tlentry = [NSString stringWithUTF8String:rslts];
			[inAry addObject:(id) tlentry];
			NSLog(@"  rslt: %@",tlentry);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	NSLog(@"  returns %@", inAry);
}

- (void) toQry2AryIS : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 {
	
	
	NSLog(@"toQry2AryIS: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2AryIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			//NSNumber *i = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 0)];
			//[i1 addObject: i];
			//[i release];
			[i1 addObject: [NSNumber numberWithInt: sqlite3_column_int(stmt,0)]];
			
			//NSString *tlentry = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
			//[s1 addObject:(id) tlentry];
			//[tlentry release];
			[s1 addObject: [NSString stringWithUTF8String:(char *) sqlite3_column_text(stmt, 1)]];
			
			NSLog(@"  rslt: %@ %@",[i1 lastObject], [s1 lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
}


- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1 {
// not used
	
	NSLog(@"toQry2AryIIS: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2AryIIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			//NSNumber *i = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 0)];
			//[i1 addObject: i];
			//[i release];
			[i1 addObject:[NSNumber numberWithInt: sqlite3_column_int(stmt, 0)]];
			
			//NSNumber *j = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 1)];
			//[i2 addObject:(id) j];
			//[j release];
			[i2 addObject: [NSNumber numberWithInt: sqlite3_column_int(stmt, 1)]];
			
			//NSString *tlentry = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 2)];
			//[s1 addObject:(id) tlentry];
			//[tlentry release];
			[s1 addObject: [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, 2)]];
			
			NSLog(@"  rslt: %@ %@ %@",[i1 lastObject], [i2 lastObject], [s1 lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	//NSLog(@"  returns %@ : %@ : %@", i1, i2, s1);
	

}


- (void) toQry2AryIISII : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1 i3:(NSMutableArray *)i3 i4:(NSMutableArray *)i4
{
	
	
	NSLog(@"toQry2AryIISII: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2AryIISII called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			//NSNumber *i = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 0)];
			//[i1 addObject: i];
			//[i release];
			[i1 addObject: [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
			
			//NSNumber *j = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 1)];
			//[i2 addObject:(id) j];
			//[j release];
			[i2 addObject: [NSNumber numberWithInt: sqlite3_column_int(stmt, 1)]];
			
			//NSString *tlentry = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 2)];
			//[s1 addObject:(id) tlentry];
			//[tlentry release];
			[s1 addObject: [NSString stringWithUTF8String:(char *) sqlite3_column_text(stmt, 2)]];
			
			//NSNumber *k = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 3)];
			//[i3 addObject: k];
			//[k release];
			[i3 addObject: [NSNumber numberWithInt: sqlite3_column_int(stmt, 3)]];
			
			//NSNumber *l = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, 4)];
			//[i4 addObject:(id) l];
			//[l release];
			[i4 addObject: [NSNumber numberWithInt: sqlite3_column_int(stmt, 4)]];
			
			NSLog(@"  rslt: %@ %@ %@ %@ %@",
				  [i1 lastObject], [i2 lastObject], [s1 lastObject], [i4 lastObject], [i4 lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	//NSLog(@"  returns %@ : %@ : %@", i1, i2, s1);
}


- (void) toQry2AryID : (NSMutableArray *)i1 d1:(NSMutableArray *)d1
{
	NSLog(@"toQry2AryIF: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2AryIF called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject: [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
			[d1 addObject: [NSNumber numberWithDouble: sqlite3_column_double(stmt, 1)]];

			NSLog(@"  rslt: %@ %@",
				  [i1 lastObject], [d1 lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
}
   
- (void) toQry2AryI : (NSMutableArray *) inAry {
	
	NSLog(@"toQry2AryI: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2AryI called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[inAry addObject: [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
			NSLog(@"  rslt: %@",[inAry lastObject]);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	NSLog(@"  returns %@", inAry);
}


- (int) toQry2Int {
	NSLog(@"toQry2Int: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2Int called with no tDb");
	
	sqlite3_stmt *stmt;
	int irslt=0;
	
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			irslt = sqlite3_column_int(stmt, 0);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"  returns %d",irslt);

	return irslt;
}

- (NSString *) toQry2StrCopy {
	NSLog(@"toQry2StrCopy: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2StrCopy called with no tDb");
	
	sqlite3_stmt *stmt;
	NSString *srslt=@"";
	
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		//int rslt;
		if((/*rslt =*/ sqlite3_step(stmt)) == SQLITE_ROW) {
			srslt = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 0)];
		} else {
			NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
		//if (rslt != SQLITE_DONE) {
		//	NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		//}
	} else {
		NSLog(@"tob error preparing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"  returns _%@_",srslt);
	
	return srslt;
}

- (float) toQry2Float {
	NSLog(@"toQry2Float: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2Float called with no tDb");
	
	sqlite3_stmt *stmt;
	float frslt=0.0f;
	
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			frslt = (float) sqlite3_column_double(stmt, 0);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"  returns %f",frslt);
	
	return frslt;
}

- (double) toQry2Double {
	NSLog(@"toQry2Double: %@ => _%@_",self.dbName,self.sql);
	NSAssert(tDb,@"toQry2Double called with no tDb");
	
	sqlite3_stmt *stmt;
	double drslt=0.0f;
	
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			drslt = sqlite3_column_double(stmt, 0);
		}
		if (rslt != SQLITE_DONE) {
			NSLog(@"tob not SQL_DONE executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
		}
	} else {
		NSLog(@"tob error executing . %@ . : %s", self.sql, sqlite3_errmsg(tDb));
	}
	sqlite3_finalize(stmt);
	
	NSLog(@"  returns %f",drslt);
	
	return drslt;
}


- (void) toExecSql {
	NSLog(@"toExecSql: %@ => _%@_", self.dbName, self.sql);
	NSAssert(tDb,@"toExecSql called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		if (sqlite3_step(stmt) != SQLITE_DONE) {
			NSAssert2(0,@"tob error executing _%@_  : %s", self.sql, sqlite3_errmsg(tDb));
		}
	}
	sqlite3_finalize(stmt);
}

@end
