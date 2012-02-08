//
//  voText.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voText.h"
#import "dbg-defs.h"

@implementation voText

@synthesize dtf;

- (int) getValCap {  // NSMutableString size for value
    return 32;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	DBGLog(@"tf begin editing");
    //*activeField = textField;
	((trackerObj*) self.vo.parentTracker).activeControl = (UIControl*) textField;
}

- (void)tfvoFinEdit:(UITextField*)tf {
	[self.vo.value setString:tf.text];
	tf.textColor = [UIColor blackColor];
    
	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	DBGLog(@"tf end editing");
	[self tfvoFinEdit:textField];
    //*activeField = nil;
	((trackerObj*) self.vo.parentTracker).activeControl = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// the user pressed the "Done" button, so dismiss the keyboard
	//DBGLog(@"textField done: %@", textField.text);
	[self tfvoFinEdit:textField];
	[textField resignFirstResponder];
	return YES;
}

- (void) dealloc {
    DBGLog(@"voText dealloc");
    self.dtf = nil;
    [dtf release];
    [super dealloc];
}


- (UITextField*) dtf {
    if (nil == dtf) {
        dtf = [[UITextField alloc] initWithFrame:self.vosFrame];
        
        dtf.borderStyle = UITextBorderStyleRoundedRect;  //Bezel;
        dtf.textColor = [UIColor blackColor];
        dtf.font = [UIFont systemFontOfSize:17.0];
        dtf.backgroundColor = [UIColor whiteColor];
        dtf.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        dtf.keyboardType = UIKeyboardTypeDefault;	// use the full keyboard 
        dtf.placeholder = @"<enter text>";
        
        dtf.returnKeyType = UIReturnKeyDone;
        
        dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        
        dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
        dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
        
        // Add an accessibility label that describes what the text field is for.
        [dtf setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
        dtf.text = @"";
    }
    
    return dtf;
}

- (void) resetData {
    if (nil != dtf) { // not self, do not instantiate
        self.dtf.text = @"";   
    }
}

- (UIView*)voDisplay:(CGRect)bounds {
	self.vosFrame = bounds;

	if (![self.vo.value isEqualToString:self.dtf.text]) {
		self.dtf.text = self.vo.value;
        DBGLog(@"dtf: vo val= %@ dtf txt= %@", self.vo.value, self.dtf.text);
	}
	
    DBGLog(@"textfield voDisplay: %@", self.dtf.text);
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

#pragma mark -
#pragma mark options page 

- (void) setOptDictDflts {
    
    
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    /*
    NSString *val = [self.vo.optDict objectForKey:key];
    if (nil == val) 
        return YES;
    if (([key isEqualToString:@"shrinkb"] && [val isEqualToString:(SHRINKBDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    */
    return [super cleanOptDictDflts:key];
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect labframe = [ctvovc configLabel:@"Options:" 
								  frame:(CGRect) {MARGIN,ctvovc.lasty,0.0,0.0}
									key:@"gooLab" 
								  addsv:YES ];
	
	ctvovc.lasty += labframe.size.height + MARGIN;
	[super voDrawOptions:ctvovc];
}

#pragma mark -
#pragma mark graph display
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_note:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    return [[vogd alloc] initAsNote:self.vo];
}



@end
