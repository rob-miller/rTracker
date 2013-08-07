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

// from http://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
// Text Layout Programming Guide: Counting Lines of Text
+ (unsigned int) countLines:(NSString*)str {
    
    unsigned int numberOfLines, index, stringLength = [str length];
    
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([str lineRangeForRange:NSMakeRange(index, 0)]);
    
    return numberOfLines;
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

+ (void) startActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
    
    if (disable) {
        view.userInteractionEnabled = NO;
        [navItem setHidesBackButton:YES animated:YES];
        navItem.rightBarButtonItem.enabled = NO;
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge ];
    activityIndicator.center = view.center;
    [view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

+ (void) finishActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
// note needs performSelectorOnMainThread fix for ios5
    if (disable) {
        [navItem setHidesBackButton:NO animated:YES];
        navItem.rightBarButtonItem.enabled = YES;
        view.userInteractionEnabled = YES;
    }
    
    [activityIndicator stopAnimating];
    [activityIndicator release];
    activityIndicator = nil;
}

static UIProgressView *progressBar=nil;

+ (void) startProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable {
    
    if (disable) {
        view.userInteractionEnabled = NO;
        [navItem setHidesBackButton:YES animated:YES];
        navItem.rightBarButtonItem.enabled = NO;
    }
    
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault ];
    CGRect pbFrame = progressBar.frame;
    CGRect vFrame = view.frame;
    pbFrame.size.width = vFrame.size.width;
    progressBar.frame = pbFrame;
    
    //progressBar.center = view.center;
    [view addSubview:progressBar];
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
        [localNavItem setHidesBackButton:NO animated:YES];
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

//---------------------------
+ (void) stashTracker:(int)tid
{
    NSString *oldFname= [NSString stringWithFormat:@"trkr%d.sqlite3",tid];
    NSString *newFname= [NSString stringWithFormat:@"stash_trkr%d.sqlite3",tid];
    NSError *error;
    
    DBGLog(@"stashing tracker %d",tid);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm copyItemAtPath:[rTracker_resource ioFilePath:oldFname access:DBACCESS]
                    toPath:[rTracker_resource ioFilePath:newFname access:DBACCESS] error:&error] != YES) {
        DBGLog(@"Unable to copy file %@ to %@: %@", oldFname, newFname, [error localizedDescription]);
    }
}

+ (void) rmStashedTracker:(int)tid {
    if (-1 == tid) {
        return;
    }
    NSString *fname= [NSString stringWithFormat:@"stash_trkr%d.sqlite3",tid];
    NSError *error;
    
    DBGLog(@"dumping stashed tracker %d",tid);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm removeItemAtPath:[rTracker_resource ioFilePath:fname access:DBACCESS] error:&error] != YES) {
        DBGLog(@"Unable to delete file %@: %@", fname, [error localizedDescription]);
    }
    
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
        DBGLog(@"Unable to move file %@ to %@: %@", oldFname, newFname, [error localizedDescription]);
    }    
}


@end
