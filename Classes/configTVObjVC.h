//
//  configValObjVC.h
//  rTracker
//
//  This screen displays configuration options for a tracker or a specific value object type.  The 
//  class provides routines to support labels, checkboxes, textboxes, etc., while the specific arrangement is 
//  delegated to the tracker or valueObj with addTOFields: or addVOFields:
//
//  Created by Robert Miller on 09/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "trackerObj.h"
#import "valueObj.h"
#import "privacyV.h"

@interface configTVObjVC : UIViewController <UITextFieldDelegate>
/*
{

	BOOL vdlConfigVO;
	trackerObj *to;
	valueObj *vo;
	
	NSMutableDictionary *wDict;  // widget dictionary

	CGFloat lasty;
	CGRect saveFrame;
	CGFloat LFHeight;

    BOOL processingTfDone;
    
}
*/

@property (nonatomic) BOOL vdlConfigVO;
@property (nonatomic,strong) trackerObj *to;
@property (nonatomic,strong) valueObj *vo;
@property (nonatomic,strong) NSDictionary *voOptDictStash;
@property (nonatomic,strong) NSMutableDictionary *wDict;
@property (nonatomic) CGFloat lasty;
@property (nonatomic) CGRect saveFrame;
@property (nonatomic) CGFloat LFHeight;

// UI element properties 
@property (nonatomic,strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;

@property (nonatomic,unsafe_unretained) UITextField *activeField;   //just a pointer, no retain
@property (nonatomic) BOOL processingTfDone;

- (void) addVOFields:(NSInteger) vot;
- (void) addTOFields;
- (void) removeSVFields;

- (CGRect) configLabel:(NSString *)text frame:(CGRect)frame key:(NSString*)key addsv:(BOOL)addsv;
- (CGRect) configCheckButton:(CGRect)frame key:(NSString*)key state:(BOOL)state addsv:(BOOL)addsv;
- (CGRect) configActionBtn:(CGRect)frame key:(NSString*)key label:(NSString*)label target:(id)target action:(SEL)action;
- (CGRect) configTextField:(CGRect)frame key:(NSString*)key target:(id)target action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text addsv:(BOOL)addsv;
- (CGRect) configTextView:(CGRect)frame key:(NSString*)key text:(NSString*)text;
- (CGRect) configPicker:(CGRect)frame key:(NSString*)key caller:(id)caller;
- (CGRect) yAutoscale:(CGRect)frame;
- (void) tfDone:(UITextField *)tf;

- (void) removeGraphMinMax;
- (void) addGraphMinMax;


@end
