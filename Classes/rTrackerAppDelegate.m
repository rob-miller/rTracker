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
#import "rTracker-constants.h"

@implementation rTrackerAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"reload_sample_trackers_pref"]) {
        ((RootViewController *) [self.navigationController.viewControllers objectAtIndex:0]).initialPrefsLoad = YES;

         NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
         NSString  *settingsPropertyListPath = [mainBundlePath
                                                stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
         
         NSDictionary *settingsPropertyList = [NSDictionary 
                                               dictionaryWithContentsOfFile:settingsPropertyListPath];
         
         NSMutableArray     *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
         NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
         
         for (int i = 0; i < [preferenceArray count]; i++)  { 
             NSString  *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
             
             if (key)  {
                 id  value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                 [registerableDictionary setObject:value forKey:key];
             }
         }
         
         [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary]; 
         [[NSUserDefaults standardUserDefaults] synchronize]; 
    }
    
    // Override point for customization after app launch    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];

    DBGLog(@" rTracker version %@ build %@  db_ver %d  fn_ver %d samples_ver %d",
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"RTMbuild"],
           RTDB_VERSION,RTFN_VERSION,SAMPLES_VERSION
           );
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

/*
// does not make utc disappear before first visible
 - (void) applicationWillBecomeActive:(UIApplication *)application {
	DBGLog(@"rt app delegate: app will become active");
    [self.navigationController.visibleViewController viewWillAppear:YES];
}
*/
- (void)applicationDidBecomeActive:(UIApplication *)application {
	// rootViewController needs to possibly load files
    // useTrackerController needs to detect if displaying a private tracker
    
	DBGLog(@"rt app delegate: app did become active");
    //[(RootViewController *) [self.navigationController.viewControllers objectAtIndex:0] viewDidAppear:YES];

    [self.navigationController.visibleViewController viewDidAppear:YES];
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

