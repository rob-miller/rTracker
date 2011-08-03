//
//  rTracker-resource.m
//  rTracker
//
//  Created by Rob Miller on 24/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "rTracker-resource.h"
#import "rTracker-constants.h"
#import "dbg-defs.h"

@implementation rTracker_resource

BOOL keyboardIsShown=NO;

+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access {
    NSArray *paths; 
    if (access) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  // file itunes accessible
    } else {
        paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);  // files not accessible
    }
	NSString *docsDir = [paths objectAtIndex:0];
	
	DBGLog(@"ioFilePath= %@",[docsDir stringByAppendingPathComponent:fname] );
	
	return [docsDir stringByAppendingPathComponent:fname];
}

// from http://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
// Text Layout Programming Guide: Counting Lines of Text
+ (unsigned int) countLines:(NSString*)str {
    
    unsigned int numberOfLines, index, stringLength = [str length];
    
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([str lineRangeForRange:NSMakeRange(index, 0)]);
    
    return numberOfLines;
}


#pragma mark -
#pragma mark navcontroller view transition

// from http://freelancemadscience.squarespace.com/fmslabs_blog/2010/10/13/changing-the-transition-animation-for-an-uinavigationcontrol.html

+ (void) myNavPushTransition:(UINavigationController*)navc vc:(UIViewController*)vc animOpt:(NSInteger)animOpt {
    [UIView 
     transitionWithView:navc.view
     duration:1.0
     options:animOpt
     animations:^{ 
         [navc 
          pushViewController:vc 
          animated:NO];
     }
     completion:NULL];
}

+ (void) myNavPopTransition:(UINavigationController*)navc animOpt:(NSInteger)animOpt {
    [UIView 
     transitionWithView:navc.view
     duration:1.0
     options:animOpt
     animations:^{ 
         [navc 
          popViewControllerAnimated:NO];
     }
     completion:NULL];
}


@end
