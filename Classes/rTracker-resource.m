/***************
 rTracker-resource.m
 Copyright 2011-2016 Robert T. Miller
 
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
//  rTracker-resource.m
//  rTracker
//
//  Created by Rob Miller on 24/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "rTracker-resource.h"
#import "rTracker-constants.h"
#import "dbg-defs.h"
#import "rt_IAPHelper.h"
#import "numField.h"

#import <AudioToolbox/AudioToolbox.h>
#import <CoreText/CTTypesetter.h>

@implementation rTracker_resource

BOOL keyboardIsShown=NO;
UIView *currKeyboardView=nil;
CGRect currKeyboardSaveFrame;
BOOL resigningActive=NO;

// found syntax for this here :
// https://stackoverflow.com/questions/5225130/grand-central-dispatch-gcd-vs-performselector-need-a-better-explanation/5226271#5226271
// https://stackoverflow.com/a/8186206/2783487
void safeDispatchSync(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


//---------------------------

// Sample code from iOS 7 Transistion Guide
// Loading Resources Conditionally

NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."][0] intValue];
    });
    return _deviceSystemMajorVersion;
}

//---------------------------

+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access {
    NSArray *paths; 
    if (access) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  // file itunes accessible
    } else {
        paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);  // files not accessible
    }
	NSString *docsDir = paths[0];
	
	//DBGLog(@"ioFilePath= %@",[docsDir stringByAppendingPathComponent:fname] );
	
	return [docsDir stringByAppendingPathComponent:fname];
}

+ (BOOL) deleteFileAtPath:(NSString*)fp {
    NSError *err;
    if (YES == [[NSFileManager defaultManager] fileExistsAtPath:fp]) {
        DBGLog(@"deleting file at path %@",fp);
        if (YES != [[NSFileManager defaultManager] removeItemAtPath:fp error:&err]) {
            DBGErr(@"Error deleting file: %@ error: %@", fp, err);
            return NO;
        }
        return YES;
    } else {
        DBGLog(@"request to delete non-existent file at path %@",fp);
        return YES;
    }
}
+ (BOOL) protectFile:(NSString*)fp {
    // not needed because NSFileProtectionComplete enabled at app level

    NSError *err;
    /*
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
    if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:fp error:&err]) {
    */
    
    if (![[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey:NSFileProtectionComplete} ofItemAtPath:fp error:&err]) {
        DBGErr(@"Error protecting file: %@ error: %@", fp, err);
            return NO;
    }
    return YES;
}

BOOL loadingDemos=NO;

//---------------------------
BOOL hasAmPm=NO;

+ (void) initHasAmPm {
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    hasAmPm = containsA.location != NSNotFound;
    
}
//---------------------------

// from http://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
// Text Layout Programming Guide: Counting Lines of Text
+ (NSUInteger) countLines:(NSString*)str {
    
    NSUInteger numberOfLines, index, stringLength = [str length];
    
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([str lineRangeForRange:NSMakeRange(index, 0)]);
    
    return numberOfLines;
}

//---------------------------

+ (UIButton*) getCheckButton:(CGRect)frame {
    UIButton *_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_checkButton setBackgroundColor:[UIColor clearColor]];
    
    _checkButton.frame = frame; //CGRectZero;
    
    [[_checkButton layer] setCornerRadius:8.0f];
    [[_checkButton layer] setMasksToBounds:YES];
    [[_checkButton layer] setBorderWidth:1.0f];
    
    //[_checkButton setTitle:@"\u2714" forState:UIControlStateNormal];
    [_checkButton setTitle:@"" forState:UIControlStateNormal];
    [_checkButton setBackgroundColor:[UIColor whiteColor]];
    _checkButton.titleLabel.font = PrefBodyFont;
    _checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter; //Center;;  // UIControlContentHorizontalAlignmentRight; //Center;
    
    return _checkButton;
}

+(void) setCheckButton:(UIButton*)cb colr:(UIColor*)colr {
    if (colr) {
        [cb setBackgroundColor:colr];
    }
    [cb setTitle:@"\u2714" forState:UIControlStateNormal];
}

+(void) clrCheckButton:(UIButton*)cb colr:(UIColor*)colr {
    if (colr) {
        [cb setBackgroundColor:colr];
    }
    [cb setTitle:@"" forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark generic alert
//---------------------------
+ (void) alert:(NSString*)title msg:(NSString*)msg vc:(UIViewController*)vc {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title message:msg
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        
        if (nil == vc) {
            UIWindow *w = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            w.rootViewController = [UIViewController new];
            w.windowLevel = UIWindowLevelAlert +1;
            [w makeKeyAndVisible];
            vc = w.rootViewController;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [vc presentViewController:alert animated:YES completion:nil];
        });
    }
}

