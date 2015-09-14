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
#define NONAME      0

#define DEBUGFUNCTION     0
#define REMINDERDBG 0

//********       vvvvvv //

#define RELEASE     1
#define DEBUGLOG    0
#define SHOWTOUCHES 0

//#define ADVERSION   0


// report scheduled notification fire dates in dbInfo() 


//********       ^^^^^^ //

#define DEBUGWARN   1
#define DEBUGERR    1

#if SQLDEBUG
#define SQLDbg(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#else 
#define SQLDbg(args...)
#endif

#define DBGSTR 
#if DEBUGLOG
#define DBGLog(args...) NSLog(@"%s%d: %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat: args])

#define DBGTLIST(tl) { \
    NSUInteger c = [tl.topLayoutNames count]; \
    NSUInteger i; \
    DBGLog(@"tlist: %lu items  privacy= %d",(unsigned long)c,[privacyV getPrivacyValue]); \
    NSLog(@"n  id  priv   name (tlist)"); \
    for (i=0;i<c;i++) { \
        NSLog(@" %lu  %@  %@   %@",(unsigned long)i+1,[tl.topLayoutIDs objectAtIndex:i], [tl.topLayoutPriv objectAtIndex:i],[tl.topLayoutNames objectAtIndex:i]); \
    } \
    NSString *sql=@"select rank, id, priv, name from toplevel order by rank"; \
    [tl toQry2Log:sql]; \
}

#else
#define DBGLog(...) 
#define DBGTLIST(tl) 
#endif

#if DEBUGWARN
//#define DBGWarn(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#define DBGWarn(args...) NSLog(@"%s%d: **WARNING** %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat: args])
#else
#define DBGWarn(args...)
#endif


#if DEBUGERR
#define DBGErr(args...) NSLog(@"%s%d: **ERROR** %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat: args])
#else
#define DBGErr(args...) 
#endif

#if RELEASE
#define dbgNSAssert(x,y) if (0==(x)) { DBGErr(y); }
#define dbgNSAssert1(x,y,z) if (0==(x)) { DBGErr(y,z); }
#define dbgNSAssert2(x,y,z,t) if (0==(x)) { DBGErr(y,z,t); }
#else
#define dbgNSAssert NSAssert
#define dbgNSAssert1 NSAssert1
#define dbgNSAssert2 NSAssert2
#endif