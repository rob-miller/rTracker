//
//  valueObj.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "valueObj.h"


@implementation valueObj

@synthesize vid;
@synthesize vtype;
@synthesize valueName;
@synthesize valueDate;
@synthesize value;
@synthesize votArray;
@synthesize display;

extern const NSInteger kViewTag;

/*
+ (NSArray *) votArray {
	NSString *votS[VOT_MAX];
	votS[VOT_NUMBER] = @"number";
	votS[VOT_SLIDER] = @"slider";
	votS[VOT_TEXT] = @"text";
	votS[VOT_PICK] = @"multiple choice";
	votS[VOT_BOOLEAN] = @"yes/no";
	votS[VOT_IMAGE] = @"image";
	votS[VOT_FUNC] = @"function";
	
	static NSArray *votA = nil;
	
	if (votA == nil) {
		votA = [[NSArray arrayWithObjects:votS count:VOT_MAX] retain];
	}
	
	return votA;
}
*/

- (id) init {
	NSLog(@"init valueObj: %@", valueName);
	if (self = [super init]) {
		valueDate = [[NSDate alloc] init];
		
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath= [bundle pathForResource:@"rt-types" ofType:@"plist"];
		votArray = [[NSArray alloc] initWithContentsOfFile:plistPath]; //
		
	}
	return self;
}

- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname {
	NSLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	vid = in_vid;
	vtype = in_vtype;
	valueName = in_vname;
	[valueName retain];
	return [self init];
}

- (void) dealloc {
	NSLog(@"dealloc valueObj: %@",valueName);
	[super dealloc];
	[valueName release];
	[valueDate release];
	[value release];
	[votArray release];
	[display release];
}

- (void) describe {
	
	NSLog(@" value id %d name %@ type %@ date %@ value .%@.",vid,valueName, [votArray objectAtIndex:vtype], valueDate, value);
}



#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	NSLog(@"textField done");
	[textField resignFirstResponder];
	return YES;
}

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0

#define kTextFieldHeight		30.0
#define kTextFieldWidth	260.0


- (void)displayTextfield:(BOOL)num 
{
	CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
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

#define kStdButtonWidth		106.0
#define kStdButtonHeight	40.0


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
	if (value == nil ) {
		value = @"";
		return YES;
	} else {
		value = nil;
		return NO;
	}
}

- (UIImage *) boolBtnImage {
	UIImage *chkBox;
	if (value == nil) {
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


- (void) displayBoolBtn 
{
	// create a UIButton with just an image instead of a title
	
	UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
	UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
	
	CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
	
	UIButton *imageButton = [valueObj buttonWithTitle:@""
												  target:self
											 selector:@selector(boolBtnAction:)
												   frame:frame
												   image:buttonBackground
											imagePressed:buttonBackgroundPressed
										   darkTextColor:YES];
	
	//[imageButton setImage:[UIImage imageNamed:@"UIButtonfile://localhost/Users/rob/code/UICatalog/ButtonsViewController.m_custom.png"] forState:UIControlStateNormal];
	[imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
	//[imageButton setImage:chkBoxOn forState: UIControlStateHighlighted];
		 
	// Add an accessibility label to the image.
	[imageButton setAccessibilityLabel:NSLocalizedString(@"CheckBoxButton", @"")];
	
	imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	

	self.display = imageButton;
}

#pragma mark -
#pragma mark UISlider

#define kSliderHeight			7.0

- (void)sliderAction:(id)sender
{ 
	NSLog(@"slider action");
}


- (void) displaySlider 
{
	CGRect frame = CGRectMake(174.0, 12.0, 120.0, kSliderHeight);
	UISlider * sliderCtl = [[UISlider alloc] initWithFrame:frame];
	[sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	sliderCtl.backgroundColor = [UIColor clearColor];
	
	sliderCtl.minimumValue = 0.0;
	sliderCtl.maximumValue = 100.0;
	sliderCtl.continuous = YES;
	sliderCtl.value = 50.0;
	
	// Add an accessibility label that describes the slider.
	[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
	
	sliderCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	self.display = sliderCtl;
	
}

#pragma mark -
#pragma mark display fn dispatch

- (UIView *) display {
	BOOL num=NO;
	if (display == nil) {
		switch (vtype) {
			case VOT_NUMBER: 
				num=YES;
				//break;
			case VOT_TEXT:
				[self displayTextfield:num];
				break;
			case VOT_SLIDER: 
				//NSLog(@"slider not implemented");
				[self displaySlider];
				break;
			case VOT_PICK:
				NSLog(@"pick not implemented");
				break;
			case VOT_BOOLEAN:
				//NSLog(@"bool not implemented");
				//[self displaySwitch];
				[self displayBoolBtn];
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


@end
