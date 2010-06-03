//
//  tObjBase.h
//  rTracker
//
//  Created by Robert Miller on 29/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"


@interface tObjBase : NSObject {

	NSString *dbName;
	NSString *sql;
	sqlite3 *tDb;
}

@property (nonatomic, retain) NSString *sql;
@property (nonatomic, retain) NSString *dbName;

- (id) init;
- (void) getTDb;
- (void) toQry2AryS : (NSMutableArray *) inAry;
- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1;

- (void) toExecSql;
- (int) toQry2Int;
- (NSString *) toQry2Str;

@end
