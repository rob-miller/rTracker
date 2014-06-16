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
@property (nonatomic,strong) IBOutlet UISegmentedControl *segControl;
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
@property (nonatomic) CGRect saveFrame;

@property (nonatomic) BOOL showNdx;

- (IBAction) addPickerData:(id)sender;
- (IBAction) segmentChanged:(id)sender;

- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;

@end
