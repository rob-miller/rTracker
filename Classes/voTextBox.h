/***************
 voTextBox.h
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
//  voTextBox.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"
#import "voDataEdit.h"

#import "useTrackerController.h"

@interface voTextBox : voState <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>
/*{

    UIButton *tbButton;
	UITextView *textView;
	UIView *accessoryView;
	UIButton *addButton;
	UISegmentedControl *segControl;
	UIPickerView *pv;
	
	NSArray *alphaArray;
	NSArray *namesArray;
	NSArray *historyArray;
	NSArray *historyNdx;
    NSArray *namesNdx;
    
	//NSMutableDictionary *peopleDict;
	//NSMutableDictionary *historyDict;
	
	BOOL showNdx;
	
	voDataEdit *devc;
	CGRect saveFrame;
	
    useTrackerController *parentUTC;
    
}*/

@property (nonatomic,strong) UIButton *tbButton;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,unsafe_unretained) IBOutlet UIView *accessoryView;
@property (nonatomic,strong) IBOutlet UIButton *addButton;

@property (nonatomic,weak) IBOutlet UISegmentedControl *segControl;
@property (nonatomic,strong) UIPickerView *pv;

@property (nonatomic,readonly) NSArray *alphaArray;
@property (nonatomic,strong) NSArray *namesArray;
@property (nonatomic,strong) NSArray *historyArray;
@property (nonatomic,strong) NSArray *historyNdx;
@property (nonatomic,strong) NSArray *namesNdx;

@property (nonatomic,strong) useTrackerController *parentUTC;

//@property (nonatomic,retain) NSMutableDictionary *peopleDictionary;
//@property (nonatomic,retain) NSMutableDictionary *historyDictionary;

@property (nonatomic, unsafe_unretained) voDataEdit *devc;
//@property (nonatomic) CGRect saveFrame;

@property (nonatomic) BOOL showNdx;
@property (nonatomic) BOOL accessAddressBook;

@property (weak, nonatomic) IBOutlet UISegmentedControl *setSearchSeg;
- (IBAction)setSearchSegChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orAndSeg;

- (IBAction) addPickerData:(id)sender;
- (IBAction) segmentChanged:(id)sender;
/*
- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
*/

@end
