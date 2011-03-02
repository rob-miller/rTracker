//
//  voNumber.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voNumber.h"


@implementation voNumber

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	NSLog(@"tf begin editing");
    //*activeField = textField;
	((trackerObj*) self.vo.parentTracker).activeControl = (UIControl*) textField;
}

- (void)tfvoFinEdit:(UITextField*)tf {
	tf.textColor = [UIColor blackColor];
	[self.vo.value setString:tf.text];
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSLog(@"tf end editing");
	[self tfvoFinEdit:textField];
    //*activeField = nil;
	((trackerObj*) self.vo.parentTracker).activeControl = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// the user pressed the "Done" button, so dismiss the keyboard
	//NSLog(@"textField done: %@", textField.text);
	[self tfvoFinEdit:textField];
	[textField resignFirstResponder];
	return YES;
}

- (UIView*)voDisplay:(CGRect)bounds {
	CGRect frame = bounds;
	UITextField * dtf = [[UITextField alloc] initWithFrame:frame];
	
	dtf.borderStyle = UITextBorderStyleRoundedRect;  //Bezel;
	dtf.textColor = [UIColor blackColor];
	dtf.font = [UIFont systemFontOfSize:17.0];
	dtf.backgroundColor = [UIColor whiteColor];
	dtf.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	dtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
	dtf.placeholder = @"<enter number>";
	dtf.textAlignment = UITextAlignmentRight;
	//[dtf addTarget:self action:@selector(numTextFieldClose:) forControlEvents:UIControlEventTouchUpOutside];
	trackerObj *to = (trackerObj*)self.vo.parentTracker;
	if ([self.vo.value isEqualToString:@""]) {
		if ([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"]
			/* && ![to hasData] */) {  // only if new entry
			to.sql = [NSString stringWithFormat:@"select count(*) from voData where id=%d",self.vo.vid];
			int v = [to toQry2Int];
			if (v>0) {
				to.sql = [NSString stringWithFormat:@"select val from voData where id=%d order by date desc limit 1;",self.vo.vid];
				NSString *r = [to toQry2Str];
				dtf.textColor = [UIColor grayColor];
				dtf.text = r;
			}
			to.sql = nil;
		}
	} else {
		dtf.text = self.vo.value;
	}
	
	
	dtf.returnKeyType = UIReturnKeyDone;
	
	dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
	dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	
	// Add an accessibility label that describes what the text field is for.
	[dtf setAccessibilityLabel:NSLocalizedString(@"enter a number", @"")];
	
	NSLog(@"dtf: vo val= %@", self.vo.value);
	
	return [dtf autorelease];
}


- (NSArray*) voGraphSet {
	return [voState voGraphSetNum];
}


- (void) voDrawOptions:(configTVObjVC*)ctvovc {

	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"start with last saved value:" frame:frame key:@"swlLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[ctvovc configCheckButton:frame 
						key:@"swlBtn" 
					  state:([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"]) ]; // default:0
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

@end
