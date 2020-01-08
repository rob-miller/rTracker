/***************
 rTrackerAppDelegate.m
 Copyright 2010-2016 Robert T. Miller
 
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
//  rTrackerAppDelegate.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "rTrackerAppDelegate.h"
#import "RootViewController.h"
#import "useTrackerController.h"
#import "dbg-defs.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"
#import "privacyV.h"
#import "trackerList.h"

#if FABRIC
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#endif

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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void) registerForNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound;

    [center requestAuthorizationWithOptions:options
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // don't care if not granted
        //if (!granted) {
        //    DBGLog(@"notification authorization not granted");
        //}
      }
    ];
}

- (void) pleaseRegisterForNotifications:(RootViewController *)rootController {
    // ios 8.1 must register for notifications
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
        if (! [rTracker_resource notificationsEnabled]) {
            
            
            if (![rTracker_resource getToldAboutNotifications]) { // if not yet told
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Authorise notifications"
                                                                               message:@"Authorise notifications in the next window to enable tracker reminders."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                        [self registerForNotifications];

                                                                          //[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                                                                      }];
                
                [alert addAction:defaultAction];
                [rootController.navigationController presentViewController:alert animated:YES completion:nil];
                
                
                
                [rTracker_resource setToldAboutNotifications:true];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toldAboutNotifications"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        
        //[rTracker_resource alert:@"" msg:@"Authorise notifications to use tracker reminders." vc:rootController];
    }
    
}


//- (void)applicationDidFinishLaunching:(UIApplication *)application {
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#if FABRIC
    //[Fabric with:@[CrashlyticsKit]];
    [Fabric with:@[[Crashlytics class]]];
#endif
    
#if !RELEASE
    DBGWarn(@"docs dir= %@",[rTracker_resource ioFilePath:nil access:YES]);
#endif
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

    [rTracker_resource setToldAboutNotifications:[sud boolForKey:@"toldAboutNotifications"]];
    
    // Override point for customization after app launch    

	// fix 'Application windows are expected to have a root view controller at the end of application launch'
    //   as found in http://stackoverflow.com/questions/7520971
    
    //[self.window addSubview:[navigationController view]];
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];

    DBGLog(@"product %@ version %@ build %@  db_ver %d  fn_ver %d samples_ver %d demos_ver %d",
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
           RTDB_VERSION,RTFN_VERSION,SAMPLES_VERSION, DEMOS_VERSION
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

    
    
#if ADVERSION
    [rTracker_resource replaceRtrackerA:rootController];
#else
    //if (![rTracker_resource getAcceptLicense]) {

    if (! [sud boolForKey:@"acceptLicense"]) { // race relying on rvc having set
        NSString *freeMsg= @"Copyright 2010-2020 Robert T. Miller\n\nrTracker is free and open source software, distributed under the Apache License, Version 2.0.\n\nrTracker is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n\nrTracker source code is available at https://github.com/rob-miller/rTracker\n\nThe full Apache License is available at http://www.apache.org/licenses/LICENSE-2.0";
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"rTracker is free software.\n"
                                                                       message:freeMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [rTracker_resource setAcceptLicense:YES];
                                                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"acceptLicense"];
                                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                                  
                                                                  [self pleaseRegisterForNotifications:rootController];
                                                              }];

        UIAlertAction* recoverAction = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) { exit(0); }];
        
        [alert addAction:defaultAction];
        [alert addAction:recoverAction];
        
        [rootController.navigationController presentViewController:alert animated:YES completion:nil];
    }
#endif
    
        


/*
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
*/
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if (nil != shortcutItem){
            [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:(shortcutItem.userInfo)[@"tid"] waitUntilDone:NO];
            return NO;  // http://stackoverflow.com/questions/32634024/3d-touch-home-shortcuts-in-obj-c
        }
    }
    
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString *bdn = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    DBGLog(@"openURL %@",url);
    DBGLog(@"bundle id: %@",bdn);

    RootViewController *rootController = (self.navigationController.viewControllers)[0];

    int tid;
    NSString *urlas = [url absoluteString];
    const char *curl = [urlas UTF8String];
    NSString *base = [NSString stringWithFormat:@"%@://",bdn];
    const char *format = [[NSString stringWithFormat:@"%@tid=%%d",base ] UTF8String];
    
    if (1 == sscanf(curl,format,&tid)) {   // correct match to URL scheme with tid
        DBGLog(@"curl=%s format=%s tid=%d",curl,format,tid);
        
        trackerList *tlist = rootController.tlist;
        [tlist loadTopLayoutTable];
        if ([tlist.topLayoutIDs containsObject:[NSNumber numberWithInt:tid]]) {
            [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:[NSNumber numberWithInt:tid] waitUntilDone:NO];
        } else {
            [rTracker_resource alert:@"no tracker found" msg:[NSString stringWithFormat:@"No tracker with ID %d found in %@.  Edit the tracker, tap the ⚙, and look in 'database info' for the tracker id.",tid,bdn] vc:rootController];
        }
        
    } else if ([urlas isEqualToString:base]) {
        // do nothing because rTracker:// should open with default trackerList page
    } else if ([urlas hasPrefix:base] || [urlas hasPrefix:[base lowercaseString]]) { // looks like our URL scheme but some errors
        DBGLog(@"sscanf fail curl=%s format=%s",curl,format);
        [rTracker_resource alert:@"bad URL" msg:[NSString stringWithFormat:@"URL received was %@ but should look like %s",[url absoluteString],format] vc:rootController];
    }

    


    //RootViewController *rootController = (RootViewController *) [navigationController.viewControllers objectAtIndex:0];
    //rootController.inputURL=url;
    //[self.navigationController popToRootViewControllerAnimated:NO];

    return YES;
        
}

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
    //DBGLog(@"qalert title: %@ msg: %@",title,msg);
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

/*
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
  }
*/


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//DBGLog(@"rt app delegate: app will terminate");
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (BOOL)checkNotificationType:(UIUserNotificationType)type
{
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    return (currentSettings.types & type);
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
    if ([self checkNotificationType:UIUserNotificationTypeBadge]) {  // minimum version is iOS 8 currently (14.iv.2016)
        application.applicationIconBadgeNumber = [(RootViewController *)rootController pendingNotificationCount];
    }
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
    
	//DBGLog(@"rt app delegate: app did become active");

    //[(RootViewController *) [self.navigationController.viewControllers objectAtIndex:0] viewDidAppear:YES];

    //[rTracker_resource enableOrientationData];

    [self.navigationController.visibleViewController viewDidAppear:YES];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    RootViewController *rootController = (self.navigationController.viewControllers)[0];
    [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:(shortcutItem.userInfo)[@"tid"] waitUntilDone:NO];
}

#pragma mark -
#pragma mark Memory management



@end

