//
//  dbg-defs.h
//  rTracker
//
//  Created by Rob Miller on 30/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#define SQLDEBUG    0

#define DEBUGLOG    1
#define DEBUGWARN   1
#define DEBUGERR    1

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
