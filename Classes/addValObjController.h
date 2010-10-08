//
//  addValObjController.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "valueObj.h"
#import "trackerObj.h"

#define SCROLLTAG 1

@interface addValObjController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> 
{
	valueObj *tempValObj;
	trackerObj *parentTrackerObj;
	NSArray *graphTypes;

	UITextField *labelField;
	UIPickerView *votPicker;
	UIScrollView *scrollView;
	NSMutableDictionary *svDict;
	
	UITextField    *textfield;
	UITextField    *textfield2;
	
	UITextField	*activeField;
	NSInteger lastVOT;
	
}

@property (nonatomic,retain) valueObj *tempValObj;
@property (nonatomic,retain) trackerObj *parentTrackerObj;  // this makes a retain cycle....
@property (nonatomic,retain) NSArray *graphTypes;

@property (nonatomic,retain) IBOutlet UITextField *labelField;
@property (nonatomic,retain) IBOutlet UIPickerView *votPicker;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic,retain) NSMutableDictionary *svDict;

+(CGSize) maxLabelFromArray:(const NSArray *)arr;

- (void) updateScrollView:(NSInteger) vot;

- (void) updateColorCount;
- (void) updateForPickerRowSelect:(NSInteger)row inComponent:(NSInteger)component;

@end
