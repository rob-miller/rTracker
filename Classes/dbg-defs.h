//
//  dbg-defs.h
//  rTracker
//
//  Created by Rob Miller on 30/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#define SQLDEBUG    0

#define DEBUGLOG    0
#define DEBUGWARN   1
#define DEBUGERR    1
#define RELEASE     1

#if SQLDEBUG 
#define SQLDbg(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#else 
#define SQLDbg(args...)
#endif

#if DEBUGLOG
#define DBGLog(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#else
#define DBGLog(args...) 
#endif

#if DEBUGWARN
#define DBGWarn(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#else
#define DBGWarn(args...)
#endif

#if DEBUGERR
#define DBGErr(args...) NSLog(@"%@",[NSString stringWithFormat: args])
#else
#define DBGErr(args...)
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