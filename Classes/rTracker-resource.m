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
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
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
	NSString *docsDir = [paths objectAtIndex:0];
	
	//DBGLog(@"ioFilePath= %@",[docsDir stringByAppendingPathComponent:fname] );
	
	return [docsDir stringByAppendingPathComponent:fname];
}

+ (BOOL) deleteFileAtPath:(NSString*)fp {
    NSError *err;
    DBGLog(@"deleting file at path %@",fp);
    if (YES != [[NSFileManager defaultManager] removeItemAtPath:fp error:&err]) {
        DBGErr(@"Error deleting file: %@ error: %@", fp, err);
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
+ (unsigned int) countLines:(NSString*)str {
    
    unsigned int numberOfLines, index, stringLength = [str length];
    
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
    [alert release];
}

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
	return [NSArray arrayWithObjects:
                [UIColor redColor], [UIColor greenColor], [UIColor blueColor],
                [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor],
                [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], 
                [UIColor whiteColor], [UIColor lightGrayColor], [UIColor darkGrayColor], nil];
		
}

+ (NSArray *) colorNames {
	return [NSArray arrayWithObjects:
            @"red", @"green", @"blue",
            @"cyan", @"yellow", @"magenta",
            @"orange", @"purple", @"brown", 
            @"white", @"lightGray", @"darkGray", nil];
}


//---------------------------

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
    captionLabel.textAlignment = UITextAlignmentCenter;
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

    [activityIndicator release];
    activityIndicator = nil;
    [captionLabel release];
    captionLabel = nil;
    [outerView removeFromSuperview];
    [outerView release];
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
    [progressBar release];
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


//---------------------------
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


+ (UITextField*) rrConfigTextField:(CGRect)frame key:(NSString*)key target:(id)target delegate:(id)delegate action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text
{
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
		rtf.textAlignment = UITextAlignmentRight;
	}
	rtf.placeholder = place;
	
	if (text)
		rtf.text = text;
	
    return rtf;
}

//---------------------------------------

+ (void) willShowKeyboard:(NSNotification*)n view:(UIView*)view boty:(CGFloat)boty {

    if (keyboardIsShown) { // need bit more logic to handle additional scrolling for another textfield
        return;
    }
	
	DBGLog(@"handling keyboard will show: %@",[n object]);

    currKeyboardView = view;
	currKeyboardSaveFrame = view.frame;

    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];  //FrameBeginUserInfoKey
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
                       subdirectory:@"sounds"];
    
    DBGLog(@"soundfile = %@ soundurl= %@",soundFileName,soundURL);
    
    AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &sound1);
    AudioServicesAddSystemSoundCompletion(sound1,
                                          NULL,
                                          NULL,
                                          systemAudioCallback,
                                          NULL);
    
    AudioServicesPlayAlertSound(sound1);
}


@end
