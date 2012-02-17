//
//  dbg-defs.h
//  rTracker
//
//  Created by Rob Miller on 30/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

// iOS Version Checking
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define SQLDEBUG    0

#define DEBUGLOG    1
#define DEBUGWARN   1
#define DEBUGERR    1
#define RELEASE     1

#if SQLDEBUG 
#define SQLDbg(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#else 
#define SQLDbg(args...)
#endif

#if DEBUGLOG
//#define DBGLog(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#define DBGLog(args...) NSLog(@"%s%d: %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat: args])
//#define DBGLog (args, ...) NSLog((@"%s [Line %d] " args), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define DBGTLIST(tl) { \
    NSUInteger c = [tl.topLayoutNames count]; \
    NSUInteger i; \
    DBGLog(@"tlist: %d items",c); \
    NSLog(@"n  id  priv   name"); \
    for (i=0;i<c;i++) { \
        NSLog(@" %d  %@  %@   %@",i+1,[tl.topLayoutIDs objectAtIndex:i], [tl.topLayoutPriv objectAtIndex:i],[tl.topLayoutNames objectAtIndex:i]); \
    } \
    tl.sql=@"select rank, id, priv, name from toplevel order by rank"; \
    [tl toQry2Log]; \
}

#else
#define DBGLog(...) 
#endif

#if DEBUGWARN
//#define DBGWarn(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#define DBGWarn(args...) NSLog(@"%s%d: **WARNING** %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat: args])
#else
#define DBGWarn(args...)
#endif


#if DEBUGERR
//#define DBGErr(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#define DBGErr(args...) 
#else
#define DBGErr(args...) NSLog(@"%s%d: **ERROR** %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat: args])
#endif

#if RELEASE
#define dbgNSAssert(x,y) if (0==x) { DBGErr(y); }
#define dbgNSAssert1(x,y,z) if (0==x) { DBGErr(y,z); }
#define dbgNSAssert2(x,y,z,t) if (0==x) { DBGErr(y,z,t); }
#else
#define dbgNSAssert NSAssert
#define dbgNSAssert1 NSAssert1
#define dbgNSAssert2 NSAssert2
#endif