#pragma mark -
#pragma mark in-app purchase and ad support

#if ADVERSION

+(void) handleUpgradeOptions:(NSInteger)choice {
    if ( choice == 1 ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/rtracker/id486541371"]];
    } else if ( choice == 2 ) {
        DBGLog(@"in app upgrade!");
        
        [[rt_IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                DBGLog(@"success: %lu products",(unsigned long)[products count]);
                NSArray *_products = products;
                for (SKProduct *skp in _products) {
                    DBGLog(@"Product title: %@" , skp.localizedTitle);
                    DBGLog(@"Product description: %@" , skp.localizedDescription);
                    DBGLog(@"Product price: %@" , skp.price);
                    DBGLog(@"Product id: %@" , skp.productIdentifier);
                    
                    if ([RTA_prodid isEqualToString:skp.productIdentifier]) {
                        [[rt_IAPHelper sharedInstance] buyProduct:skp];  // currently only one product !!!!!
                    }
                    
                }
            } else {
                DBGLog(@"fail");
            }
            
        }];
        
        
        DBGLog(@"done.");
        
    } else if ( choice == 3 ) {
        [[rt_IAPHelper sharedInstance] restoreCompletedTransactions];
    } else if ( choice == 4 ) {
        [rTracker_resource setPurchased:YES];
    }

}

+ (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [rTracker_resource handleUpgradeOptions:buttonIndex];
}

+ (void) buy_rTrackerAlert {
    NSString *title = @"Upgrade to rTracker";
    NSString *msg = [NSString stringWithFormat:@"\nrTrackerA is advertising supported and limited to %d trackers of %d items.\n\nPlease buy rTracker, which does not have advertisements or limits.\n\nUse the 'email tracker+data' functionality to transfer your existing trackers to rTracker (email to yourself, open the attachment in rTracker from Mail on your iOS device - you may need to look in your sent mail folder).\n\nOr use the In-App upgrade button below to continue using rTrackerA without ads or limits.  Please note that the In-App upgraded product costs more and seems to get updates later.",ADVER_TRACKER_LIM, ADVER_ITEM_LIM];
    NSString *btn0 = @"Not now";
    NSString *btn1 = @"Get rTracker";
    NSString *btn2 = @"In-App Upgrade";
    NSString *btn3 = @"Restore In-App Upgrade";
#if !RELEASE
    NSString *btn4 = @"set Purchased";
#endif
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:btn0
                                               otherButtonTitles:btn1,btn2,btn3,
#if !RELEASE
                               btn4,
#endif
                               nil];
        [_alert show];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* skipAction = [UIAlertAction actionWithTitle:btn0 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        UIAlertAction* getAction = [UIAlertAction actionWithTitle:btn1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [rTracker_resource handleUpgradeOptions:1]; }];
        UIAlertAction* inappAction = [UIAlertAction actionWithTitle:btn2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [rTracker_resource handleUpgradeOptions:2]; }];
        UIAlertAction* restoreAction = [UIAlertAction actionWithTitle:btn3 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {  [rTracker_resource handleUpgradeOptions:3]; }];
        
        [alert addAction:skipAction];
        [alert addAction:getAction];
        [alert addAction:inappAction];
        [alert addAction:restoreAction];

#if !RELEASE
        UIAlertAction* purchaseAction = [UIAlertAction actionWithTitle:btn4 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {  [rTracker_resource handleUpgradeOptions:4]; }];
        [alert addAction:purchaseAction];
#endif
        UIViewController* vc;
        UIWindow *w = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        w.rootViewController = [UIViewController new];
        w.windowLevel = UIWindowLevelAlert +1;
        [w makeKeyAndVisible];
        vc = w.rootViewController;
        
        [vc presentViewController:alert animated:YES completion:nil];
    }
}

//----

/*  defined elsewhere in this file and no buttons
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 if (0 == buttonIndex) {   // do nothing
 }
 }
 */

+ (void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

+ (UIAlertView*) quickAlert:(NSString*)title msg:(NSString*)msg {
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

+(void) dismissAlertController:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:(BOOL)YES
                                        completion:nil];
}

