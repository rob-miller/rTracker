//
//  rTracker-resource.h
//  rTracker
//
//  Created by Rob Miller on 24/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

// make sqlite db files available from itunes? (perhaps prefs option later)
#define DBACCESS NO


@interface rTracker_resource : NSObject {
    //int foo;
}
+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access;
+ (unsigned int) countLines:(NSString*)str;
+ (void) myNavPushTransition:(UINavigationController*)navc vc:(UIViewController*)vc animOpt:(NSInteger)animOpt;
+ (void) myNavPopTransition:(UINavigationController*)navc animOpt:(NSInteger)animOpt;

@end

extern BOOL keyboardIsShown;

