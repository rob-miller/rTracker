//
//  valueObj.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "valueObj.h"
#import "trackerObj.h"
#import "rTracker-constants.h"

@implementation valueObj

@synthesize vid, vtype, valueName, value, vcolor, vGraphType, display, useVO, optDict, parentTracker, checkButtonUseVO;

//extern const NSInteger kViewTag;
extern const NSArray *numGraphs,*textGraphs,*pickGraphs,*boolGraphs;

#pragma mark -
#pragma mark core object methods and support


- (id) init {
	NSLog(@"init valueObj: %@", self.valueName);
	if (self = [super init]) {
		//valueDate = [[NSDate alloc] init];
		self.useVO = NO;
	}
	return self;
}

- (id) init:(id*)parentTO 
	 in_vid:(NSInteger)in_vid 
   in_vtype:(NSInteger)in_vtype 
   in_vname:(NSString *)in_vname 
  in_vcolor:(NSInteger)in_vcolor 
in_vgraphtype:(NSInteger)in_vgraphtype
{
	NSLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	self.parentTracker = parentTO;
	self.vid = in_vid;
	self.vtype = in_vtype;
	switch (in_vtype) {
		case VOT_NUMBER:
		case VOT_SLIDER:
			value = [[NSMutableString alloc] initWithCapacity:10];
			//[self.value setString:@"0"];
			break;
		case VOT_BOOLEAN:
			value = [[NSMutableString alloc] initWithCapacity:1];
			[self.value setString:@"0"];
			break;
		case VOT_CHOICE:
			value = [[NSMutableString alloc] initWithCapacity:1];
			//[self.value setString:@"0"];
			break;
		case VOT_TEXT:
		case VOT_FUNC:
			/*self.*/ value = [[NSMutableString alloc] initWithCapacity:32];
			//[self.value setString:@""];
			break;	
		case VOT_IMAGE:
			/*self.*/ value = [[NSMutableString alloc] initWithCapacity:64];
			//[self.value setString:@""];
			break;
		case VOT_TEXTB:
			/*self.*/ value = [[NSMutableString alloc] initWithCapacity:96];
			//[self.value setString:@""];
			break;
		default:
			NSAssert1(0,@"valueObj init vtype %d not supported",in_vtype);
			break;
	}
		
	self.valueName = in_vname;
	self.vcolor = in_vcolor;
	self.vGraphType = in_vgraphtype;
	
	return [self init];
}

- (void) dealloc 
{
	NSLog(@"dealloc valueObj: %@",valueName);
	self.valueName = nil;
	[valueName release];
	self.value = nil;
	[value release];
	self.display = nil;
	[display release];
	self.optDict = nil;
	[optDict release];
	
	self.checkButtonUseVO = nil;
	[checkButtonUseVO release];
	
	
	
	[super dealloc];
}

- (NSMutableDictionary *) optDict
{
	if (optDict == nil) {
		optDict = [[NSMutableDictionary alloc] init];
	}
	return optDict;
}

#pragma mark -
#pragma mark valueObj display routines
#pragma mark -

#pragma mark textfield

UITextField **activeField;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	NSLog(@"tf begin editing");
    *activeField = textField;
}

- (void)tfvoFinEdit:(UITextField*)tf {
	[self.value setString:tf.text];
	tf.textColor = [UIColor blackColor];
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"tf end editing");
	[self tfvoFinEdit:textField];
    *activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	//NSLog(@"textField done: %@", textField.text);
	[self tfvoFinEdit:textField];
	[textField resignFirstResponder];
	return YES;
}

