//
//  rTrackerAppDelegate.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "rTrackerAppDelegate.h"
#import "RootViewController.h"
#import "useTrackerController.h"
#import "dbg-defs.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"
#import "privacyV.h"


#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#if SHOWTOUCHES
#import "GSTouchesShowingWindow.h"
#endif

#if ADVERSION
#import "rt_IAPHelper.h"
#endif

@implementation rTrackerAppDelegate

@synthesize window=_window;
@synthesize navigationController=_navigationController;
@synthesize pendingTid=_pendingTid;

#if SHOWTOUCHES
- (GSTouchesShowingWindow *)window {
    static GSTouchesShowingWindow *window = nil;
    if (!window) {
        window = [[GSTouchesShowingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return window;
}
#endif

#pragma mark -
#pragma mark Application lifecycle

//- (void)applicationDidFinishLaunching:(UIApplication *)application {
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Fabric with:@[CrashlyticsKit]];

    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    [sud synchronize];
    
#if ADVERSION
    [rTracker_resource setPurchased:[sud boolForKey:RTA_prodid]];
    if (![rTracker_resource getPurchased]) {
        [rt_IAPHelper sharedInstance];
    }
#endif

    RootViewController *rootController = (RootViewController *) (self.navigationController.viewControllers)[0];
    
    if (nil == [sud objectForKey:@"reload_sample_trackers_pref"]) {

        //((RootViewController *) [self.navigationController.viewControllers objectAtIndex:0]).initialPrefsLoad = YES;
        rootController.initialPrefsLoad = YES;

         NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
         NSString  *settingsPropertyListPath = [mainBundlePath
                                                stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
         
         NSDictionary *settingsPropertyList = [NSDictionary 
                                               dictionaryWithContentsOfFile:settingsPropertyListPath];
         
         NSMutableArray     *preferenceArray = settingsPropertyList[@"PreferenceSpecifiers"];
         NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
         
         for (int i = 0; i < [preferenceArray count]; i++)  { 
             NSString  *key = preferenceArray[i][@"Key"];
             
             if (key)  {
                 id  value = preferenceArray[i][@"DefaultValue"];
                 registerableDictionary[key] = value;
             }
         }
         
         [sud registerDefaults:registerableDictionary];
         [sud synchronize];
    }
    
    // Override point for customization after app launch    

	// fix 'Application windows are expected to have a root view controller at the end of application launch'
    //   as found in http://stackoverflow.com/questions/7520971
    
    //[self.window addSubview:[navigationController view]];
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];

    DBGLog(@"product %@ version %@ build %@  db_ver %d  fn_ver %d samples_ver %d",
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
           RTDB_VERSION,RTFN_VERSION,SAMPLES_VERSION
           );
/*
    if ([@"rTrackerA" isEqualToString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]]) {
#if !ADVERSION 
        [rTracker_resource alert:@"rTrackerA version error" msg:@"bundle rTrackerA but ADVERSION not set" vc:nil];
        DBGErr(@"bundle rTrackerA but ADVERSION not set");
#endif
    } else {
#if ADVERSION
        [rTracker_resource alert:@"rTracker version error" msg:@"bundle not rTrackerA but ADVERSION is set" vc:nil];
        DBGErr(@"bundle not rTrackerA but ADVERSION is set");
#endif
    }
 */
    //NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    // docs say app openURL below is called anyway, so don't do here which is only if app not already open
    //
    // if (url != nil && [url isFileURL]) {
    //    [rootController handleOpenFileURL:url];
    //}
    //DBGLog(@"rt app delegate: app did finish launching");

    [rTracker_resource initHasAmPm];

    // ios 8.1 must register for notifications
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
    
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

    }
    
    // for when actually not running, not just in background:
    UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (nil != notification) {
        DBGLog(@"responding to local notification with msg : %@",notification.alertBody);
        //[rTracker_resource alert:@"launched with locNotification" msg:notification.alertBody];
        //NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
        //[sud synchronize];
        [rTracker_resource setToldAboutSwipe:[sud boolForKey:@"toldAboutSwipe"]];

        [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:(notification.userInfo)[@"tid"] waitUntilDone:NO];
    }
    
    
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    DBGLog(@"openURL %@",url);
    //RootViewController *rootController = (RootViewController *) [navigationController.viewControllers objectAtIndex:0];
    //rootController.inputURL=url;
    
    //[self.navigationController popToRootViewControllerAnimated:NO];

    return YES;
        
}


