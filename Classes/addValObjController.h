//
//  addValObjController.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "valueObj.h"
#import "trackerObj.h"

@interface addValObjController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	UITextField *labelField;
	UIPickerView *votPicker;
	UIToolbar *toolbar;
	
	valueObj *tempValObj;
	trackerObj *parentTrackerObj;
	NSArray *graphTypes;
}

@property (nonatomic, retain) IBOutlet UITextField *labelField;
@property (nonatomic,retain) IBOutlet UIPickerView *votPicker;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic,retain) valueObj *tempValObj;
@property (nonatomic,retain) trackerObj *parentTrackerObj;
@property (nonatomic,retain) NSArray *graphTypes;

+(CGSize) maxLabelFromArray:(const NSArray *)arr;


@end