- (void)displayTextfield:(BOOL)num bounds:(CGRect)bounds
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
		trackerObj *to = (trackerObj*)parentTracker;
		if ([[self.optDict objectForKey:@"nswl"] isEqualToString:@"1"]
			&& ![to hasData]) {  // only if new entry
			to.sql = [NSString stringWithFormat:@"select count(*) from voData where id=%d",self.vid];
			int v = [to toQry2Int];
			if (v>0) {
				to.sql = [NSString stringWithFormat:@"select val from voData where id=%d order by date desc limit 1;",self.vid];
				NSString *r = [to toQry2StrCopy];
				dtf.textColor = [UIColor blueColor];
				dtf.text = r;
				[r release];
			}
			to.sql = nil;
		}
				
	} else {
		dtf.keyboardType = UIKeyboardTypeDefault;	// use the full keyboard 
		dtf.placeholder = @"<enter text>";
	}

	dtf.returnKeyType = UIReturnKeyDone;
	
	dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
	dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	
	// Add an accessibility label that describes what the text field is for.
	[dtf setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
	
	NSLog(@"dtf: vo val= %@", self.value);
	if (![value isEqualToString:@""]) {
		dtf.text = self.value;
	}
	
	/*self.*/ display = dtf;
}


#pragma mark switch

- (void)switchAction:(id)sender
{
	// NSLog(@"switchAction: value = %d", [sender isOn]);
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
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
	
	/*self.*/ display = switchCtl;
	
}

#pragma mark bool button 


