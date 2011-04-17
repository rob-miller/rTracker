//
//  dbg-defs.h
//  rTracker
//
//  Created by Rob Miller on 30/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#define SQLDEBUG    1

#define DEBUGLOG    1
#define DEBUGWARN   1
#define DEBUGERR    1

#if SQLDEBUG 
#define SQLDbg(a) NSLog(a)
#define SQLDbg1(a,b) NSLog(a,b)
#define SQLDbg2(a,b,c) NSLog(a,b,c)
#define SQLDbg3(a,b,c,d) NSLog(a,b,c,d)
#define SQLDbg4(a,b,c,d,e) NSLog(a,b,c,d,e)
#define SQLDbg5(a,b,c,d,e,f) NSLog(a,b,c,d,e,f)
#define SQLDbg6(a,b,c,d,e,f,g) NSLog(a,b,c,d,e,f,g)
#else 
#define SQLDbg(a)
#define SQLDbg1(a,b)
#define SQLDbg2(a,b,c)
#define SQLDbg3(a,b,c,d)
#define SQLDbg4(a,b,c,d,e)
#define SQLDbg5(a,b,c,d,e,f)
#define SQLDbg6(a,b,c,d,e,f,g)
#endif

#if DEBUGLOG
#define DBGLog(a) NSLog(a)
#define DBGLog1(a,b) NSLog(a,b)
#define DBGLog2(a,b,c) NSLog(a,b,c)
#define DBGLog3(a,b,c,d) NSLog(a,b,c,d)
#define DBGLog4(a,b,c,d,e) NSLog(a,b,c,d,e)
#define DBGLog5(a,b,c,d,e,f) NSLog(a,b,c,d,e,f)
#define DBGLog6(a,b,c,d,e,f,g) NSLog(a,b,c,d,e,f,g)
#else
#define DBGLog(a) 
#define DBGLog1(a,b)
#define DBGLog2(a,b,c)
#define DBGLog3(a,b,c,d)
#define DBGLog4(a,b,c,d,e)
#define DBGLog5(a,b,c,d,e,f)
#define DBGLog6(a,b,c,d,e,f,g)
#endif

#if DEBUGWARN
#define DBGWarn(a) NSLog(a)
#define DBGWarn1(a,b) NSLog(a,b)
#define DBGWarn2(a,b,c) NSLog(a,b,c)
#define DBGWarn3(a,b,c,d) NSLog(a,b,c,d)
#define DBGWarn4(a,b,c,d,e) NSLog(a,b,c,d,e)
#define DBGWarn5(a,b,c,d,e,f) NSLog(a,b,c,d,e,f)
#define DBGWarn6(a,b,c,d,e,f,g) NSLog(a,b,c,d,e,f,g)
#else
#define DBGWarn(a)
#define DBGWarn1(a,b)
#define DBGWarn2(a,b,c)
#define DBGWarn3(a,b,c,d)
#define DBGWarn4(a,b,c,d,e)
#define DBGWarn5(a,b,c,d,e,f)
#define DBGWarn6(a,b,c,d,e,f,g)
#endif

#if DEBUGERR
#define DBGErr(a) NSLog(a)
#define DBGErr1(a,b) NSLog(a,b)
#define DBGErr2(a,b,c) NSLog(a,b,c)
#define DBGErr3(a,b,c,d) NSLog(a,b,c,d)
#define DBGErr4(a,b,c,d,e) NSLog(a,b,c,d,e)
#define DBGErr5(a,b,c,d,e,f) NSLog(a,b,c,d,e,f)
#define DBGErr6(a,b,c,d,e,f,g) NSLog(a,b,c,d,e,f,g)
#else
#define DBGErr(a)
#define DBGErr1(a,b)
#define DBGErr2(a,b,c)
#define DBGErr3(a,b,c,d)
#define DBGErr4(a,b,c,d,e)
#define DBGErr5(a,b,c,d,e,f)
#define DBGErr6(a,b,c,d,e,f,g)
#endif
