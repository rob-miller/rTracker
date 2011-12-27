//
//  rTrackerAppDelegate.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import "rTrackerAppDelegate.h"
#import "RootViewController.h"
#import "dbg-defs.h"

@implementation rTrackerAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];

	DBGLog(@"rt app delegate: app did finish launching");
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	DBGLog(@"rt app delegate: app will terminate");
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Save data if appropriate
	DBGLog(@"rt app delegate: app will resign active");
    [((RootViewController *) [self.navigationController.viewControllers objectAtIndex:0]).privacyObj lockDown];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	DBGLog(@"rt app delegate: dealloc");
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

