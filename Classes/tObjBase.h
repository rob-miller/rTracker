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
	
}

@property (nonatomic, retain) NSString *sql;
@property (nonatomic, retain) NSString *dbName;

- (id) init;
- (void) toQry2Ary : (NSMutableArray *) inAry;
- (void) toExecSql;

@end