- (UIImage *) boolBtnImage {
	// default is not checked
	return ( [self.value isEqualToString:@"1"] ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"] );
}

- (void)boolBtnAction:(UIButton *)imageButton
{  // default is unchecked or nil, so only certain is if =1
	if ([self.value isEqualToString:@"1"]) {
		[self.value setString:@"0"];
		[imageButton setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	} else {  
		[self.value setString:@"1"];
		[imageButton setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];		
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}


- (void) displayBoolBtn :(CGRect) bounds
{

	UIButton *imageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	imageButton.frame = bounds; //CGRectZero;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	[imageButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];		
	[imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
	
	imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells

	/*self.*/ display = imageButton;
}

#pragma mark slider

//#define kSliderHeight			7.0

- (void)sliderAction:(UISlider *)sender
{ 
	//NSLog(@"slider action value = %f", ((UISlider *)sender).value);
	[self.value setString:[NSString stringWithFormat:@"%f",sender.value]];

	if (!self.useVO)
		[self enableVO];

	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (void) displaySlider :(CGRect) bounds
{
	//CGRect frame = CGRectMake(174.0, 12.0, 120.0, kSliderHeight);
	CGRect frame = bounds;
	UISlider * sliderCtl = [[UISlider alloc] initWithFrame:frame];
	[sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	sliderCtl.backgroundColor = [UIColor clearColor];
	
	NSNumber *nsmin = [self.optDict objectForKey:@"smin"];
	NSNumber *nsmax = [self.optDict objectForKey:@"smax"];
	NSNumber *nsdflt = [self.optDict objectForKey:@"sdflt"];
	
	CGFloat smin = (nsmin ? [nsmin floatValue] : SLIDRMINDFLT);
	CGFloat smax = (nsmax ? [nsmax floatValue] : SLIDRMAXDFLT);
	CGFloat sdflt = (nsdflt ? [nsdflt floatValue] : SLIDRDFLTDFLT);
	
	sliderCtl.minimumValue = smin;
	sliderCtl.maximumValue = smax;
	sliderCtl.continuous = YES;
	if ([self.value isEqualToString:@""]) {
		sliderCtl.value = sdflt;  
	} else {
		sliderCtl.value = [self.value floatValue];
	}
	// Add an accessibility label that describes the slider.
	[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
	
	sliderCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	/* self. */ display = sliderCtl;
}

#pragma mark segmented control

- (void) segmentAction:(id) sender
{
	NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
	
	if ([sender selectedSegmentIndex] == UISegmentedControlNoSegment) {
		[self disableVO];
		[self.value setString:@""];
	} else {
		int i;
		[self enableVO];
		// user may leave an intermediate choice title blank, must get their choice number not just seg ndx
		NSString *ch = [(UISegmentedControl*) display titleForSegmentAtIndex:[sender selectedSegmentIndex]];
		for (i=0; i<CHOICES;i++) {
			NSString *key = [NSString stringWithFormat:@"c%d",i];
			NSString *val = [self.optDict objectForKey:key];
			if ([val isEqualToString:ch]) {
				[self.value setString:[NSString stringWithFormat:@"%d",i]];
				break;
			}
		}
		NSAssert(i<CHOICES,@"segmentAction: failed to identify choice!");
		[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
	}
}

- (void) displaySegment:(CGRect)bounds {
	//NSArray *segmentTextContent = [NSArray arrayWithObjects: @"0", @"one", @"two", @"three", @"four", nil];

	int i;
	NSMutableArray *segmentTextContent = [[NSMutableArray alloc] init];
	for (i=0;i<CHOICES;i++) {
		NSString *key = [NSString stringWithFormat:@"c%d",i];
		NSString *s = [self.optDict objectForKey:key];
		if ((s != nil) && (![s isEqualToString:@""])) 
			[segmentTextContent addObject:s];
	}
	//[segmentTextContent addObject:nil];

	CGRect frame = bounds;
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	
	if ([self.optDict objectForKey:@"shrinkb"]) {  // default is NO, so a defined result means yes
		int j=0;
		for (NSString *s in segmentTextContent) {
			CGSize siz = [s sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
			[segmentedControl setWidth:siz.width forSegmentAtIndex:j];
			j++;
		}
	}
	[segmentTextContent release];
	
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;

	if ([self.value isEqualToString:@""]) {
		segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
		[self disableVO];
	} else {
		segmentedControl.selectedSegmentIndex = [self.value integerValue];
	}
	
	//[segmentedControl setWidth:20.0f forSegmentAtIndex:0];
	//segmentedControl.tintColor = [UIColor colorWithRed:0.70 green:0.171 blue:0.1 alpha:70.0];
	//segmentedControl.alpha = 20.0f;
	
	segmentedControl.tag = kViewTag;
	display = segmentedControl;
}

#pragma mark displayFunction

- (void) displayFunc:(CGRect)bounds {
	
	//trackerObj *to = (trackerObj*) parentTracker;
	
	UILabel *rlab = [[UILabel alloc] initWithFrame:bounds];
	rlab.backgroundColor = [UIColor grayColor];
	rlab.textAlignment = UITextAlignmentRight;
	rlab.text = @"42";
	
	display = rlab;
}

#pragma mark -
#pragma mark display fn dispatch

- (UIView *) display:(CGRect)bounds af:(UITextField**)af; {
	NSLog(@"vo display %@",self.valueName);
	BOOL num=NO;
	activeField = af;
	if (display == nil) {
		switch (self.vtype) {
			case VOT_NUMBER: 
				num=YES;
				//break;
			case VOT_TEXT:
				[self displayTextfield:num bounds:bounds];
				break;
			case VOT_TEXTB:
				NSLog(@"text box not implemented");
				// don't forget addressbook names picker
				break;
			case VOT_SLIDER: 
				//NSLog(@"slider not implemented");
				[self displaySlider:bounds];
				break;
			case VOT_CHOICE:
				[self displaySegment:bounds];
				break;
			case VOT_BOOLEAN:
				[self displayBoolBtn:bounds];
				break;
			case VOT_IMAGE:
				NSLog(@"image not implemented");
				break;
			case VOT_FUNC:
				NSLog(@"func not implemented");
				[self displayFunc:bounds];
				break;
			default:
				NSLog(@"vtype %d not identified!", self.vtype);
				break;
		}
	} 
	
	return display;
}

#pragma mark -
#pragma mark checkButton support

- (void) enableVO 
{
	if (!self.useVO) {
		self.useVO = YES;
		[self.checkButtonUseVO setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
	}
}

- (void) disableVO 
{
	if (self.useVO) {
		self.useVO = NO;
		[self.checkButtonUseVO setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
	}
}


// called when the checkmark button is touched 
- (void)checkAction:(id)sender
{
	NSLog(@"checkbox ticked for %@ new state= %d",valueName, !self.useVO);
	UIImage *checkImage;
	
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	//self.useVO = !self.useVO;

	if (self.useVO = !self.useVO) {
		checkImage = [UIImage imageNamed:@"checked.png"];
		if (self.vtype == VOT_SLIDER)
			[self.value setString:[NSString stringWithFormat:@"%f",((UISlider*)self.display).value]];
	} else {
		checkImage = [UIImage imageNamed:@"unchecked.png"];
		if (self.vtype == VOT_CHOICE)
			((UISegmentedControl *) self.display).selectedSegmentIndex =  UISegmentedControlNoSegment;
		else if (self.vtype == VOT_SLIDER) {
			NSNumber *nsdflt = [self.optDict objectForKey:@"sdflt"];
			CGFloat sdflt =  nsdflt ? [nsdflt floatValue] : SLIDRDFLTDFLT;
			[((UISlider *) self.display) setValue:sdflt animated:YES];
		}
	}

	[checkButtonUseVO setImage:checkImage forState:UIControlStateNormal];
	
}

- (UIButton *) checkButtonUseVO
{
	if (checkButtonUseVO == nil) {
		checkButtonUseVO = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		checkButtonUseVO.frame = CGRectZero;
		checkButtonUseVO.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		checkButtonUseVO.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[checkButtonUseVO addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchDown];		
	}
	return checkButtonUseVO;
}

#pragma mark -
#pragma mark utility methods

- (void) describe 
{
	NSLog(@" value id %d name %@ type %d value .%@.",self.vid,self.valueName, self.vtype, self.value);
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
			//ret = [NSArray arrayWithObjects:@"dots",@"bar",@"line", @"line+dots", nil];
			ret = [[NSArray alloc] initWithObjects:@"dots",@"bar",@"line", @"line+dots", /*@"no graph",*/ nil];
			break;
		case VOT_IMAGE:
			//break;
		case VOT_TEXT:
			//break;
		case VOT_TEXTB:
			//ret = [NSArray arrayWithObjects:@"dots", nil];
			ret = [[NSArray alloc] initWithObjects:@"dots", /*@"no graph",*/ nil];
			break;
		case VOT_CHOICE:
			//ret =  [NSArray arrayWithObjects:@"dots",@"pie", nil];
			ret =  [[NSArray alloc] initWithObjects:@"dots",@"pie", /*@"no graph",*/ nil];
			break;
		case VOT_BOOLEAN:
			//ret = [NSArray arrayWithObjects:@"dots", @"bar", nil];
			ret = [[NSArray alloc] initWithObjects:@"dots", @"bar", /*@"no graph",*/ nil];
			break;
		default:
			//ret = [NSArray arrayWithObjects:@"dots", @"bar",@"line", @"line+dots", @"pie", nil];
			ret = [[NSArray alloc] initWithObjects:@"dots", @"bar",@"line", @"line+dots", @"pie", /*@"no graph",*/ nil];
			break;
	}
	
	//[ret retain ];  //]autorelease]; //retain?
	//[ret autorelease];
	return ret;
}

// object version so can change components dynamically
- (const NSArray *) graphsForVOTCopy:(NSInteger)vot 
{
	if (vot == VOT_TEXTB) {
		if ([self.optDict objectForKey:@"tbnl"]) // default is no and thus nil, so any defined val means linecount is a num for graph
			return [[NSArray alloc] initWithObjects:@"dots",@"bar",@"line", @"line+dots", /*@"no graph",*/ nil];
	}
	return [valueObj graphsForVOTCopy:vot];
	
		
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
	if ([gts isEqual:@"no graph"])
		return VOG_NONE;
	
	NSAssert1(0,@"mapGraphTypes: no match for %@",gts);
	
	return 0;
}

@end
