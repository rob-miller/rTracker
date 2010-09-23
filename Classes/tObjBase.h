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

	NSInteger toid;
	NSString *dbName;
	NSString *sql;
	sqlite3 *tDb;
	int tuniq;
}

@property (nonatomic) NSInteger toid;
@property (nonatomic, retain) NSString *sql;
@property (nonatomic, retain) NSString *dbName;

- (id) init;
- (void) getTDb;
- (void) deleteTDb;

- (int) getUnique;

- (void) toQry2AryS : (NSMutableArray *) inAry;
- (void) toQry2AryIS : (NSMutableArray *) i1 s1: (NSMutableArray *) s1;
//- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1;
- (void) toQry2AryIISII :(NSMutableArray *)i1 i2:(NSMutableArray *)i2 s1:(NSMutableArray *)s1 i3:(NSMutableArray *)i3 i4:(NSMutableArray *)i4;

- (void) toExecSql;
- (int) toQry2Int;
- (NSString *) toQry2StrCopy;
- (float) toQry2Float;

@end
