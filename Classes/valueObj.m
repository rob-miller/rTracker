//
//  valueObj.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "valueObj.h"


@implementation valueObj

@synthesize vid, vtype, valueName, value, vcolor, vGraphType, display;

extern const NSInteger kViewTag;
extern const NSArray *numGraphs,*textGraphs,*pickGraphs,*boolGraphs;

- (id) init {
	NSLog(@"init valueObj: %@", valueName);
	if (self = [super init]) {
		//valueDate = [[NSDate alloc] init];
		
	}
	return self;
}

/*
- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname {
	NSLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	vid = in_vid;
	vtype = in_vtype;
	switch (in_vtype) {
		case VOT_NUMBER:
		case VOT_SLIDER:
			value = [[NSMutableString alloc] initWithCapacity:10];
			break;
		case VOT_BOOLEAN:
		case VOT_PICK:
			value = [[NSMutableString alloc] initWithCapacity:1];
			break;
		case VOT_TEXT:
		case VOT_FUNC:
			value = [[NSMutableString alloc] initWithCapacity:32];
			break;	
		case VOT_IMAGE:
			value = [[NSMutableString alloc] initWithCapacity:64];
			break;
		case VOT_TEXTB:
			value = [[NSMutableString alloc] initWithCapacity:96];
			break;
		default:
			NSAssert1(0,@"valueObj init vtype %d not supported",in_vtype);
			break;
	}
			
	valueName = in_vname;
	[valueName retain];
	return [self init];
}
*/

- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname in_vcolor:(NSInteger) in_vcolor in_vgraphtype:(NSInteger) in_vgraphtype
{
	NSLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	vid = in_vid;
	vtype = in_vtype;
	switch (in_vtype) {
		case VOT_NUMBER:
		case VOT_SLIDER:
			value = [[NSMutableString alloc] initWithCapacity:10];
			break;
		case VOT_BOOLEAN:
		case VOT_PICK:
			value = [[NSMutableString alloc] initWithCapacity:1];
			break;
		case VOT_TEXT:
		case VOT_FUNC:
			value = [[NSMutableString alloc] initWithCapacity:32];
			break;	
		case VOT_IMAGE:
			value = [[NSMutableString alloc] initWithCapacity:64];
			break;
		case VOT_TEXTB:
			value = [[NSMutableString alloc] initWithCapacity:96];
			break;
		default:
			NSAssert1(0,@"valueObj init vtype %d not supported",in_vtype);
			break;
	}
			
	valueName = in_vname;
	[valueName retain];
	vcolor = in_vcolor;
	vGraphType = in_vgraphtype;
	
	return [self init];
}

- (void) dealloc {
	NSLog(@"dealloc valueObj: %@",valueName);
	[super dealloc];
	[valueName release];
	[value release];
	[display release];
}

- (void) describe {
	
	NSLog(@" value id %d name %@ type %d value .%@.",vid,valueName, vtype, value);
}



#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	NSLog(@"textField done: %@", textField.text);
	[self.value setString:textField.text];
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark valueObj display routines