+(void) doQuickAlert:(NSString*)title msg:(NSString*)msg delay:(int) delay vc:(UIViewController*)vc {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIAlertView *alert = [rTracker_resource quickAlert:title msg:msg];
        [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:delay];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [vc presentViewController:alert animated:YES completion:nil];
        [rTracker_resource performSelector:@selector(dismissAlertController:) withObject:alert afterDelay:delay];
    }
}

+(void) replaceRtrackerA:(UIViewController*)vc {
    [rTracker_resource alert:@"rTracker is free" msg:@"rTrackerA is being removed from the app store.\n\nPlease install rTracker, which is now free and open source.\n\nSee the help pages for instructions on how to transfer trackers between these applications (tl;dr : email tracker+data to yourself, open attachment with rTracker)." vc:vc];
}
//----
#endif



//---------------------------
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

//---------------------------

+ (NSArray *) colorSet {
	return @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor],
                [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor],
                [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], 
                [UIColor whiteColor], [UIColor lightGrayColor], [UIColor darkGrayColor]];
		
}

+ (NSArray *) colorNames {
	return @[@"red", @"green", @"blue",
            @"cyan", @"yellow", @"magenta",
            @"orange", @"purple", @"brown", 
            @"white", @"lightGray", @"darkGray"];
}

+ (NSArray*) vtypeNames {
    // indexes must match defns in valueObj.h 
    return @[@"number", @"text", @"textbox", @"slider", @"choice", @"yes/no", @"function", @"info"];
}


//---------------------------
#pragma mark -
#pragma mark activity indicator support

static UIActivityIndicatorView *activityIndicator=nil;
static UIView *outerView;
static UILabel *captionLabel;

static BOOL activityIndicatorGoing=NO;
static BOOL progressBarGoing=NO;

+ (void) startActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable str:(NSString*)str {
    DBGLog(@"start spinner");
    __block BOOL skip=NO;
    safeDispatchSync(^{
        if (activityIndicatorGoing)
            skip=YES;
        activityIndicatorGoing=YES;
    });
    if (skip) return;
    
    if (disable) {
        view.userInteractionEnabled = NO;
        //[navItem setHidesBackButton:YES animated:YES];
        navItem.leftBarButtonItem.enabled = NO;
        navItem.rightBarButtonItem.enabled = NO;
    }
    
    outerView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    outerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    outerView.clipsToBounds = YES;
    outerView.layer.cornerRadius = 10.0;

    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge ];
    //activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray ];
    //activityIndicator.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
    activityIndicator.frame = CGRectMake(65, 40, activityIndicator.bounds.size.width, activityIndicator.bounds.size.height);

    //activityIndicator.backgroundColor = [UIColor blackColor];
    
    //activityIndicator.center = outerView.center;
    
    [outerView addSubview:activityIndicator];
    [activityIndicator startAnimating];

    captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter ;  // ios6 UITextAlignmentCenter;
    captionLabel.text = str;
    [outerView addSubview:captionLabel];

    //[activityIndicator performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];

    [view addSubview:outerView];
    DBGLog(@"spinning");

}

+ (void) finishActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
    DBGLog(@"stop spinner");

    //if (! activityIndicatorGoing) return;  // race condition, may not be set yet so ignore
    
    safeDispatchSync(^(void){
        if (disable) {
            //[navItem setHidesBackButton:NO animated:YES];
            navItem.rightBarButtonItem.enabled = YES;
            view.userInteractionEnabled = YES;
        }
        
        //[activityIndicator stopAnimating];
        [activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        
        [outerView removeFromSuperview];
        
        activityIndicator = nil;
        captionLabel = nil;
        outerView = nil;
        activityIndicatorGoing=NO;
    });
    DBGLog(@"not spinning");

}

static UIProgressView *progressBar=nil;

+ (void) startProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable yloc:(CGFloat)yloc {
    
    if (disable) {
        view.userInteractionEnabled = NO;
        //[navItem setHidesBackButton:YES animated:YES];
        navItem.leftBarButtonItem.enabled = NO;
        navItem.rightBarButtonItem.enabled = NO;
    }
    
    //progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault ];
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar ];
    CGRect pbFrame = progressBar.frame;
    CGRect vFrame = view.frame;
    pbFrame.size.width = vFrame.size.width;
    
    //pbFrame.origin.y = 70.0;
    pbFrame.origin.y = yloc;
    DBGLog(@"progressbar yloc= %f",yloc);
    
    //pbFrame.size.height = 550;
    progressBar.frame = pbFrame;
    
    //progressBar.center = view.center;
    progressBarGoing=YES;
    [view addSubview:progressBar];
    //[view bringSubviewToFront:progressBar];
    //[progressBar startAnimating];
    
