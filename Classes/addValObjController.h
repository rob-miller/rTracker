/***************
 addValObjController.h
 Copyright 2010-2016 Robert T. Miller
 
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