- (void)displayTextfield:(BOOL)num bounds:(CGRect) bounds
{
	CGRect frame = bounds;
	UITextField * dtf = [[UITextField alloc] initWithFrame:frame];
	
	dtf.borderStyle = UITextBorderStyleRoundedRect;  //Bezel;
	dtf.textColor = [UIColor blackColor];
	dtf.font = [UIFont systemFontOfSize:17.0];
	dtf.backgroundColor = [UIColor whiteColor];
	dtf.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	if (num) {
		dtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
		dtf.placeholder = @"<enter number>";
		dtf.textAlignment = UITextAlignmentRight;
		//[dtf addTarget:self action:@selector(numTextFieldClose:) forControlEvents:UIControlEventTouchUpOutside];
	} else {
		dtf.keyboardType = UIKeyboardTypeDefault;	// use the full keyboard 
		dtf.placeholder = @"<enter text>";
	}

	dtf.returnKeyType = UIReturnKeyDone;
	
	dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
	//UITextFieldDelegate
	dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	
	// Add an accessibility label that describes what the text field is for.
	[dtf setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
	
	NSLog(@"dtf: vo val= %@", self.value);
	if (![value isEqualToString:@""]) {
		dtf.text = self.value;
	}
	
	self.display = dtf;
}


#pragma mark -
#pragma mark UISwitch

- (void)switchAction:(id)sender
{
	// NSLog(@"switchAction: value = %d", [sender isOn]);
}

- (void) displaySwitch 
{
	CGRect frame = CGRectMake(198.0, 12.0, 94.0, 27.0);
	UISwitch * switchCtl = [[UISwitch alloc] initWithFrame:frame];
	[switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	switchCtl.backgroundColor = [UIColor clearColor];
	
	[switchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
	
	switchCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	self.display = switchCtl;
	
}

#pragma mark -
#pragma mark UIButton 

//#define kStdButtonWidth		106.0
//#define kStdButtonHeight	40.0


+ (UIButton *)buttonWithTitle:	(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(UIImage *)image
				 imagePressed:(UIImage *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	//		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//		button.frame = frame;
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	[button autorelease];
	return button;
}

- (BOOL) toggleBoolBtn 
{
	if (value == nil || [value isEqualToString:@""] ||[value isEqualToString:@"0"]) {
		[value setString:@"1"];
		return YES;
	} else {
		[value setString:@"0"];
		return NO;
	}
}

- (UIImage *) boolBtnImage {
	UIImage *chkBox;
	if (value == nil || [value isEqualToString:@""] || [value isEqualToString:@"0"]) {
		chkBox = [UIImage imageNamed:@"chkbox_off.png"];
	} else {
		chkBox = [UIImage imageNamed:@"chkbox_on.png"];
	}
	return chkBox;
}

- (void)boolBtnAction:(UIButton *)imageButton
{
	//NSLog(@"boolBtnAction");
	[self toggleBoolBtn];
	[imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
}


- (void) displayBoolBtn :(CGRect) bounds
{
	// create a UIButton with just an image instead of a title
	
	UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
	UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
	
	//CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
	CGRect frame = bounds;

	UIImage *bbi = [self boolBtnImage];
	frame.origin.x += (frame.size.width - bbi.size.width) / 2.0f;
	frame.size.width = bbi.size.width;
	frame.size.height = bbi.size.height;
	
	UIButton *imageButton = [valueObj buttonWithTitle:@""
												  target:self
											 selector:@selector(boolBtnAction:)
												   frame:frame
												   image:buttonBackground
											imagePressed:buttonBackgroundPressed
										   darkTextColor:YES];
	
	NSLog(@"booBtn: vo val= %@", self.value);
	
	[imageButton setImage:bbi forState: UIControlStateNormal];
	//[imageButton setImage:chkBoxOn forState: UIControlStateHighlighted];
		 
	// Add an accessibility label to the image.
	[imageButton setAccessibilityLabel:NSLocalizedString(@"CheckBoxButton", @"")];
	
	imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	

	self.display = imageButton;
}

#pragma mark -
#pragma mark UISlider

#define kSliderHeight			7.0

- (void)sliderAction:(UISlider *)sender
{ 
	//NSLog(@"slider action value = %f", ((UISlider *)sender).value);
	[self.value setString:[NSString stringWithFormat:@"%f",sender.value]];
}


- (void) displaySlider :(CGRect) bounds
{
	//CGRect frame = CGRectMake(174.0, 12.0, 120.0, kSliderHeight);
	CGRect frame = bounds;
	UISlider * sliderCtl = [[UISlider alloc] initWithFrame:frame];
	[sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	sliderCtl.backgroundColor = [UIColor clearColor];
	
	sliderCtl.minimumValue = 0.0;
	sliderCtl.maximumValue = 100.0;
	sliderCtl.continuous = YES;
	if ([value isEqualToString:@""]) {
		sliderCtl.value = 50.0;  // TODO: default value here
	} else {
		sliderCtl.value = [value floatValue];
	}
	// Add an accessibility label that describes the slider.
	[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
	
	sliderCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	self.display = sliderCtl;
	
}

#pragma mark -
#pragma mark display fn dispatch

- (UIView *) display :(CGRect) bounds
{
	NSLog(@"vo display %@",valueName);
	BOOL num=NO;
	if (display == nil) {
		switch (vtype) {
			case VOT_NUMBER: 
				num=YES;
				//break;
			case VOT_TEXT:
				[self displayTextfield:num bounds:bounds];
				break;
			case VOT_TEXTB:
				NSLog(@"text box not implemented");
				break;
			case VOT_SLIDER: 
				//NSLog(@"slider not implemented");
				[self displaySlider:bounds];
				break;
			case VOT_PICK:
				NSLog(@"pick not implemented");
				break;
			case VOT_BOOLEAN:
				//NSLog(@"bool not implemented");
				//[self displaySwitch];
				[self displayBoolBtn:bounds];
				break;
			case VOT_IMAGE:
				NSLog(@"image not implemented");
				break;
			case VOT_FUNC:
				NSLog(@"func not implemented");
				break;
			default:
				NSLog(@"vtype %d not identified!", vtype);
				break;
		}
	} 
	
	return display;
}

+ (const NSArray *) graphsForVOTCopy:(NSInteger)vot 
{
	NSArray *ret; 
	switch (vot) {
		case VOT_FUNC:
			//break;
		case VOT_SLIDER: 
			//break;
		case VOT_NUMBER: 
			ret = [NSArray arrayWithObjects:@"dots",@"bar",@"line", @"line+dots", nil];
			break;
		case VOT_IMAGE:
			//break;
		case VOT_TEXT:
			//break;
		case VOT_TEXTB:
			ret = [NSArray arrayWithObjects:@"dots", nil];
			break;
		case VOT_PICK:
			ret =  [NSArray arrayWithObjects:@"dots",@"pie", nil];
			break;
		case VOT_BOOLEAN:
			ret = [NSArray arrayWithObjects:@"dots", @"bar", nil];
			break;
		default:
			ret = [NSArray arrayWithObjects:@"dots", @"bar",@"line", @"line+dots", @"pie", nil];
			break;
	}
	
	[ret retain];
	return ret;
}

+ (NSInteger) mapGraphType:(NSString *)gts {
	if ([gts isEqual:@"dots"])
		return VOG_DOTS;
	if ([gts isEqual:@"bar"])
		return VOG_BAR;
	if ([gts isEqual:@"line"])
		return VOG_LINE;
	if ([gts isEqual:@"line+dots"])
		return VOG_DOTSLINE;
	if ([gts isEqual:@"pie"])
		return VOG_PIE;
	
	NSAssert1(0,@"mapGraphTypes: no match for %@",gts);
	
	return 0;
}

@end
