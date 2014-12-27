//
//  addValObjController.h
//  rTracker
//
//  this screen supports create/edit of a value object, specifying its label, type and graph color/style
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "valueObj.h"
#import "trackerObj.h"

@interface addValObjController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> 

@property (nonatomic,strong) valueObj *tempValObj;
@property (nonatomic,strong) trackerObj *parentTrackerObj;  // this makes a retain cycle....
@property (nonatomic,strong) NSArray *graphTypes;

@property (nonatomic,strong) NSDictionary *voOptDictStash;

// UI element properties 
@property (nonatomic,strong) IBOutlet UITextField *labelField;
@property (nonatomic,strong) IBOutlet UIPickerView *votPicker;
@property (nonatomic, strong) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction) btnSetup:(id)sender;
- (IBAction) labelFieldDone:(id)sender;


+(CGSize) maxLabelFromArray:(const NSArray *)arr;

- (void) updateColorCount;
- (void) updateForPickerRowSelect:(NSInteger)row inComponent:(NSInteger)component;
//- (IBAction) btnSetup;

- (void) stashVals;

@end
