//
//  tObjBase.m
//  rTracker
//
//  Created by Robert Miller on 29/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "tObjBase.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"
#import "dbg-defs.h"

@implementation tObjBase

@synthesize toid=_toid, dbName=_dbName, sql=_sql, tuniq=_tuniq, tDb=_tDb;
//sqlite3 *tDb;

/******************************
 *
 * base tObj db tables
 *
 *  uniquev: id(int) ; value(int)
 *       persistent store to maintain unique trackerObj and valueObj IDs
 *
 ******************************/

#pragma mark -
#pragma mark core object methods and support

- (id) init {
	
	if ((self = [super init])) {
		//DBGLog(@"tObjBase init: db %@",self.dbName);
		self.tDb=nil;
		//[self getTDb];
		self.tuniq = TMPUNIQSTART;
	}
	return self;
}

- (void) dealloc {
    //DBGLog(@"dealloc tObjBase: %@  id=%d",self.dbName,self.toid);
	
	//UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] removeObserver:self
												 name:UIApplicationWillTerminateNotification
											   object:nil];
                                               //object:app];
    [self closeTDb];

	
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	DBGLog(@"tObjBase: app will terminate: toid= %ld",(long)self.toid);
	[self closeTDb];
}


#pragma mark -
#pragma mark total db methods 

//- (sqlite3*) tDb {
//    return _tDb;  // don't auto-allocate; allow to be nil
//}

/*
- (NSString *) trackerDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  // file itunes accessible
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);  // files not accessible
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingPathComponent:self.dbName];
}
*/

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
	//DBGLog(@"a= %f  b= %f  r= %d",va,vb,r);

	return r;
}


- (void) getTDb {
	//DBGLog(@"getTDb dbName= %@ id=%d",self.dbName,self.toid);
	dbgNSAssert(self.dbName, @"getTDb called with no dbName set");
	
	//if (sqlite3_open([[rTracker_resource ioFilePath:self.dbName access:DBACCESS] UTF8String], &_tDb) != SQLITE_OK) {
	if (sqlite3_open_v2([[rTracker_resource ioFilePath:self.dbName access:DBACCESS] UTF8String],
                        &_tDb,
                        SQLITE_OPEN_FILEPROTECTION_COMPLETE|SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,
                        nil) != SQLITE_OK) {
        sqlite3_close(self.tDb);
		dbgNSAssert(0, @"error opening rTracker database");
	} else {
		//DBGLog(@"opened tDb %@",self.dbName);
		int c;
		
		self.sql = @"create table if not exists uniquev (id integer, value integer);";
		[self toExecSql];
		self.sql = @"select count(*) from uniquev where id=0;";
		c = [self toQry2Int];
		
		if (c == 0) {
			DBGLog(@"init uniquev");
			self.sql = @"insert into uniquev (id, value) values (0, 1);";
			[self toExecSql];
		}
/*
#if DEBUGLOG
        else {
			self.sql = @"select value from uniquev where id=0;";
			c = [self toQry2Int];
			DBGLog(@"uniquev= %d",c);
		}
#endif
*/
		self.sql = nil;

		
		sqlite3_create_collation(self.tDb,"CMPSTRDBL",SQLITE_UTF8,NULL,col_str_flt);  // set how comparisons will be done on this database
		
		UIApplication *app = [UIApplication sharedApplication];  // add callback to close database on app terminate
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillTerminate:) 
													 name:UIApplicationWillTerminateNotification
												   object:app];
		
		
	}
}

/* valid to have as nil
- (sqlite3*) tDb {
    if (nil == tDb) {
        [self getTDb];
    }
    return tDb;
}
*/

- (void) deleteTDb {
	DBGLog(@"deleteTDb dbName= %@ id=%ld",self.dbName,(long)self.toid);
	dbgNSAssert(self.dbName, @"deleteTDb called with no dbName set");
	sqlite3_close(self.tDb);
	self.tDb = nil;
    if ([rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:self.dbName access:DBACCESS]]) {
		self.dbName = nil;
    } else {
		DBGErr(@"error removing tDb named %@",_dbName);
    }
}

- (void) closeTDb
{
	if (self.tDb != nil) {
		sqlite3_close(self.tDb);
		self.tDb = nil;
		DBGLog(@"closed tDb: %@", self.dbName);
	} else {
		DBGLog(@"hey! tdb close when tDb already closed %@", self.dbName);
	}
}

