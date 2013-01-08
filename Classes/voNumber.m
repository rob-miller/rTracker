//
//  voNumber.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voNumber.h"
#import "dbg-defs.h"

@implementation voNumber

@synthesize dtf;


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	DBGLog(@"tf begin editing vid=%d",self.vo.vid);
    //*activeField = textField;
	((trackerObj*) self.vo.parentTracker).activeControl = (UIControl*) textField;
}

/*
- (void)tfvoFinEdit:(UITextField*)tf {
	tf.textColor = [UIColor blackColor];
	[self.vo.value setString:tf.text];
    tf.backgroundColor = [UIColor whiteColor];
    
	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}
*/

- (void)textFieldDidEndEditing:(UITextField *)textField {
	DBGLog(@"tf end editing vid=%d",self.vo.vid);
	//[self tfvoFinEdit:textField];
	textField.textColor = [UIColor blackColor];
	[self.vo.value setString:textField.text];
    textField.backgroundColor = [UIColor whiteColor];
    
	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
    
    
    //*activeField = nil;
	((trackerObj*) self.vo.parentTracker).activeControl = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// the user pressed the "Done" button, so dismiss the keyboard
	//DBGLog(@"textField done: %@  vid=%d", textField.text,self.vo.vid);
	// [self tfvoFinEdit:textField];  // textFieldDidEndEditing will be called, just dismiss kybd here
	[textField resignFirstResponder];
	return YES;
}

- (void) dealloc {
    DBGLog(@"voNumber dealloc");
    self.dtf = nil;
    [dtf release];
    [super dealloc];
}

- (UITextField*) dtf {
    if (nil == dtf) {
        DBGLog(@"init %@ : x=%f y=%f w=%f h=%f",self.vo.valueName,self.vosFrame.origin.x,self.vosFrame.origin.y,self.vosFrame.size.width,self.vosFrame.size.height);
        dtf = [[UITextField alloc] initWithFrame:self.vosFrame];
        
        dtf.borderStyle = UITextBorderStyleRoundedRect;  //Bezel;
        dtf.textColor = [UIColor blackColor];
        dtf.font = [UIFont systemFontOfSize:17.0];
        dtf.backgroundColor = [UIColor whiteColor];
        dtf.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        dtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
        dtf.placeholder = @"<enter number>";
        dtf.textAlignment = UITextAlignmentRight;
        //[dtf addTarget:self action:@selector(numTextFieldClose:) forControlEvents:UIControlEventTouchUpOutside];
        
        dtf.returnKeyType = UIReturnKeyDone;
        
        dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        
        dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
        dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
        
        // Add an accessibility label that describes what the text field is for.
        [dtf setAccessibilityLabel:NSLocalizedString(@"enter a number", @"")];
        dtf.text=@"";
        
    }
    //DBGLog(@"num dtf rc= %d",[dtf retainCount]);
    
    return dtf;
}

- (void) resetData {
    if (nil != dtf) {  // not self as don't want to instantiate prematurely
        self.dtf.text = @"";
    }
}

- (UIView*)voDisplay:(CGRect)bounds {
	self.vosFrame = bounds;

	//if (![self.vo.value isEqualToString:dtf.text]) {
        
        if ([self.vo.value isEqualToString:@""]) {
            if ([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"] /* && ![to hasData] */) {  // only if new entry
                trackerObj *to = (trackerObj*)self.vo.parentTracker;
                to.sql = [NSString stringWithFormat:@"select count(*) from voData where id=%d and date<%d",
                          self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                int v = [to toQry2Int];
                if (v>0) {
                    to.sql = [NSString stringWithFormat:@"select val from voData where id=%d and date<%d order by date desc limit 1;",
                              self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                    NSString *r = [to toQry2Str];
                    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                        self.dtf.textColor = [UIColor lightGrayColor];
                    } else {
                        self.dtf.textColor = [UIColor yellowColor]; //[UIColor lightGrayColor];
                    }
                    self.dtf.backgroundColor = [UIColor darkGrayColor];
                    self.dtf.text = r;
                }
                to.sql = nil;
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
    if ((nil == dtf) // NOT self.dtf as we want to test if is instantiated
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
    
    if (nil == [self.vo.optDict objectForKey:@"nswl"]) 
        [self.vo.optDict setObject:(NSWLDFLT ? @"1" : @"0") forKey:@"nswl"];
    
    if (nil == [self.vo.optDict objectForKey:@"autoscale"]) 
        [self.vo.optDict setObject:(AUTOSCALEDFLT ? @"1" : @"0") forKey:@"autoscale"];

    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = [self.vo.optDict objectForKey:key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"nswl"] && [val isEqualToString:(NSWLDFLT ? @"1" : @"0")])
        ||
        ([key isEqualToString:@"autoscale"] && [val isEqualToString:(AUTOSCALEDFLT ? @"1" : @"0")])
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
	[ctvovc configCheckButton:frame 
                          key:@"swlBtn"
                        state:([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"])  // default:0
                        addsv:YES
    ];
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	
	frame = [ctvovc yAutoscale:frame];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	
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
