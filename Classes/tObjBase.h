/***************
 tObjBase.h
 Copyright 2010-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

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
//@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic) sqlite3 *tDb; 
@property (nonatomic) NSInteger tuniq;

- (id) init;
- (void) getTDb;
- (void) deleteTDb;
- (void) closeTDb ;

- (NSInteger) getUnique;
- (void) minUniquev:(NSInteger) minU;

- (void) toQry2AryS : (NSMutableArray *) inAry sql:(NSString*)sql;
- (void) toQry2AryIS : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 sql:(NSString*)sql;
- (void) toQry2AryISI : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 i2: (NSMutableArray *) i2 sql:(NSString*)sql;
- (void) toQry2AryISII : (NSMutableArray *) i1 s1: (NSMutableArray *) s1 i2: (NSMutableArray *) i2 i3:(NSMutableArray *) i3 sql:(NSString*)sql;

- (void) toQry2ArySS : (NSMutableArray *) s1 s2: (NSMutableArray *) s2 sql:(NSString*)sql;
//- (void) toQry2AryIIS : (NSMutableArray *) i1 i2: (NSMutableArray *) i2 s1: (NSMutableArray *) s1;
- (void) toQry2AryIISIII :(NSMutableArray *)i1 i2:(NSMutableArray *)i2 s1:(NSMutableArray *)s1 i3:(NSMutableArray *)i3 i4:(NSMutableArray *)i4 i5:(NSMutableArray *)i5 sql:(NSString*)sql;
- (void) toQry2AryID : (NSMutableArray *)i1 d1:(NSMutableArray *)d1 sql:(NSString*)sql;
- (void) toQry2AryI : (NSMutableArray *) inAry sql:(NSString*)sql;

-(void) toQry2DictII : (NSMutableDictionary*) dict sql:(NSString*)sql;
-(void) toQry2SetI : (NSMutableSet*) set sql:(NSString*)sql;

- (void) toExecSql :(NSString*)sql;
- (void) toExecSqlIgnErr:(NSString*)sql;

- (int) toQry2Int :(NSString*)sql;
- (void) toQry2IntInt:(int*)i1 i2:(int*)i2 sql:(NSString*)sql;
- (void) toQry2IntIntInt:(NSInteger*)i1 i2:(NSInteger*)i2 i3:(NSInteger*)i3 sql:(NSString*)sql;
- (NSString *) toQry2Str :(NSString*)sql;
- (NSString *) toQry2I12aS1:(int *)arr sql:(NSString*)sql;
- (float) toQry2Float :(NSString*)sql;
- (double) toQry2Double :(NSString*)sql;

- (void) toQry2Log :(NSString*)sql;

@end
