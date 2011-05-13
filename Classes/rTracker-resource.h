//
//  rTracker-resource.h
//  rTracker
//
//  Created by Rob Miller on 24/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DBACCESS YES


@interface rTracker_resource : NSObject {
    //int foo;
}
+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access;
+ (unsigned int) countLines:(NSString*)str;

@end

extern BOOL keyboardIsShown;

