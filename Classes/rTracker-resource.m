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

#import <AudioToolbox/AudioToolbox.h>


@implementation rTracker_resource

BOOL keyboardIsShown=NO;
UIView *currKeyboardView=nil;
CGRect currKeyboardSaveFrame;

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
+ (void) alert:(NSString*)title msg:(NSString*)msg {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title message:msg
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
    [alert show];
}

#if ADVERSION

+ (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 1 ) /* NO = 0, YES = 1 */
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/rtracker/id486541371"]];
    }
}

+ (void) buy_rTrackerAlert {
    NSString *msg = [NSString stringWithFormat:@"\nrTrackerA is advertising supported and limited to %d trackers of %d items.\n\nPlease buy rTracker to remove the advertisements and these limits.\n\nUse the 'email tracker+data' functionality to transfer your existing trackers (email to yourself, open the attachment in rTracker from Mail on your iOS device - you may need to look in your sent mail folder).",ADVER_TRACKER_LIM, ADVER_ITEM_LIM];
    UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:@"Upgrade to rTracker"
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"Not now"
                                           otherButtonTitles:@"Get rTracker",nil];
    [_alert show];
}

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


//---------------------------
#pragma mark -
#pragma mark activity indicator support

static UIActivityIndicatorView *activityIndicator=nil;
static UIView *outerView;
static UILabel *captionLabel;

+ (void) startActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable str:(NSString*)str {
    
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

    //[activityIndicator performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];

    [view addSubview:outerView];
}

+ (void) finishActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
// note needs performSelectorOnMainThread fix for ios5
    if (disable) {
        //[navItem setHidesBackButton:NO animated:YES];
        navItem.rightBarButtonItem.enabled = YES;
        view.userInteractionEnabled = YES;
    }
    
    //[activityIndicator stopAnimating];
    [activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];

    activityIndicator = nil;
    captionLabel = nil;
    [outerView removeFromSuperview];
    outerView = nil;
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
    
    /*
     [[NSNotificationCenter defaultCenter] removeObserver:self
     name:rtProgressBarUpdateNotification
     object:nil];
     */
    //[progressBar stopAnimating];

    [progressBar removeFromSuperview];
    progressBar = nil;
    
    //DBGLog(@"progressbar finished");
    
}

+ (void) finishProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
    localView = view;
    localNavItem = navItem;
    localDisable = disable;
    if ( SYSTEM_VERSION_LESS_THAN(@"5.0") ) {// if not 5
        [rTracker_resource doFinishProgressBar];
    } else {
        [self performSelectorOnMainThread:@selector(doFinishProgressBar) withObject:nil waitUntilDone:NO];
    }
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
	DBGLog(@"updateSeparateDateTimePicker:%d",separateDateTimePicker);
}

static BOOL rtcsvOutput=RTCSVOUTDFLT;

+ (BOOL)getRtcsvOutput {
	return rtcsvOutput;
}

+ (void)setRtcsvOutput:(BOOL)rtcsvOut {
	rtcsvOutput = rtcsvOut;
	DBGLog(@"updateRtcsvOutput:%d",rtcsvOutput);
}

static BOOL savePrivate=SAVEPRIVDFLT;

+ (BOOL)getSavePrivate {
	return savePrivate;
}

+ (void)setSavePrivate:(BOOL)savePriv {
	savePrivate = savePriv;
	DBGLog(@"updateSavePrivate:%d",savePrivate);
}


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

