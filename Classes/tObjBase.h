//
//  tObjBase.h
//  rTracker
//
//  Created by Robert Miller on 29/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface tObjBase : NSObject
/*{

	NSInteger toid;
	NSString *dbName;
	NSString *sql;
	sqlite3 *tDb;
	int tuniq;
}*/

@property (nonatomic) NSInteger toid;
@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic) sqlite3 *tDb; 
@property (nonatomic) NSInteger tuniq;

- (id) init;
- (void) getTDb;
- (void) deleteTDb;
- (void) closeTDb ;

- (NSInteger) getUnique;
- (void) minUniquev:(NSInteger) minU;

- (void) toQry2AryS : (NSMutableArray *) inAry;
- (void) toQry2AryIS : (NSMutableArray *) i1 s1: (NSMutableArray *) s1;
- (void) toQry2AryISI : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 i2: (NSMutableArray *) i2;
- (void) toQry2AryISII : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 i2: (NSMutableArray *) i2 i3:(NSMutableArray *) i3;

- (void) toQry2ArySS : (NSMutableArray *) s1 s2: (NSMutableArray *) s2;
//- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1;
- (void) toQry2AryIISIII :(NSMutableArray *)i1 i2:(NSMutableArray *)i2 s1:(NSMutableArray *)s1 i3:(NSMutableArray *)i3 i4:(NSMutableArray *)i4 i5:(NSMutableArray *)i5;
- (void) toQry2AryID : (NSMutableArray *)i1 d1:(NSMutableArray *)d1;
- (void) toQry2AryI : (NSMutableArray *) inAry;

-(void) toQry2DictII : (NSMutableDictionary*) dict;
-(void) toQry2SetI : (NSMutableSet*) set;

- (void) toExecSql;
- (void) toExecSqlIgnErr;

- (int) toQry2Int;
- (void) toQry2IntInt:(int*)i1 i2:(int*)i2;
- (void) toQry2IntIntInt:(NSInteger*)i1 i2:(NSInteger*)i2 i3:(NSInteger*)i3;
- (NSString *) toQry2Str;
- (NSString *) toQry2I12aS1:(int *)arr;
- (float) toQry2Float;
- (double) toQry2Double;

- (void) toQry2Log;

@end
