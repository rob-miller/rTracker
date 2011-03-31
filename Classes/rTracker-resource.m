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

+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access {
    NSArray *paths; 
    if (access) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  // file itunes accessible
    } else {
        paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);  // files not accessible
    }
	NSString *docsDir = [paths objectAtIndex:0];
	
	DBGLog1(@"ioFilePath= %@",[docsDir stringByAppendingPathComponent:fname] );
	
	return [docsDir stringByAppendingPathComponent:fname];
}



@end