/*
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateProgressBar) 
                                                 name:rtProgressBarUpdateNotification 
                                               object:nil];
    
  */  
    //DBGLog(@"progressBar started");
}

static float localProgressVal;

+ (void) setProgressVal:(float)progressVal {
    localProgressVal = progressVal;
    [self performSelectorOnMainThread:@selector(updateProgressBar) withObject:nil waitUntilDone:NO];
}

+ (void) updateProgressBar {
    [progressBar setProgress:localProgressVal];
    //DBGLog(@"progress bar updated: %f",localProgressVal);
}

static float localProgValTotal;
static float localProgValCurr;

+ (void) stashProgressBarMax:(int) total {
    localProgValTotal = (float) total;
    localProgValCurr = 0.0f;
}

+ (void) bumpProgressBar {
    localProgValCurr += 1.0f;
    [self setProgressVal:(localProgValCurr/localProgValTotal)];
    //DBGLog(@"setprogress %f", (localProgValCurr/localProgValTotal));
}

static UIView *localView;
static UINavigationItem *localNavItem;
static BOOL localDisable;

+ (void) doFinishProgressBar {
    if (localDisable) {
        //[localNavItem setHidesBackButton:NO animated:YES];
        localNavItem.leftBarButtonItem.enabled = YES;
        localNavItem.rightBarButtonItem.enabled = YES;
        localView.userInteractionEnabled = YES;
    }
    
    //[progressBar stopAnimating];

    [progressBar removeFromSuperview];
    progressBar = nil;
    progressBarGoing=NO;
    //DBGLog(@"progressbar finished");
    
}

+ (void) finishProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
    if (!progressBarGoing) return;
    localView = view;
    localNavItem = navItem;
    localDisable = disable;
    [self performSelectorOnMainThread:@selector(doFinishProgressBar) withObject:nil waitUntilDone:YES];
}

//---------------------------
#pragma mark -
#pragma mark option settings to remember

static BOOL separateDateTimePicker=SDTDFLT;

+ (BOOL)getSeparateDateTimePicker {
	return separateDateTimePicker;
}

+ (void)setSeparateDateTimePicker:(BOOL)sdt {
	separateDateTimePicker = sdt;
	//DBGLog(@"updateSeparateDateTimePicker:%d",separateDateTimePicker);
}

static BOOL rtcsvOutput=RTCSVOUTDFLT;

+ (BOOL)getRtcsvOutput {
	return rtcsvOutput;
}

+ (void)setRtcsvOutput:(BOOL)rtcsvOut {
	rtcsvOutput = rtcsvOut;
	//DBGLog(@"updateRtcsvOutput:%d",rtcsvOutput);
}

static BOOL savePrivate=SAVEPRIVDFLT;

+ (BOOL)getSavePrivate {
	return savePrivate;
}

+ (void)setSavePrivate:(BOOL)savePriv {
	savePrivate = savePriv;
	//DBGLog(@"updateSavePrivate:%d",savePrivate);
}

static BOOL acceptLicense=ACCEPTLICENSEDFLT;

+ (BOOL)getAcceptLicense {
    return acceptLicense;
}

+ (void)setAcceptLicense:(BOOL)acceptLic {
    acceptLicense = acceptLic;
    //DBGLog(@"updateAcceptLicense:%d",acceptLicense);
}

/*
 // can't set more than 4 :-(
 
static NSUInteger SCICount=SCICOUNTDFLT;

+ (NSUInteger)getSCICount {
    return SCICount;
}
+ (void)setSCICount:(NSUInteger)saveSCICount {
    SCICount = saveSCICount;
}
*/

/*
static BOOL hideRTimes=HIDERTIMESDFLT;
 
 + (BOOL)getHideRTimes {
	return hideRTimes;
}

+ (void)setHideRTimes:(BOOL)hideRT {
	hideRTimes = hideRT;
	DBGLog(@"updateHideRTimes:%d",hideRTimes);
}
*/

static BOOL toldAboutSwipe=false;

+ (BOOL)getToldAboutSwipe {
	return toldAboutSwipe;
}

