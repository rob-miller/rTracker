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

}

- (id) init;
- (void) toQry2Ary : (NSString *) inQry inAry: (NSMutableArray *) inAry;
- (void) toExecSql : (NSString *) sql;

@end
