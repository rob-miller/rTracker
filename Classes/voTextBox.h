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

@interface voTextBox : voState <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>{

	UITextView *textView;
	UIView *accessoryView;
	UIButton *addButton;
	UISegmentedControl *segControl;
	UIPickerView *pv;
	
	NSArray *alphaArray;
	NSArray *peopleArray;
	NSArray *historyArray;
	
	//NSMutableDictionary *peopleDict;
	//NSMutableDictionary *historyDict;
	
	BOOL showNdx;
	
	voDataEdit *devc;
	CGRect saveFrame;
	
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, assign) IBOutlet UIView *accessoryView;
@property (nonatomic,retain) IBOutlet UIButton *addButton;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segControl;
@property (nonatomic,assign) UIPickerView *pv;

@property (nonatomic,readonly) NSArray *alphaArray;
@property (nonatomic,retain) NSArray *peopleArray;
@property (nonatomic,retain) NSArray *historyArray;
//@property (nonatomic,retain) NSMutableDictionary *peopleDictionary;
//@property (nonatomic,retain) NSMutableDictionary *historyDictionary;

@property (nonatomic, assign) voDataEdit *devc;
@property (nonatomic) CGRect saveFrame;

@property (nonatomic) BOOL showNdx;

- (IBAction) addPickerData:(id)sender;
- (IBAction) segmentChanged:(id)sender;


@end