+ (void)setToldAboutSwipe:(BOOL)toldSwipe {
	toldAboutSwipe = toldSwipe;
	DBGLog(@"updateToldAboutSwipe:%d",toldAboutSwipe);
}

static BOOL toldAboutNotifications=false;

+ (BOOL)getToldAboutNotifications {
    return toldAboutNotifications;
}

+ (void)setToldAboutNotifications:(BOOL)toldNotifications {
    toldAboutNotifications = toldNotifications;
    DBGLog(@"updateToldAboutNotifications:%d",toldAboutNotifications);
}

+ (BOOL)notificationsEnabled {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        return (types & UIUserNotificationTypeAlert);
    }
    else {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
}

#if ADVERSION

static BOOL purchased=false;

+ (BOOL)getPurchased {
    return purchased;
}

+ (void)setPurchased:(BOOL)inPurchased {
    purchased = inPurchased;
    DBGLog(@"setPurchased:%d",inPurchased);
    if (inPurchased) {
        [[NSNotificationCenter defaultCenter] postNotificationName:rtPurchasedNotification object:nil];
    }
}

#endif

//---------------------------

#pragma mark -
#pragma mark stash tracker

static int lastStashedTid=0;

+ (void) stashTracker:(int)tid
{
    NSString *oldFname= [NSString stringWithFormat:@"trkr%d.sqlite3",tid];
    NSString *newFname= [NSString stringWithFormat:@"stash_trkr%d.sqlite3",tid];
    NSError *error;
    
    DBGLog(@"stashing tracker %d",tid);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm copyItemAtPath:[rTracker_resource ioFilePath:oldFname access:DBACCESS]
                    toPath:[rTracker_resource ioFilePath:newFname access:DBACCESS] error:&error] != YES) {
        DBGWarn(@"Unable to copy file %@ to %@: %@", oldFname, newFname, [error localizedDescription]);
    } else {
        lastStashedTid=tid;
    }
}

+ (void) rmStashedTracker:(int)tid {
    if (-1 == tid) {
        return;
    }
    if (0 == tid) {
        if (lastStashedTid) {
            tid = lastStashedTid;
        } else {
            return;
        }
    }
    
    NSString *fname= [NSString stringWithFormat:@"stash_trkr%d.sqlite3",tid];
    NSError *error;
    
    DBGLog(@"dumping stashed tracker %d",tid);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm removeItemAtPath:[rTracker_resource ioFilePath:fname access:DBACCESS] error:&error] != YES) {
        DBGWarn(@"Unable to delete file %@: %@", fname, [error localizedDescription]);
    }
    lastStashedTid=0;
    
}

+ (void) unStashTracker:(int)tid {
    if (-1 == tid) {
        return;
    }
    NSString *oldFname= [NSString stringWithFormat:@"stash_trkr%d.sqlite3",tid];
    NSString *newFname= [NSString stringWithFormat:@"trkr%d.sqlite3",tid];
    NSError *error;

    DBGLog(@"restoring stashed tracker %d",tid);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm removeItemAtPath:[rTracker_resource ioFilePath:newFname access:DBACCESS] error:&error] != YES) {
        DBGLog(@"Unable to delete file %@: %@", newFname, [error localizedDescription]);
    }
    if ([fm moveItemAtPath:[rTracker_resource ioFilePath:oldFname access:DBACCESS]
                    toPath:[rTracker_resource ioFilePath:newFname access:DBACCESS] error:&error] != YES) {
        DBGWarn(@"Unable to move file %@ to %@: %@", oldFname, newFname, [error localizedDescription]);
    }    
}

#pragma mark -
#pragma mark sql