+ (UITextField*) rrConfigTextField:(CGRect)frame key:(NSString*)key target:(id)target delegate:(id)delegate action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text
{
    DBGLog(@" frame x %f y %f w %f h %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
	UITextField *rtf = [[UITextField alloc] initWithFrame:frame ];
	rtf.clearsOnBeginEditing = NO;
    
	[rtf setDelegate:delegate];
	rtf.returnKeyType = UIReturnKeyDone;
	rtf.borderStyle = UITextBorderStyleRoundedRect;

	dbgNSAssert((action != nil), @"nil action");
	dbgNSAssert((target != nil), @"nil action");
	
	[rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEndOnExit];
    //[rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEnd|UIControlEventEditingDidEndOnExit];
    [rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEnd];
    
	if (num) {
		rtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
        rtf.textAlignment = NSTextAlignmentRight;  // ios6 UITextAlignmentRight;
	}
	rtf.placeholder = place;
	
	if (text)
		rtf.text = text;
	
    return rtf;
}

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
		
		[view setFrame:viewFrame];
		
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
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return window.frame;
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
    NSBundle* mb = [NSBundle mainBundle];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat maxDim = [self getScreenMaxDim];
    NSString *retStr;
    
    DBGLog(@"width %f  height %f",size.width, size.height);
    /*
     UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationUnknown == orientation) DBGLog(@"orientation unknown");
    if (UIDeviceOrientationPortraitUpsideDown == orientation) DBGLog(@"orientation portrait upside down");
    if (UIDeviceOrientationPortrait == orientation) DBGLog(@"orientation portrait");
    */
    
    if ([self isDeviceiPhone])
    {
        if (maxDim < MAXDIM_4S) {
            retStr = @"LaunchImage.png";                                                // non-retina iPhone
        } else if (maxDim < MAXDIM_5) {
            retStr = CHOOSE(@"LaunchImage-700@2x.png",@"LaunchImage@2x.png");             // iPhone 4s
        } else if (maxDim < MAXDIM_6) {
            retStr = CHOOSE(@"LaunchImage-700-568h@2x.png",@"LaunchImage-568h@2x.png");   // iPhone 5
        } else if (maxDim <MAXDIM_6P) {
            retStr = @"LaunchImage-800-667h@2x.png";                                      // iPhone 6
        } else if (size.height < size.width) {                                          // if landscape
            retStr = @"LaunchImage-800-Landscape-736h@3x.png";                            // iPhone 6+ or larger
        } else {
            retStr = @"LaunchImage-800-Portrait-736h@3x.png";                             // default: iPhone 6+ or larger, portrait
        }
    } else {     // iPad
        if (size.height < size.width) {                                                 // if landscape  -- does not work at startup for ios7, orientation reports 'unknown'
            if ([UIScreen mainScreen].scale == 1.0) {
                retStr = CHOOSE(@"LaunchImage-700-Landscape~ipad.png", @"LaunchImage-Landscape~ipad.png");           // non-retina iPad
            } else {
                retStr = CHOOSE(@"LaunchImage-700-Landscape@2x~ipad.png", @"LaunchImage-Landscape@2x~ipad.png");     // retina iPad or larger
            }
        } else {
            if ([UIScreen mainScreen].scale == 1.0) {
                retStr = CHOOSE(@"LaunchImage-700-Portrait~ipad.png", @"LaunchImage-Portrait~ipad.png");           // non-retina iPad
            } else {
                retStr = CHOOSE(@"LaunchImage-700-Portrait@2x~ipad.png", @"LaunchImage-Portrait@2x~ipad.png");     // default: retina iPad or larger
            }
        }
    }
    DBGLog(@"LaunchImage: %@",retStr);
    return(retStr);
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
    
    if (UIInterfaceOrientationIsLandscape(vc.interfaceOrientation)) {
        result.width = size.height;
        result.height = size.width;
    }
    else {
        result.width = size.width;
        result.height = size.height;
    }

    DBGLog(@"gvs entry:  w= %f  h= %f",result.width, result.height);

    UIViewController *rvc= (vc.navigationController.viewControllers)[0];
    
    if (vc == rvc) {
        size = [[UIApplication sharedApplication] statusBarFrame].size;
        result.height -= MIN(size.width, size.height);
    
        DBGLog(@"statusbar h= %f curr height= %f",size.height,result.height);
    }
    
    if (vc.navigationController != nil) {
        if (vc == rvc) {
            size = vc.navigationController.navigationBar.frame.size;
            result.height -= MIN(size.width, size.height);
            DBGLog(@"navigationbar h= %f curr height= %f",size.height,result.height);
        }
        if (vc.navigationController.toolbar != nil) {
            size = vc.navigationController.toolbar.frame.size;
            result.height -= MIN(size.width, size.height);
            DBGLog(@"toolbar h= %f curr height= %f",size.height,result.height);
        }
    }
    
    if (vc.tabBarController != nil) {
        size = vc.tabBarController.tabBar.frame.size;
        result.height -= MIN(size.width, size.height);
        DBGLog(@"tabbar h= %f curr height= %f",size.height,result.height);
    }
    
    DBGLog(@"gvs exit:  w= %f  h= %f",result.width, result.height);
    
    return result;
}

@end
