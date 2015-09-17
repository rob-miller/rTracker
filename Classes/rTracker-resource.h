//
//  rTracker-resource.h
//  rTracker
//
//  Created by Rob Miller on 24/03/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbg-defs.h"

// make sqlite db files available from itunes? (perhaps prefs option later)
#define DBACCESS NO

#define DBLRANDOM ((double)arc4random() / 0x100000000)


// Sample code from iOS 7 Transistion Guide
// Loading Resources Conditionally
NSUInteger DeviceSystemMajorVersion();
#define kIS_LESS_THAN_IOS7 (DeviceSystemMajorVersion() < 7)
#define kIS_LESS_THAN_IOS8 (DeviceSystemMajorVersion() < 8)

@interface rTracker_resource : NSObject {
    
}


+ (NSString *) ioFilePath:(NSString*)fname access:(BOOL)access;
+ (BOOL) deleteFileAtPath:(NSString*)fp;
+ (BOOL) protectFile:(NSString*)fp;

+ (NSUInteger) countLines:(NSString*)str;
+ (void) initHasAmPm;

+ (UIButton*) getCheckButton:(CGRect)frame;
+ (void) setCheckButton:(UIButton*)cb colr:(UIColor*)colr;
+ (void) clrCheckButton:(UIButton*)cb colr:(UIColor*)colr;

+ (void) alert:(NSString*)title msg:(NSString*)msg vc:(UIViewController*)vc;
#if ADVERSION
+ (void) handleUpgradeOptions:(NSInteger)choice;
+ (void) buy_rTrackerAlert;
#endif

+ (void) myNavPushTransition:(UINavigationController*)navc vc:(UIViewController*)vc animOpt:(NSInteger)animOpt;
+ (void) myNavPopTransition:(UINavigationController*)navc animOpt:(NSInteger)animOpt;
+ (NSArray*) colorSet;
+ (NSArray*) colorNames;

+ (void) startActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable str:(NSString*)str;
+ (void) finishActivityIndicator:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable;

+ (void) startProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable yloc:(CGFloat)yloc;
+ (void) setProgressVal:(float)progressVal;
//+ (void) updateProgressBar;
+ (void) stashProgressBarMax:(int) total;
+ (void) bumpProgressBar;
+ (void) finishProgressBar:(UIView*)view navItem:(UINavigationItem*)navItem disable:(BOOL)disable;

+ (BOOL)getSeparateDateTimePicker;
+ (void)setSeparateDateTimePicker:(BOOL)sdt;

+ (BOOL)getRtcsvOutput;
+ (void)setRtcsvOutput:(BOOL)rtcsvOut;

+ (BOOL)getSavePrivate;
+ (void)setSavePrivate:(BOOL)savePriv;

//+ (BOOL)getHideRTimes;
//+ (void)setHideRTimes:(BOOL)hideRTimes;

+ (BOOL)getToldAboutSwipe;
+ (void)setToldAboutSwipe:(BOOL)toldSwipe;

#if ADVERSION
+ (BOOL)getPurchased;
+ (void)setPurchased:(BOOL)inPurchased;
#endif

    
+ (void) stashTracker:(int)tid;
+ (void) rmStashedTracker:(int)tid;
+ (void) unStashTracker:(int)tid;

+ (NSString*) fromSqlStr:(NSString*) instr;
+ (NSString*) toSqlStr:(NSString*) instr;

+ (NSString*) negateNumField:(NSString*)text;
+ (UITextField*) rrConfigTextField:(CGRect)frame key:(NSString*)key target:(id)target delegate:(id)delegate action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text;

+ (void) willShowKeyboard:(NSNotification*)n view:(UIView*)view boty:(CGFloat)boty;
+ (void) willHideKeyboard;

+ (void) playSound:(NSString*) soundFileName;

//+(void)enableOrientationData;
//+(void)disableOrientationData;

+(BOOL)isDeviceiPhone4;
+(CGRect) getKeyWindowFrame;
+(CGFloat) getKeyWindowWidth;
+(CGFloat) getScreenMaxDim;
+ (NSString*)getLaunchImageName;

+ (CGSize)get_visible_size:(UIViewController*)uvc;

@end

extern BOOL keyboardIsShown;
extern BOOL hasAmPm;
extern BOOL resigningActive;