+ (NSString*) fromSqlStr:(NSString*) instr {
    NSString *outstr = [instr stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
    //DBGLog(@"in: %@  out: %@",instr,outstr);
    return outstr;
}

+ (NSString*) toSqlStr:(NSString*) instr {
    //DBGLog(@"in: %@",instr);
    NSString *outstr = [instr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    //DBGLog(@"in: %@  out: %@",instr,outstr);
    return outstr;
}

#pragma mark -

+ (NSString*) negateNumField:(NSString*)text {
    
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange range = [text rangeOfString:@"-"];
    if (NSNotFound == range.location) {
        return [@"-" stringByAppendingString:text];
    } else {
        return [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }

    //return [text stringByAppendingString:@"-"];
}

+ (UITextField*) rrConfigTextField:(CGRect)frame key:(NSString*)key target:(id)target delegate:(id)delegate action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text
{
    DBGLog(@" frame x %f y %f w %f h %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    UITextField *rtf;
    if (num) {
        rtf = (UITextField*) [[numField alloc] initWithFrame:frame ];
    } else {
        rtf = [[UITextField alloc] initWithFrame:frame ];
    }
    
	rtf.clearsOnBeginEditing = NO;
    
	[rtf setDelegate:delegate];
	rtf.returnKeyType = UIReturnKeyDone;
	rtf.borderStyle = UITextBorderStyleRoundedRect;
    [rtf setFont:PrefBodyFont];

	dbgNSAssert((action != nil), @"nil action");
	dbgNSAssert((target != nil), @"nil action");
	
	[rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEndOnExit];
    //[rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEnd|UIControlEventEditingDidEndOnExit];
    [rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEnd];
    
	if (num) {
        
		//rtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
        rtf.textAlignment = NSTextAlignmentRight;  // ios6 UITextAlignmentRight;
        
        rtf.keyboardType = UIKeyboardTypeDecimalPad; //number pad with decimal point but no done button 	// use the number input only
        // no done button for number pad // _dtf.returnKeyType = UIReturnKeyDone;
        // need this from http://stackoverflow.com/questions/584538/how-to-show-done-button-on-iphone-number-pad Michael Laszlo
        float appWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
        UIToolbar *accessoryView = [[UIToolbar alloc]
                                    initWithFrame:CGRectMake(0, 0, appWidth, 0.1 * appWidth)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil
                                  action:nil];
        UIBarButtonItem *done = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:rtf
                                 action:@selector(resignFirstResponder)];
        
        UIBarButtonItem *minus = [[UIBarButtonItem alloc]
                                  initWithTitle:@"-"
                                  style:UIBarButtonItemStylePlain
                                  target:rtf
                                  action:@selector(minusKey)];
        
        //[minus.action = [^{NSLog(@"Pressed the button");} copy] action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
        
        //accessoryView.items = @[space, done, space];
        accessoryView.items = @[space, done, space, minus, space];
        rtf.inputAccessoryView = accessoryView;

	}
	rtf.placeholder = place;
	
	if (text)
		rtf.text = text;
	
    return rtf;
}

//---------------------------------------
/*
+ (CGSize)frameSizeForAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width {
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    //CGFloat width = YOUR_FIXED_WIDTH;
    
    CFIndex offset = 0, length;
    CGFloat y = 0;
    do {
        length = CTTypesetterSuggestLineBreak(typesetter, offset, width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CFRelease(line);
        
        offset += length;
        y += ascent + descent + leading;
    } while (offset < [attributedString length]);
    
    CFRelease(typesetter);
    
    return CGSizeMake(width, ceil(y));
}
 */
//---------------------------------------

#pragma mark -
#pragma mark keyboard support

+ (void) willShowKeyboard:(NSNotification*)n view:(UIView*)view boty:(CGFloat)boty {

    if (keyboardIsShown) { // need bit more logic to handle additional scrolling for another textfield
        return;
    }
	
	DBGLog(@"handling keyboard will show: %@",[n object]);
    currKeyboardView = view;
	currKeyboardSaveFrame = view.frame;

    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = userInfo[UIKeyboardFrameEndUserInfoKey];  //FrameBeginUserInfoKey
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
    CGRect viewFrame = view.frame;
    CGFloat topk = viewFrame.size.height - keyboardSize.height;  // - viewFrame.origin.y;
	
    if (boty <= topk) {
		DBGLog(@"activeField visible, do nothing  boty= %f  topk= %f",boty,topk);
	} else {
		DBGLog(@"activeField hidden, scroll up  boty= %f  topk= %f",boty,topk);
        viewFrame.origin.y -= (boty - topk);

		//viewFrame.size.height -= self.navigationController.toolbar.frame.size.height;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
        
        if ([view respondsToSelector:@selector(flashScrollIndicators)]) {  // if is scrollview
            UIScrollView *sv = (UIScrollView*) view;
            CGPoint scrollPos = [sv contentOffset];
            scrollPos.y += (boty - topk);
            [sv setContentOffset:scrollPos];
        } else {
            [view setFrame:viewFrame];
        }
        
		[UIView commitAnimations];
	}
	
    keyboardIsShown = YES;

}

+ (void) willHideKeyboard {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[currKeyboardView setFrame:currKeyboardSaveFrame];
	
	[UIView commitAnimations];
	
    keyboardIsShown = NO;
    currKeyboardView = nil;
}

#pragma mark -
#pragma mark audio

static SystemSoundID sound1;

void systemAudioCallback (SystemSoundID ssID,void *clientData) {
    AudioServicesRemoveSystemSoundCompletion(sound1);
    AudioServicesDisposeSystemSoundID(sound1);
}

+(void) playSound:(NSString *) soundFileName {
    
    if (nil == soundFileName) {
        return;
    }
    
    NSURL *soundURL = [[NSBundle mainBundle]
                       URLForResource:soundFileName
                       withExtension:nil
                       //subdirectory:@"sounds"
                       ];
    
    DBGLog(@"soundfile = %@ soundurl= %@",soundFileName,soundURL);
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound1);
    AudioServicesAddSystemSoundCompletion(sound1,
                                          NULL,
                                          NULL,
                                          systemAudioCallback,
                                          NULL);
    
    AudioServicesPlayAlertSound(sound1);
}



//---------------------------
#pragma mark -
#pragma mark launchImage support

// figure out launchImage
/*
static BOOL getOrientEnabled=false;

+(void) enableOrientationData
{
    if (getOrientEnabled) return;
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    getOrientEnabled=true;
}
+(void) disableOrientationData
{
    if (! getOrientEnabled) return;
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    getOrientEnabled=false;
}
*/
+(BOOL)isDeviceiPhone
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return TRUE;
    }
    
    return FALSE;
}

