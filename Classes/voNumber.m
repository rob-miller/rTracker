/***************
 voNumber.m
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
//  voNumber.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voNumber.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation voNumber

@synthesize dtf=_dtf, startStr=_startStr;

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	//DBGLog(@"number tf begin editing vid=%ld",(long)self.vo.vid);
    self.startStr = textField.text;
	((trackerObj*) self.vo.parentTracker).activeControl = (UIControl*) textField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    // not sure yet - lot of actions for every char when just want to enable 'save'
    //[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DBGLog(@"vo.value= %@",self.vo.value);
    DBGLog(@"tf.text= %@",textField.text);
	DBGLog(@"tf end editing vid=%ld vo.value=%@ tf.text=%@",(long)self.vo.vid,self.vo.value,textField.text);

    if (! [self.startStr isEqualToString:textField.text]) {
        [self.vo.value setString:textField.text];
        textField.textColor = [UIColor blackColor];
        textField.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
        self.startStr=nil;
    }
    
	((trackerObj*) self.vo.parentTracker).activeControl = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// the user pressed the "Done" button, so dismiss the keyboard
	//DBGLog(@"textField done: %@  vid=%d", textField.text,self.vo.vid);
	// [self tfvoFinEdit:textField];  // textFieldDidEndEditing will be called, just dismiss kybd here
    DBGLog(@"tf should return vid=%ld vo.value=%@ tf.text=%@",(long)self.vo.vid,self.vo.value,textField.text);

	[textField resignFirstResponder];
	return YES;
}

- (void)selectDoneButton {
    [self.dtf resignFirstResponder];
}

- (void) selectMinusButton {
    self.dtf.text = [rTracker_resource negateNumField:self.dtf.text] ;
}

- (UITextField*) dtf {
    if (_dtf && _dtf.frame.size.width != self.vosFrame.size.width) _dtf=nil;  // first time around thinks size is 320, handle larger devices
    
    if (nil == _dtf) {
        DBGLog(@"init %@ : x=%f y=%f w=%f h=%f",self.vo.valueName,self.vosFrame.origin.x,self.vosFrame.origin.y,self.vosFrame.size.width,self.vosFrame.size.height);
        _dtf = [[UITextField alloc] initWithFrame:self.vosFrame];
        
        _dtf.borderStyle = UITextBorderStyleRoundedRect;  //Bezel;
        _dtf.textColor = [UIColor blackColor];
        _dtf.font = PrefBodyFont; // [UIFont systemFontOfSize:17.0];
        _dtf.backgroundColor = [UIColor whiteColor];
        _dtf.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        _dtf.placeholder = @"<enter number>";
        _dtf.textAlignment = NSTextAlignmentRight; // ios6 UITextAlignmentRight;
        //[dtf addTarget:self action:@selector(numTextFieldClose:) forControlEvents:UIControlEventTouchUpOutside];
        
        
        //_dtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only -- need decimal point
        
        _dtf.keyboardType = UIKeyboardTypeDecimalPad; //number pad with decimal point but no done button 	// use the number input only
        // no done button for number pad // _dtf.returnKeyType = UIReturnKeyDone;
        // need this from http://stackoverflow.com/questions/584538/how-to-show-done-button-on-iphone-number-pad Michael Laszlo
        float appWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
        UIToolbar *accessoryView = [[UIToolbar alloc]
                                    initWithFrame:CGRectMake(0, 0, appWidth, 0.1 * appWidth)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil
                                  action:nil];
        UIBarButtonItem *done = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(selectDoneButton)];
        UIBarButtonItem *minus = [[UIBarButtonItem alloc]
                                  initWithTitle:@"-"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(selectMinusButton)];

        accessoryView.items = @[space, done, space, minus, space];
        _dtf.inputAccessoryView = accessoryView;

        
        
        _dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        
        //dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
        _dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
        
        // Add an accessibility label that describes what the text field is for.
        [_dtf setAccessibilityLabel:NSLocalizedString(@"enter a number", @"")];
        _dtf.text=@"";
        [_dtf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    //DBGLog(@"num dtf rc= %d",[dtf retainCount]);
    
    return _dtf;
}

- (void) resetData {
    if (nil != _dtf) {  // not self as don't want to instantiate prematurely
        if ([NSThread isMainThread]) {
            self.dtf.text = @"";
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.dtf.text = @"";
            });
        }
    }
    self.vo.useVO = YES;
}

- (UIView*)voDisplay:(CGRect)bounds {
	self.vosFrame = bounds;

	//if (![self.vo.value isEqualToString:dtf.text]) {
        
        if ([self.vo.value isEqualToString:@""]) {
            if ([(self.vo.optDict)[@"nswl"] isEqualToString:@"1"] /* && ![to hasData] */) {  // only if new entry
                trackerObj *to = (trackerObj*)self.vo.parentTracker;
                NSString *sql = [NSString stringWithFormat:@"select count(*) from voData where id=%ld and date<%d",
                          (long)self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                int v = [to toQry2Int:sql];
                if (v>0) {
                   sql = [NSString stringWithFormat:@"select val from voData where id=%ld and date<%d order by date desc limit 1;",
                              (long)self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                    NSString *r = [to toQry2Str:sql];
                    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                        self.dtf.textColor = [UIColor lightGrayColor];
                    } else {
                        self.dtf.textColor = [UIColor yellowColor]; //[UIColor lightGrayColor];
                    }
                    self.dtf.backgroundColor = [UIColor darkGrayColor];
                    self.dtf.text = r;
                }
              //sql = nil;
            } else {
                self.dtf.text = @"";
                //DBGLog(@"reset dtf.txt to empty");
            }
        } else {
            self.dtf.backgroundColor = [UIColor whiteColor];
            self.dtf.textColor = [UIColor blackColor];
            self.dtf.text = self.vo.value;
        }
        
        //DBGLog(@"dtf: vo val= %@  dtf.text= %@", self.vo.value, self.dtf.text);
	//}
    
    DBGLog(@"number voDisplay: %@", self.dtf.text);
    return self.dtf;
}