#pragma mark -
#pragma mark tObject support utilities

- (NSInteger) getUnique {
	NSInteger i;
	if (self.tDb == nil) {
		++self.tuniq;
		i = -self.tuniq;
		//DBGLog(@"temp tObj id=%d getUnique returning %d",self.toid,i);
	} else {
		self.sql = @"select value from uniquev where id=0;";
		i = [self toQry2Int];
		DBGLog(@"id %ld getUnique got %ld",(long)self.toid,(long)i);
		self.sql = [NSString stringWithFormat:@"update uniquev set value = %ld where id=0;",(long)i+1];
		[self toExecSql];
		self.sql = nil;
	}
	return i;
}

- (void) minUniquev:(NSInteger) minU {
    NSInteger i;
    self.sql = @"select value from uniquev where id=0;";
    i = [self toQry2Int];
    if (i <= minU) {
		self.sql = [NSString stringWithFormat:@"update uniquev set value = %ld where id=0;",(long)minU+1];
		[self toExecSql];
		self.sql = nil;
    }
}

#pragma mark -
#pragma mark escape chars for sql store (apostrophe)

// move to rTracker_resource

#pragma mark -
#pragma mark sql db errors

- (void) tobPrepError {
    DBGErr(@"tob error preparing -> %@ <- : %s toid %ld dbName %@", self.sql, sqlite3_errmsg(self.tDb), (long)self.toid, self.dbName);
}

- (void) tobDoneCheck:(int)rslt {
    if (rslt != SQLITE_DONE) {
        DBGErr(@"tob error not SQL_DONE (%d) -> %@ <- : %s toid %ld dbName %@", rslt, self.sql, sqlite3_errmsg(self.tDb), (long)self.toid, self.dbName);
    }
}

- (void) tobExecError {
    DBGErr(@"tob error executing -> %@ <- : %s toid %ld dbName %@", self.sql, sqlite3_errmsg(self.tDb), (long)self.toid, self.dbName);
}

#pragma mark -
#pragma mark sql query execute methods