+(BOOL)isDeviceiPhone4
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    // iphone6+  414, 736
    // iphone6   375, 667
    // iphone 5s 320, 568
    // iphone 5  320, 568
    // iphone 4s 320, 480
    
    
    if ((size.height==480 && size.width==320) || (size.height==320 && size.width==480) )
        return TRUE;
    
    return FALSE;
}


+(BOOL)isDeviceRetina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0))        // Retina display
    {
        return TRUE;
    }
    else                                          // non-Retina display
    {
        return FALSE;
    }
}


+(BOOL)isDeviceiPhone5
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (! [rTracker_resource isDeviceiPhone4]))
    {
        return TRUE;
    }
    return FALSE;
}

+(CGRect) getKeyWindowFrame
{
    __block CGRect rframe;
    safeDispatchSync(^{
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (!window) window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        rframe = window.frame;
    });
    
    return rframe;
}

+(UIDeviceOrientation) getOrientationFromWindow
{
    CGRect f = [rTracker_resource getKeyWindowFrame];
    DBGLog(@"window : width %f   height %f ", f.size.width , f.size.height);
    if (f.size.height > f.size.width) return UIDeviceOrientationPortrait;
    if (f.size.width > f.size.height) return UIDeviceOrientationLandscapeLeft; // could go further here
    return UIDeviceOrientationUnknown;
}

+(CGFloat) getKeyWindowWidth
{
    return [rTracker_resource getKeyWindowFrame].size.width;
}


#define MAXDIM_4S 480
#define MAXDIM_5 568
#define MAXDIM_6 667
#define MAXDIM_6P 736

+(CGFloat) getScreenMaxDim {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    return (size.width > size.height ? size.width : size.height);
}

#define CHOOSE(x,y) [mb URLForResource:x withExtension:nil] ? x : y
+(NSString*)getLaunchImageName
{
    return(@"LaunchScreenImg.png");

    /* no longer needed with story board
    NSArray *allPngImageNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                            inDirectory:nil];

    for (NSString *imgName in allPngImageNames){
        DBGLog(@"imgName %@", imgName);
        // Find launch images
        if ([imgName containsString:@"LaunchImage"]){
            UIImage *img = [UIImage imageNamed:imgName];
            // Has image same scale and dimensions as our current device's screen?
            if (img.scale == [UIScreen mainScreen].scale && CGSizeEqualToSize(img.size, [UIScreen mainScreen].bounds.size)) {
                DBGLog(@"Found launch image for current device %@", img.description);
                return imgName; //break;
            }
        }
    }
    
    DBGLog(@"fail on launchimage name");
    return(@"LaunchScreenImg.png");
     */
}