- (NSString*) update:(NSString*)instr {   // confirm textfield not forgotten
    if ((nil == _dtf) // NOT self.dtf as we want to test if is instantiated
        ||
        !([instr isEqualToString:@""])
        ){ 
        return instr;
    }
    return self.dtf.text;
}


- (NSArray*) voGraphSet {
	return [voState voGraphSetNum];
}

#pragma mark -
#pragma mark options page 

- (void) setOptDictDflts {
    
    if (nil == (self.vo.optDict)[@"nswl"]) 
        (self.vo.optDict)[@"nswl"] = (NSWLDFLT ? @"1" : @"0");
    
    if (nil == (self.vo.optDict)[@"autoscale"]) 
        (self.vo.optDict)[@"autoscale"] = (AUTOSCALEDFLT ? @"1" : @"0");

    if (nil == (self.vo.optDict)[@"numddp"])
        (self.vo.optDict)[@"numddp"] = [NSString stringWithFormat:@"%d", NUMDDPDFLT];

    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"nswl"] && [val isEqualToString:(NSWLDFLT ? @"1" : @"0")])
        ||
        ([key isEqualToString:@"autoscale"] && [val isEqualToString:(AUTOSCALEDFLT ? @"1" : @"0")])
        ||
        ([key isEqualToString:@"numddp"] && ([val intValue] == NUMDDPDFLT))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    return [super cleanOptDictDflts:key];
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {

	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"Start with last saved value:" frame:frame key:@"swlLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	frame = [ctvovc configCheckButton:frame
                          key:@"swlBtn"
                        state:([(self.vo.optDict)[@"nswl"] isEqualToString:@"1"])  // default:0
                        addsv:YES
    ];
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
    
	frame = [ctvovc yAutoscale:frame];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
    
    labframe = [ctvovc configLabel:@"graph decimal places (-1 auto):" frame:frame key:@"numddpLab" addsv:YES];
    
    frame.origin.x += labframe.size.width + SPACE;
    CGFloat tfWidth = [@"99999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
    frame.size.width = tfWidth;
    frame.size.height = ctvovc.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
    
    frame = [ctvovc configTextField:frame
                              key:@"numddpTF"
                           target:nil
                           action:nil
                              num:YES
                            place:[NSString stringWithFormat:@"%d",NUMDDPDFLT]
                             text:(self.vo.optDict)[@"numddp"]
                            addsv:YES ];

    
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
    //-- title label
	
	labframe = [ctvovc configLabel:@"Other options:" frame:frame key:@"noLab" addsv:YES];
	
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN;

	[super voDrawOptions:ctvovc];
}
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_num:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    return [[vogd alloc] initAsNum:self.vo];
}

@end