- (void) toQry2AryS : (NSMutableArray *) inAry {
	
	SQLDbg(@"toQry2AryS: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			char *rslts = (char *) sqlite3_column_text(stmt, 0);
			NSString *tlentry = [rTracker_resource fromSqlStr:@(rslts)];
			[inAry addObject:(id) tlentry];
			SQLDbg(@"  rslt: %@",tlentry);
		}
        [self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %@", inAry);
}

- (void) toQry2AryIS : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 {
	
	
	SQLDbg(@"toQry2AryIS: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
            int li1;
            char *ls1;
            li1 = sqlite3_column_int(stmt,0);
            ls1 = (char *) sqlite3_column_text(stmt, 1);
            
            //if (strlen(ls1)) {  // don't report if empty ? - fix problem with csv load...
                [i1 addObject: @(li1)];
                [s1 addObject: [rTracker_resource fromSqlStr:@(ls1)]];
                SQLDbg(@"  rslt: %@ %@",[i1 lastObject], [s1 lastObject]);
            //}
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}

- (void) toQry2AryISI : (NSMutableArray *) i1 s1:(NSMutableArray *)s1 i2:(NSMutableArray *)i2 {
	
	
	SQLDbg(@"toQry2AryISI: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryISI called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject: @(sqlite3_column_int(stmt,0))];
			[s1 addObject: [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 1))]];
			[i2 addObject: @(sqlite3_column_int(stmt,2))];
			
			SQLDbg(@"  rslt: %@ %@ %@",[i1 lastObject], [s1 lastObject],[i2 lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}

- (void) toQry2AryISII : (NSMutableArray *) i1 s1:(NSMutableArray *)s1 i2:(NSMutableArray *)i2 i3:(NSMutableArray *)i3 {
	
	
	SQLDbg(@"toQry2AryISII: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryISI called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject: @(sqlite3_column_int(stmt,0))];
			[s1 addObject: [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 1))]];
			[i2 addObject: @(sqlite3_column_int(stmt,2))];
			[i3 addObject: @(sqlite3_column_int(stmt,3))];
			
			SQLDbg(@"  rslt: %@ %@ %@ %@",[i1 lastObject], [s1 lastObject],[i2 lastObject],[i3 lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}

- (void) toQry2ArySS : (NSMutableArray *) s1 s2: (NSMutableArray *) s2 {
	
	
	SQLDbg(@"toQry2ArySS: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2ArySS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[s1 addObject: [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 0))]];
			
			[s2 addObject: [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 1))]];
			
			SQLDbg(@"  rslt: %@ %@",[s1 lastObject], [s2 lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}

- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1 {
// not used
	
	SQLDbg(@"toQry2AryIIS: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryIIS called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject:@(sqlite3_column_int(stmt, 0))];
			
			[i2 addObject: @(sqlite3_column_int(stmt, 1))];
			
			[s1 addObject: [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 2))]];
			
			SQLDbg(@"  rslt: %@ %@ %@",[i1 lastObject], [i2 lastObject], [s1 lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}


- (void) toQry2AryIISIII : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1 i3:(NSMutableArray *)i3 i4:(NSMutableArray *)i4 i5:(NSMutableArray *)i5 
{
	
	
	SQLDbg(@"toQry2AryIISII: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryIISII called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject: @(sqlite3_column_int(stmt, 0))];
			
			[i2 addObject: @(sqlite3_column_int(stmt, 1))];
			
			[s1 addObject: [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 2))]];
			
			[i3 addObject: @(sqlite3_column_int(stmt, 3))];
			
			[i4 addObject: @(sqlite3_column_int(stmt, 4))];
			[i5 addObject: @(sqlite3_column_int(stmt, 5))];
			
			SQLDbg(@"  rslt: %@ %@ %@ %@ %@ %@",[i1 lastObject], [i2 lastObject], [s1 lastObject], [i4 lastObject], [i4 lastObject], [i5 lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}


- (void) toQry2AryID : (NSMutableArray *)i1 d1:(NSMutableArray *)d1
{
	SQLDbg(@"toQry2AryID: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryIF called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[i1 addObject: @(sqlite3_column_int(stmt, 0))];
			[d1 addObject: @(sqlite3_column_double(stmt, 1))];

			SQLDbg(@"  rslt: %@ %@",[i1 lastObject], [d1 lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}
   
- (void) toQry2AryI : (NSMutableArray *) inAry {
	
	SQLDbg(@"toQry2AryI: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryI called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			[inAry addObject: @(sqlite3_column_int(stmt, 0))];
			SQLDbg(@"  rslt: %@",[inAry lastObject]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %@", inAry);
}

-(void) toQry2DictII : (NSMutableDictionary*) dict {
	SQLDbg(@"toQry2DictII: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2DictII called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
            [dict setObject:@(sqlite3_column_int(stmt, 1)) forKey:@(sqlite3_column_int(stmt, 0))];
			SQLDbg(@"  rslt: %@ -> %@",@(sqlite3_column_int(stmt, 0)),[dict objectForKey:@(sqlite3_column_int(stmt, 0))]);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %@", dict);
    
}

-(void) toQry2SetI : (NSMutableSet*) set {
	SQLDbg(@"toQry2SetI: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2SetI called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
            [set addObject:@(sqlite3_column_int(stmt, 0))];
			SQLDbg(@"  rslt: %@ ",@(sqlite3_column_int(stmt, 0)));
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %@", set);
    
}
- (void) toQry2IntInt:(int *)i1 i2:(int*)i2 {
	
	SQLDbg(@"toQry2AryII: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2AryII called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		*i1=0;
		*i2=0;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			*i1 = sqlite3_column_int(stmt, 0);
			*i2 = sqlite3_column_int(stmt, 1);
			SQLDbg(@"  rslt: %d %d",*i1,*i2);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %d %d",*i1,*i2);
}

- (void) toQry2IntIntInt:(NSInteger *)i1 i2:(NSInteger*)i2 i3:(NSInteger*)i3 {
	
	SQLDbg(@"toQry2IntIntInt: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2IntIntInt called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		*i1=0;
		*i2=0;
        *i3=0;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			*i1 = sqlite3_column_int(stmt, 0);
			*i2 = sqlite3_column_int(stmt, 1);
			*i3 = sqlite3_column_int(stmt, 2);
			SQLDbg(@"  rslt: %d %d %d",*i1,*i2,*i3);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %d %d %d",*i1,*i2,*i3);
}

- (int) toQry2Int {
	SQLDbg(@"toQry2Int: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2Int called with no tDb");
	
	sqlite3_stmt *stmt;
	int irslt=0;
	
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			irslt = sqlite3_column_int(stmt, 0);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	
	SQLDbg(@"  returns %d",irslt);

	return irslt;
}

- (NSString *) toQry2Str {
	SQLDbg(@"toQry2StrCopy: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2StrCopy called with no tDb");
	
	sqlite3_stmt *stmt;
	NSString *srslt=@"";
	
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		//int rslt;
		if((/*rslt =*/ sqlite3_step(stmt)) == SQLITE_ROW) {
            if (sqlite3_column_text(stmt, 0)) {
                srslt = [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 0))];
            }
		} else {
			[self tobExecError];
		}
		//[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	
	SQLDbg(@"  returns _%@_",srslt);
	
	return srslt;
}

- (NSString *) toQry2I12aS1:(int *)arr {
	
	SQLDbg(@"toQry2AryI11S1: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(self.tDb,@"toQry2AryI11S1 called with no tDb");
	
	sqlite3_stmt *stmt;
    NSString *srslt=@"";

	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt,i;
        for (i=0;i<12;i++) {
            arr[i]=0;
        }
        
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
            for (i=0;i<12;i++) {
                arr[i] = sqlite3_column_int(stmt, i);
            }
            srslt = [rTracker_resource fromSqlStr:@((char *) sqlite3_column_text(stmt, 12))];
			SQLDbg(@"  rslt: %d %d %d %d %d %d %d %d %d %d %d %d %@",arr[0],arr[1],arr[2],arr[3],arr[4],arr[5],arr[6],arr[7],arr[8],arr[9],arr[10],arr[11],srslt);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	SQLDbg(@"  returns %d %d %d %d %d %d %d %d %d %d %d %d %@",arr[0],arr[1],arr[2],arr[3],arr[4],arr[5],arr[6],arr[7],arr[8],arr[9],arr[10],arr[11],srslt);
    return srslt;
}

- (float) toQry2Float {
	SQLDbg(@"toQry2Float: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2Float called with no tDb");
	
	sqlite3_stmt *stmt;
	float frslt=0.0f;
	
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			frslt = (float) sqlite3_column_double(stmt, 0);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	
	SQLDbg(@"  returns %f",frslt);
	
	return frslt;
}

- (double) toQry2Double {
	SQLDbg(@"toQry2Double: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2Double called with no tDb");
	
	sqlite3_stmt *stmt;
	double drslt=0.0f;
	
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			drslt = sqlite3_column_double(stmt, 0);
		}
		[self tobDoneCheck:rslt];
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
	
	SQLDbg(@"  returns %f",drslt);
	
	return drslt;
}


- (void) toExecSql {
	SQLDbg(@"toExecSql: %@ => _%@_", self.dbName, self.sql);
	dbgNSAssert(_tDb,@"toExecSql called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		if (sqlite3_step(stmt) != SQLITE_DONE) {
			[self tobExecError];
		}
	} else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
}

// so we can ignore error when adding column
- (void) toExecSqlIgnErr {
	SQLDbg(@"toExecSqlIgnErr: %@ => _%@_", self.dbName, self.sql);
	dbgNSAssert(_tDb,@"toExecSqlIgnErr called with no tDb");
	
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
	}
	sqlite3_finalize(stmt);
}

- (void) toQry2Log {
#if DEBUGLOG    
	SQLDbg(@"toQry2Log: %@ => _%@_",self.dbName,self.sql);
	dbgNSAssert(_tDb,@"toQry2Log called with no tDb");
	
	sqlite3_stmt *stmt;
	NSString *srslt;
	
	if (sqlite3_prepare_v2(self.tDb, [self.sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		int rslt;
		int c = sqlite3_column_count(stmt);
		int i;
		NSString *cols=@"";
		for (i=0; i<c; i++) {
			cols = [cols stringByAppendingString:[NSString stringWithUTF8String:sqlite3_column_name(stmt,i)]];
			cols = [cols stringByAppendingString:@" "];
		}
		NSLog(@"%@  (db)",cols);
		while ((rslt = sqlite3_step(stmt)) == SQLITE_ROW) {
			cols = @"";
			for (i=0; i<c; i++) {
				srslt = [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, i)];
				cols = [cols stringByAppendingString:srslt];
				cols = [cols stringByAppendingString:@" "];
			}
			NSLog(@"%@",cols);
        }
        [self tobDoneCheck:rslt];
    } else {
		[self tobPrepError];
	}
	sqlite3_finalize(stmt);
#endif
}

@end