/**************************
 
 640x1136   LaunchImage-568h@2x.png                iphone 5 retina
 LaunchImage-700-568h@2x.png
 LaunchImage-700-Landscape@2x~ipad.png
 LaunchImage-700-Landscape~ipad.png
 LaunchImage-700-Portrait@2x~ipad.png
 LaunchImage-700-Portrait~ipad.png
 LaunchImage-700@2x.png
 2048x1496  LaunchImage-Landscape@2x~ipad.png      ipad landscape retina
 1024x768   LaunchImage-Landscape~ipad.png         ipad landscape
 1536x2008  LaunchImage-Portrait@2x~ipad.png       ipad portrait retina
 768x1004   LaunchImage-Portrait~ipad.png          ipad portrait
 768x1024
 320x480    LaunchImage.png                        iphone 3gs
 640x960    LaunchImage@2x.png                     iphone retina
 750x1334   LaunchImage-800-667h@2x.png            iPhone 6
 1242x2208  LaunchImage-800-Portrait-736h@3x.png   iPhone 6 Plus Portrait
 
 
 
 
 
 iphone6+  414, 736
 iphone6   375, 667
 iphone 5s 320, 568
 iphone 5  320, 568
 iphone 4s 320, 480
 ipad retina 768, 1024
 ipad air    768, 1024
 ipad2       768, 1024
 
 LaunchImage-568h@2x.png
 LaunchImage-700-568h@2x.png
 LaunchImage-700-Landscape@2x~ipad.png
 LaunchImage-700-Landscape~ipad.png
 LaunchImage-700-Portrait@2x~ipad.png
 LaunchImage-700-Portrait~ipad.png
 LaunchImage-700@2x.png
 LaunchImage-800-667h@2x.png
 LaunchImage-800-Landscape-736h@3x.png
 LaunchImage-800-Portrait-736h@3x.png
 LaunchImage-Landscape@2x~ipad.png
 LaunchImage-Landscape~ipad.png
 LaunchImage-Portrait@2x~ipad.png
 LaunchImage-Portrait~ipad.png
 LaunchImage.png
 LaunchImage@2x.png
 
 image name :
 The LaunchImages are special, and aren't actually an asset catalog on the device. If you look using iFunBox/iExplorer/etc (or on the simulator, or in the build directory) you can see the final names, and then write code to use them
 
 
 /Default-568h@2x.png
 /Default-667h-Landscap@2x.png
 /Default-667h@2x.png
 /Default-736h-Landscape@3x.png
 /Default-736h@3x.png
 /Default-iphone.png
 /Default-Landscape-ipad.png
 /Default-Landscape@2x-ipad.png
 /Default-Portrait-ipad.png
 /Default-Portrait@2x-ipad.png
 /Default.png
 /Default@2x-iphone.png
 /Default@2x.png
 /Default~iphone.png
 

 
 *************************/

// copied from http://www.creativepulse.gr/en/blog/2013/how-to-find-the-visible-width-and-height-in-an-ios-app
+ (CGSize)get_visible_size:(UIViewController*)vc
{
    CGSize result;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //if (UIInterfaceOrientationIsLandscape(vc.interfaceOrientation)) {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        result.width = size.height;
        result.height = size.width;
    }
    else {
        result.width = size.width;
        result.height = size.height;
    }

    //DBGLog(@"gvs entry:  w= %f  h= %f",result.width, result.height);

    UIViewController *rvc= (vc.navigationController.viewControllers)[0];
    
    if (vc == rvc) {
        size = [[UIApplication sharedApplication] statusBarFrame].size;
        result.height -= MIN(size.width, size.height);
    
        //DBGLog(@"statusbar h= %f curr height= %f",size.height,result.height);
    }
    
    if (vc.navigationController != nil) {
        if (vc == rvc) {
            size = vc.navigationController.navigationBar.frame.size;
            result.height -= MIN(size.width, size.height);
            //DBGLog(@"navigationbar h= %f curr height= %f",size.height,result.height);
        }
        if (vc.navigationController.toolbar != nil) {
            size = vc.navigationController.toolbar.frame.size;
            result.height -= MIN(size.width, size.height);
            //DBGLog(@"toolbar h= %f curr height= %f",size.height,result.height);
        }
    }
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets sai =  [[[UIApplication sharedApplication] delegate] window].safeAreaInsets;
        result.height -= sai.bottom;
    }
    
    if (vc.tabBarController != nil) {
        size = vc.tabBarController.tabBar.frame.size;
        result.height -= MIN(size.width, size.height);
        //DBGLog(@"tabbar h= %f curr height= %f",size.height,result.height);
    }
    
    //DBGLog(@"gvs exit:  w= %f  h= %f",result.width, result.height);
    
    return result;
}

+ (NSString *)sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

@end
