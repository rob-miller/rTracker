//
//  rTracker-resource.h
//  rTracker
//
//  Created by Rob Miller on 24/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

// make sqlite db files available from itunes? (perhaps prefs option later)
#define DBACCESS NO

// Sample code from iOS 7 Transistion Guide
// Loading Resources Conditionally
NSUInteger DeviceSystemMajorVersion();
#define kIS_LESS_THAN_IOS7 (DeviceSystemMajorVersion() < 7)

@interface rTracker_resource : NSObject {
    
}


+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access;
+ (BOOL) deleteFileAtPath:(NSString*)fp;

+ (unsigned int) countLines:(NSString*)str;
+ (void) initHasAmPm;

+ (void) alert:(NSString*)title msg:(NSString*)msg;

+ (void) myNavPushTransition:(UINavigationController*)navc vc:(UIViewController*)vc animOpt:(NSInteger)animOpt;
+ (void) myNavPopTransition:(UINavigationController*)navc animOpt:(NSInteger)animOpt;
+ (NSArray*) colorSet;
+ (NSArray*) colorNames;

+ (void) startActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable;
+ (void) finishActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable;

+ (void) startProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable yloc:(CGFloat)yloc;
+ (void) setProgressVal:(float)progressVal;
//+ (void) updateProgressBar;
+ (void) stashProgressBarMax:(int) total;
+ (void) bumpProgressBar;
+ (void) finishProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable;

+ (BOOL)getSeparateDateTimePicker;

+ (void)setSeparateDateTimePicker:(BOOL)sdt;
+ (void) stashTracker:(int)tid;
+ (void) rmStashedTracker:(int)tid;
+ (void) unStashTracker:(int)tid;

+ (NSString*) fromSqlStr:(NSString*) instr;
+ (NSString*) toSqlStr:(NSString*) instr;

+ (UITextField*) rrConfigTextField:(CGRect)frame key:(NSString*)key target:(id)target delegate:(id)delegate action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text;

+ (void) willShowKeyboard:(NSNotification*)n view:(UIView*)view boty:(CGFloat)boty;
+ (void) willHideKeyboard;

@end

extern BOOL keyboardIsShown;
extern BOOL hasAmPm;