/*
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
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIViewController *rootController = (self.navigationController.viewControllers)[0];
    if (0 == buttonIndex) {   // do nothing
    } else {                  // go to the pending tracker
        [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:self.pendingTid waitUntilDone:NO];
    }
}


- (void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (UIAlertView*) quickAlert:(NSString*)title msg:(NSString*)msg {
    DBGLog(@"qalert title: %@ msg: %@",title,msg);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title message:msg
                          delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:nil];
    [alert show];
    //[alert release];
    return alert;
}

-(void) dismissAlertController:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:(BOOL)YES
                                        completion:nil];
}

-(void) doQuickAlert:(NSString*)title msg:(NSString*)msg delay:(int) delay {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIAlertView *alert = [self quickAlert:title msg:msg];
        [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:delay];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        [self performSelector:@selector(dismissAlertController:) withObject:alert afterDelay:delay];
        
        
        
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //
    
    DBGLog(@"notification from tid %@",[notification.userInfo objectForKey:@"tid"]);
    
    if ([application applicationState] == UIApplicationStateActive) {
        DBGLog(@"app is active!");
        [rTracker_resource playSound:notification.soundName];
        [self doQuickAlert:notification.alertAction msg:notification.alertBody delay:2];
    } else {
        RootViewController *rootController = (self.navigationController.viewControllers)[0];
        [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:(notification.userInfo)[@"tid"] waitUntilDone:NO];
    }
    //[rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:[notification.userInfo objectForKey:@"tid"] waitUntilDone:NO];
    
    /*
    UIViewController *topController = [self.navigationController.viewControllers lastObject];

    if (topController == rootController) {
        //[self doQuickAlert:notification.alertAction msg:notification.alertBody delay:1];
        [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:[notification.userInfo objectForKey:@"tid"] waitUntilDone:NO];
    }
     */
    /*
    else {
        // going to tracker actually pushes the other viewcontroller -- so don't really need to alert and ask?
        self.pendingTid = [notification.userInfo objectForKey:@"tid"];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"rTracker reminder"
                              message:notification.alertBody
                              delegate:self
                              cancelButtonTitle:@"later"
                              otherButtonTitles:@"go there now",nil];
        [alert show];
        [alert release];

    }
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//DBGLog(@"rt app delegate: app will terminate");
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    resigningActive=YES;
	// Save data if appropriate
	//DBGLog(@"rt app delegate: app will resign active");
    UIViewController *rootController = (self.navigationController.viewControllers)[0];
    UIViewController *topController = [self.navigationController.viewControllers lastObject];
    
    [((RootViewController *)rootController).privacyObj lockDown];  // hiding is handled after startup - viewDidAppear() below
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    SEL rtSelector = NSSelectorFromString(@"rejectTracker");
    
    if ( [topController respondsToSelector:rtSelector] ) {  // leaving so reject tracker if it is rejectable
        if (((useTrackerController *) topController).rejectable) {
            //[((useTrackerController *) topController) rejectTracker];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    application.applicationIconBadgeNumber = [(RootViewController *)rootController pendingNotificationCount];
    //[rTracker_resource disableOrientationData];
    resigningActive=NO;
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

    //[rTracker_resource enableOrientationData];

    [self.navigationController.visibleViewController viewDidAppear:YES];
}

#pragma mark -
#pragma mark Memory management



@end

