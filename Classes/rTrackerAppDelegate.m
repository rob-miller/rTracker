//
//  rTrackerAppDelegate.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import "rTrackerAppDelegate.h"
#import "RootViewController.h"
#import "useTrackerController.h"
#import "dbg-defs.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"

@implementation rTrackerAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

//- (void)applicationDidFinishLaunching:(UIApplication *)application {
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RootViewController *rootController = (RootViewController *) [navigationController.viewControllers objectAtIndex:0];
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"reload_sample_trackers_pref"]) {

        //((RootViewController *) [self.navigationController.viewControllers objectAtIndex:0]).initialPrefsLoad = YES;
        rootController.initialPrefsLoad = YES;

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

	// fix 'Application windows are expected to have a root view controller at the end of application launch'
    //   as found in http://stackoverflow.com/questions/7520971
    
    //[self.window addSubview:[navigationController view]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];

    DBGLog(@" rTracker version %@ build %@  db_ver %d  fn_ver %d samples_ver %d",
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
           RTDB_VERSION,RTFN_VERSION,SAMPLES_VERSION
           );
    
    //NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    // rtm here
    // docs say app openURL below is called anyway, so don't do here which is only if app not already open
    //
    // if (url != nil && [url isFileURL]) {
    //    [rootController handleOpenFileURL:url];
    //}
    //DBGLog(@"rt app delegate: app did finish launching");

    return YES;
}

- (void) doOpenURL:(NSURL*)url {
    
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    RootViewController *rootController = (RootViewController *) [navigationController.viewControllers objectAtIndex:0];
    //if (url != nil && [url isFileURL]) {
    int tid = [rootController handleOpenFileURL:url tname:nil];
    if (0 != tid) {
        // get to root view controller, else get last view on stack
        [self.navigationController popToRootViewControllerAnimated:NO];
        [rootController openTracker:tid rejectable:YES];
    }
    //}
    
    //[rTracker_resource finishActivityIndicator:rootController.view navItem:nil disable:NO];
    
    //[pool drain];
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    DBGLog(@"openURL %@",url);
    //RootViewController *rootController = (RootViewController *) [navigationController.viewControllers objectAtIndex:0];
    //[rTracker_resource startActivityIndicator:rootController.view navItem:nil disable:NO];
    
    //[NSThread detachNewThreadSelector:@selector(doOpenURL:) toTarget:self withObject:url];
    [self doOpenURL:url];
    
    return YES;
        
}
    
- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//DBGLog(@"rt app delegate: app will terminate");
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Save data if appropriate
	//DBGLog(@"rt app delegate: app will resign active");
    UIViewController *rootController = [self.navigationController.viewControllers objectAtIndex:0];
    UIViewController *topController = [self.navigationController.viewControllers lastObject];
    
    [((RootViewController *)rootController).privacyObj lockDown];
    
    SEL rtSelector = NSSelectorFromString(@"rejectTracker");
    
    if ( [topController respondsToSelector:rtSelector] ) {
        if (((useTrackerController *) topController).rejectable) {
            //[((useTrackerController *) topController) rejectTracker];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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
    
	//DBGLog(@"rt app delegate: app did become active");
    //[(RootViewController *) [self.navigationController.viewControllers objectAtIndex:0] viewDidAppear:YES];

    [self.navigationController.visibleViewController viewDidAppear:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	//DBGLog(@"rt app delegate: dealloc");
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

