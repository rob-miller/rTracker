/***************
 dbg-defs.h
 Copyright 2011-2021 Robert T. Miller
 
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
//  dbg-defs.h
//  rTracker
//
//  Created by Rob Miller on 30/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//


#define RELEASE     0

#define DEBUGLOG    1
#define DEBUGWARN   1
#define DEBUGERR    1

// enable additional debugging code in these sections
#define SQLDEBUG    0
#define FUNCTIONDBG 0
#define REMINDERDBG 0
#define GRAPHDBG    0


// enable advertising code -- controlled in Xcode build settings (Apple LLVM -> Preprocessing -> Preprocessor macros) for rTrackerA
//#define ADVERSION   0

// advertisements disabled - open source - no revenue -- code left in place as documentation/example for interested parties
#define DISABLE_ADS 1


// enable Lukas Petr's GSTouchesShowingWindow (https://github.com/LukasCZ/GSTouchesShowingWindow - not included here)
#define SHOWTOUCHES 0

// enable Fabric Crashlytics crash reporting (https://try.crashlytics.com/ - not included here)
#define FABRIC      0

// disable attempts to extract device owner's name and use for main screen title line ("rob's tracks")
#define NONAME      0


// iOS Version Checking
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



// implementation for debug messages:

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
