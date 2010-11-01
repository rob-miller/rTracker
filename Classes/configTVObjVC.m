//
//  configTVObjVC.m
//  rTracker
//
//  Created by Robert Miller on 09/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "configTVObjVC.h"

#import "addValObjController.h"
#import "rTracker-constants.h"

//  private methods including properties can go here!
@interface configTVObjVC ()
- (void) updateFnTitles;
//@property (nonatomic, retain) NSNumber *foo;
@end


@implementation configTVObjVC

@synthesize to, vo, wDict;
@synthesize toolBar, navBar;
@synthesize epTitles, fnTitles, fnStrs, fnArray, lasty, saveFrame, fnSegNdx;

BOOL keyboardIsShown;

CGFloat LFHeight;  // textfield height based on parent viewcontroller's xib

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {

	self.to = nil;
	[to release];
	self.vo = nil;
	[vo release];
	
	self.wDict = nil;
	[wDict release];
	
	self.toolBar = nil;
	[toolBar release];
	self.navBar = nil;
	[navBar release];

	self.epTitles = nil;
	[epTitles release];

	self.fnArray = nil;
	[fnArray release];
	self.fnStrs = nil;
	[fnStrs release];
	
    [super dealloc];
}

# pragma mark -
# pragma mark view support


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)btnDone:(UIButton *)btn
{
	NSLog(@"configTVObjVC: btnDone pressed.");
	if (fnArray != nil && [self.fnArray count] != 0) {
		[self.vo.optDict setObject:[self.fnArray componentsJoinedByString:@" "] forKey:@"func"];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

//- (IBAction) backgroundTap:(id)sender {
//	[activeField resignFirstResponder];
//}
//

- (void)viewDidLoad {

	NSString *name;
	if (self.vo == nil) {
		name = self.to.trackerName;
	} else {
		name = self.vo.valueName;
		self.epTitles = [NSArray arrayWithObjects: @"entry", @"hours", @"days", @"weeks", @"months", @"years", nil];
	}
	
	if ((name == nil) || [name isEqualToString:@""]) 
		name = [NSString stringWithFormat:@"<%@>",[self.to.votArray objectAtIndex:vo.vtype]];
	[[self.navBar.items lastObject] setTitle:[NSString stringWithFormat:@"configure %@",name]];
	name = nil;
	 
	LFHeight = 31.0f; 
	//LFHeight = ((addValObjController *) [self parentViewController]).labelField.frame.size.height;
	
	self.lasty = self.navBar.frame.size.height + MARGIN;
	if (self.vo == nil) {
		[self addTOFields];
	} else {
		[self addVOFields:self.vo.vtype];
	}

	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								target:self
								action:@selector(btnDone:)];
	
	if (self.vo != nil && self.vo.vtype == VOT_FUNC && [self.to.valObjTable count] > 0) {
		[self.fnArray addObjectsFromArray:[[self.vo.optDict objectForKey:@"func"] componentsSeparatedByString:@" "]];
		
		UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
													initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
													target:nil action:nil];
		
		NSArray *segmentTextContent = [NSArray arrayWithObjects: @"overview", @"range", @"fn definition", nil];
		
		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
		//[segmentTextContent release];
		
		[segmentedControl addTarget:self action:@selector(fnSegmentAction:) forControlEvents:UIControlEventValueChanged];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.selectedSegmentIndex = self.fnSegNdx = 0;
		UIBarButtonItem *scButtonItem = [[UIBarButtonItem alloc]
												 initWithCustomView:segmentedControl];
		
		self.toolBar.items = [NSArray arrayWithObjects: doneBtn, flexibleSpaceButtonItem, scButtonItem, flexibleSpaceButtonItem, nil];
		[segmentedControl release];
		[scButtonItem release];
		[flexibleSpaceButtonItem release];
	} else {
		self.toolBar.items = [NSArray arrayWithObjects: doneBtn, nil];
	}
	[doneBtn release];
	
	// register for keyboard notifications
	keyboardIsShown = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification 
											   object:self.view.window];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	///*
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
	//*/
	
	self.wDict = nil;
	self.to = nil;
	self.vo = nil;
	self.epTitles = nil;
	self.fnArray = nil;
	self.fnStrs = nil;
	
	self.toolBar = nil;
	self.navBar = nil;

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	NSLog(@"I am touched at %f, %f.",touchPoint.x, touchPoint.y);
	
	[activeField resignFirstResponder];
}

# pragma mark -
# pragma mark textField support Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	NSLog(@"tf begin editing");
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"tf end editing");
    activeField = nil;
}




 
# pragma mark -
# pragma mark keyboard notifications

- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) { // need bit more logic to handle additional scrolling for another textfield
        return;
    }
	
	//NSLog(@"handling keyboard will show");
	self.saveFrame = self.view.frame;
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	CGRect viewFrame = self.view.frame;
	//NSLog(@"k will show, y= %f",viewFrame.origin.y);
	CGFloat boty = activeField.frame.origin.y + activeField.frame.size.height + MARGIN;
	CGFloat topk = viewFrame.size.height - keyboardSize.height;  // - viewFrame.origin.y;
	if (boty <= topk) {
		//NSLog(@"activeField visible, do nothing  boty= %f  topk= %f",boty,topk);
	} else {
		//NSLog(@"activeField hidden, scroll up  boty= %f  topk= %f",boty,topk);
		
		viewFrame.origin.y -= (boty - topk);
		viewFrame.size.height -= self.toolBar.frame.size.height - MARGIN;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		[self.view setFrame:viewFrame];
		
		[UIView commitAnimations];
	}
	
    keyboardIsShown = YES;
	
}
- (void)keyboardWillHide:(NSNotification *)n
{
	//NSLog(@"handling keyboard will hide");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.view setFrame:self.saveFrame];
	
	[UIView commitAnimations];
	
    keyboardIsShown = NO;	
}



# pragma mark -
# pragma mark config region support Methods

#pragma mark newWidget methods

- (CGRect) configLabel:(NSString *)text frame:(CGRect)frame key:(NSString*)key addsv:(BOOL)addsv
{
	frame.size = [text sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]]];
	
	UILabel *rlab = [[UILabel alloc] initWithFrame:frame];
	rlab.text = text;
	rlab.backgroundColor = [UIColor clearColor];

	[self.wDict setObject:rlab forKey:key];
	if (addsv)
		[self.view addSubview:rlab];
	
	CGRect retFrame = rlab.frame;
	[rlab release];
	
	return retFrame;
}

- (void) checkBtnAction:(UIButton*)btn
{
	NSString *okey, *dflt, *ndflt, *img;
	BOOL dfltState;
	
	if ( btn == [self.wDict objectForKey:@"nasBtn"] ) {
		okey = @"autoscale"; dfltState=AUTOSCALEDFLT;
		if ([(NSString*) [self.vo.optDict objectForKey:okey] isEqualToString:@"0"]) { // will switch on
			[self removeGraphMinMax];
		} else {
			[self addGraphMinMax];
		}
	} else if ( btn == [self.wDict objectForKey:@"csBtn"] ) {
		okey = @"shrinkb"; dfltState=SHRINKBDFLT;
	} else if ( btn == [self.wDict objectForKey:@"tbnlBtn"] ) {
		okey = @"tbnl"; dfltState=TBNLDFLT;
	} else if ( btn == [self.wDict objectForKey:@"tbabBtn"] ) {
		okey = @"tbab"; dfltState=TBABDFLT;
	} else if ( btn == [self.wDict objectForKey:@"ggBtn"] ) {
		okey = @"graph"; dfltState=GRAPHDFLT;
	} else if ( btn == [self.wDict objectForKey:@"swlBtn"] ) {
		okey = @"nswl"; dfltState=NSWLDFLT;
	} else if ( btn == [self.wDict objectForKey:@"srBtn"] ) {
		okey = @"savertn"; dfltState=SAVERTNDFLT;
	}else {
		NSAssert(0,@"ckButtonAction cannot identify btn");
	}
	
	if (dfltState == YES) {
		dflt=@"1"; ndflt = @"0";
	} else {
		dflt=@"0"; ndflt = @"1";
	}
	
	if (self.vo == nil) {
		if ([(NSString*) [self.to.optDict objectForKey:okey] isEqualToString:ndflt]) {
			[self.to.optDict setObject:dflt forKey:okey]; 
			img = (dfltState ? @"checked.png" : @"unchecked.png"); // going to default state
		} else {
			[self.to.optDict setObject:ndflt forKey:okey];
			img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
		}
	} else {
		if ([(NSString*) [self.vo.optDict objectForKey:okey] isEqualToString:ndflt]) {
			[self.vo.optDict setObject:dflt forKey:okey]; 
			img = (dfltState ? @"checked.png" : @"unchecked.png"); // going to default state
		} else {
			[self.vo.optDict setObject:ndflt forKey:okey];
			img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
		}
	}
	[btn setImage:[UIImage imageNamed:img] forState: UIControlStateNormal];
	
}

- (void) configCheckButton:(CGRect)frame key:(NSString*)key state:(BOOL)state
{
	UIButton *imageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	imageButton.frame = frame;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;

	[self.wDict setObject:imageButton forKey:key];
	[imageButton addTarget:self action:@selector(checkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[imageButton setImage:[UIImage imageNamed:(state ? @"checked.png" : @"unchecked.png")] 
				 forState: UIControlStateNormal];
	
	[self.view addSubview:imageButton];
	[imageButton release];
}

- (void) configActionBtn:(CGRect)frame key:(NSString*)key label:(NSString*)label action:(SEL)action {

	UIButton *button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	frame.size.width = [label sizeWithFont:button.titleLabel.font].width + 4*SPACE;
	if (frame.origin.x == -1.0f) {
		frame.origin.x = self.view.frame.size.width - (frame.size.width + MARGIN); // right justify
	}
	button.frame = frame;
	[button setTitle:label forState:UIControlStateNormal];
	//imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	
	[self.wDict setObject:button forKey:key];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:button];
	[button release];
}

- (void) tfDone:(UITextField *)tf
{
	NSString *okey, *nkey;
	if ( tf == [self.wDict objectForKey:@"nminTF"] ) {
		okey = @"gmin";
		nkey = @"nmaxTF";
	} else if ( tf == [self.wDict objectForKey:@"nmaxTF"] ) {
		okey = @"gmax";
		nkey = nil;
	} else if ( tf == [self.wDict objectForKey:@"sminTF"] ) {
		okey = @"smin";
		nkey = @"smaxTF";
	} else if ( tf == [self.wDict objectForKey:@"smaxTF"] ) {
		okey = @"smax";
		nkey = @"sdfltTF";
	} else if ( tf == [self.wDict objectForKey:@"sdfltTF"] ) {
		okey = @"sdflt";
		nkey = nil;
	} else if ( tf == [self.wDict objectForKey:@"gpTF"] ) {
		okey = @"privacy";
		nkey = nil;
	} else if ( tf == [self.wDict objectForKey:@"fr0TF"] ) {
		okey = @"frv0";
		nkey = nil;
	} else if ( tf == [self.wDict objectForKey:@"fr1TF"] ) {
		okey = @"frv1";
		nkey = nil;
	} else {
		NSAssert(0,@"mtfDone cannot identify tf");
	}

	NSLog(@"set %@: %@", okey, tf.text);
	
	[self.vo.optDict setObject:tf.text forKey:okey];
	if (nkey) {
		[[self.wDict objectForKey:nkey] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
}


- (void) configTextField:(CGRect)frame key:(NSString*)key action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text addsv:(BOOL)addsv
{
	frame.origin.y -= TFXTRA;
	UITextField *rtf = [[UITextField alloc] initWithFrame:frame ];
	rtf.clearsOnBeginEditing = NO;
	[rtf setDelegate:self];
	rtf.returnKeyType = UIReturnKeyDone;
	rtf.borderStyle = UITextBorderStyleRoundedRect;
	[self.wDict setObject:rtf forKey:key];
	
	if (action != nil) 
		[rtf addTarget:self action:action forControlEvents:UIControlEventEditingDidEndOnExit];
	else
		[rtf addTarget:self action:@selector(tfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	if (num) {
		rtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
		rtf.textAlignment = UITextAlignmentRight;
	}
	rtf.placeholder = place;
	
	if (text)
		rtf.text = text;
	
	if (addsv)
		[self.view addSubview:rtf];
	
	[rtf release];
}

- (void) configTextView:(CGRect)frame key:(NSString*)key text:(NSString*)text {

	UITextView *rtv = [[UITextView alloc] initWithFrame:frame];
	rtv.editable = NO;
	[self.wDict setObject:rtv forKey:key];
	
	rtv.text = text;
	[self.view addSubview:rtv];
	[rtv release];
}


- (CGRect) configPicker:(CGRect)frame key:(NSString*)key
{
	UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	frame.size = [myPickerView sizeThatFits:CGSizeZero];;
	myPickerView.frame = frame;
	
	myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	myPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	myPickerView.delegate = self;
	myPickerView.dataSource = self;
	
	[self.wDict setObject:myPickerView forKey:key];
	[self.view addSubview:myPickerView];
	
	[myPickerView release];
	
	return frame;
}

#pragma mark autoscale / graph min/max options

- (void) removeGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[[self.wDict objectForKey:@"nminLab"] removeFromSuperview];
	[[self.wDict objectForKey:@"nminTF"] removeFromSuperview];
	[[self.wDict objectForKey:@"nmaxLab"] removeFromSuperview];
	[[self.wDict objectForKey:@"nmaxTF"] removeFromSuperview];
	
	[UIView commitAnimations];
}

- (void) addGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.view addSubview:[self.wDict objectForKey:@"nminLab"]];
	[self.view addSubview:[self.wDict objectForKey:@"nminTF"]];
	[self.view addSubview:[self.wDict objectForKey:@"nmaxLab"]];
	[self.view addSubview:[self.wDict objectForKey:@"nmaxTF"]];
	
	[UIView commitAnimations];
}

- (CGRect) yAutoscale:(CGRect)frame {
	CGRect labframe;
	
	
	labframe = [self configLabel:@"Graph Y axis:" frame:frame key:@"ngLab" addsv:YES];
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [self configLabel:@"Auto Scale:" frame:frame key:@"nasLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	[self configCheckButton:frame 
						key:@"nasBtn" 
					  state:(![[self.vo.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) ]; // default:1
	
	//if (! autoscale) {  still need to calc lasty, make room before general options
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"min:" frame:frame key:@"nminLab" addsv:NO];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"nminTF" 
				   action:nil
					  num:YES 
					place:@"<number>" 
					 text:[self.vo.optDict objectForKey:@"ngmin"] 
					addsv:NO ];
	
	frame.origin.x += tfWidth + MARGIN;
	labframe = [self configLabel:@" max:" frame:frame key:@"nmaxLab" addsv:NO];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"nmaxTF" 
				   action:nil
					  num:YES 
					place:@"<number>" 
					 text:[self.vo.optDict objectForKey:@"ngmax"]
					addsv:NO ];
	
	if ([[self.vo.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) 
		[self addGraphMinMax];
	
	return frame;
}


- (void) drawNumOpts 
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"start with last saved value:" frame:frame key:@"swlLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[self configCheckButton:frame 
				   key:@"swlBtn" 
				 state:([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"]) ]; // default:0
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	
	frame = [self yAutoscale:frame];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	
	//-- title label
	
	labframe = [self configLabel:@"Other options:" frame:frame key:@"noLab" addsv:YES];
	
	self.lasty = frame.origin.y + labframe.size.height + MARGIN;
	
}

#pragma mark choice valObj options 

- (void) ctfDone:(UITextField *)tf
{
	int i=0;
	NSString *key;
	for (key in self.wDict) {
		if ([self.wDict objectForKey:key] == tf) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dtf",&i);
			break;
		}
	}
	
	NSLog(@"set choice %d: %@",i, tf.text);
	[self.vo.optDict setObject:tf.text forKey:[NSString stringWithFormat:@"c%d",i]];
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	UIButton *b = [self.wDict objectForKey:[NSString stringWithFormat:@"%dbtn",i]];
	if ([tf.text isEqualToString:@""]) {
		b.backgroundColor = [UIColor clearColor];
		[self.vo.optDict removeObjectForKey:cc];
		// TODO: should offer to delete any stored data
	} else {
		NSNumber *ncol = [self.vo.optDict objectForKey:cc];
		
		if (ncol == nil) {
			NSInteger col = [self.to nextColor];
			[self.vo.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
			b.backgroundColor = [self.to.colorSet objectAtIndex:col];
		} 
	}
	if (++i<CHOICES) {
		[[self.wDict objectForKey:[NSString stringWithFormat:@"%dtf",i]] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
}

- (void) choiceColorButtonAction:(UIButton *)btn
{
	int i=0;
	
	for (NSString *key in self.wDict) {
		if ([self.wDict objectForKey:key] == btn) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dbtn",&i);
			break;
		}
	}
	
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	NSNumber *ncol = [self.vo.optDict objectForKey:cc];
	if (ncol == nil) {
		// do nothing as no choice label set so button not active
	} else {
		NSInteger col = [ncol integerValue];
		if (++col >= [self.to.colorSet count])
			col=0;
		[self.vo.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
		btn.backgroundColor = [self.to.colorSet objectAtIndex:col];
	}
	
}

- (void) drawChoiceOpts 
{
	
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"Choices:" frame:frame key:@"coLab" addsv:YES ];
	
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
	
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	int i,j=1;
	for (i=0; i<CHOICES; i++) {
		
		[self configTextField:frame 
							 key:[NSString stringWithFormat:@"%dtf",i] 
						  action:@selector(ctfDone:) 
						  num:NO 
						   place:[NSString stringWithFormat:@"choice %d",i+1]
							text:[self.vo.optDict objectForKey:[NSString stringWithFormat:@"c%d",i]]
						   addsv:YES ];
		
		frame.origin.x += MARGIN + tfWidth;
		
		//frame.size.height = 1.2* frame.size.height;
		frame.size.width = frame.size.height;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = frame;
		[[btn layer] setCornerRadius:8.0f];
		[[btn layer] setMasksToBounds:YES];
		[[btn layer] setBorderWidth:1.0f];
		NSNumber *cc = [self.vo.optDict objectForKey:[NSString stringWithFormat:@"cc%d",i]];
		if (cc == nil) {
			btn.backgroundColor = [UIColor clearColor];
		} else {
			btn.backgroundColor = [self.to.colorSet objectAtIndex:[cc integerValue]];
		}
		
		[btn addTarget:self action:@selector(choiceColorButtonAction:) forControlEvents:UIControlEventTouchDown];
		[self.wDict setObject:btn forKey:[NSString stringWithFormat:@"%dbtn",i]];
		[self.view addSubview:btn];
		
		frame.origin.x = MARGIN + (j * (tfWidth + LFHeight + 2*MARGIN));
		j = ( j ? 0 : 1 ); // j toggles 0-1
		frame.origin.y += j * ((2*MARGIN) + LFHeight);
		frame.size.width = tfWidth;
		//frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
	}

	//frame.origin.y -= MARGIN; // remove extra from end of loop, add one back for next line
	frame.origin.x = MARGIN;
	
	//-- general options label
	
	labframe = [self configLabel:@"Other options:" frame:frame key:@"goLab" addsv:YES];
	
	frame.origin.y += labframe.size.height + MARGIN;

	labframe = [self configLabel:@"Shrink buttons:" frame:frame key:@"csbLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	[self configCheckButton:frame 
				   key:@"csbBtn" 
				 state:[[self.vo.optDict objectForKey:@"shrinkb"] isEqualToString:@"1"] ]; // default:0
	
	self.lasty = frame.origin.y + frame.size.height + MARGIN;
	
}	

#pragma mark slider options

- (void) drawSliderOpts 
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"Slider range:" frame:frame key:@"srLab" addsv:YES];
	
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;

	labframe = [self configLabel:@"min:" frame:frame key:@"sminLab" addsv:YES];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; 
	
	[self configTextField:frame 
					  key:@"sminTF" 
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%3.1f",SLIDRMINDFLT] 
					 text:[self.vo.optDict objectForKey:@"smin"] 
					addsv:YES ];
	
	frame.origin.x += tfWidth + MARGIN;
	labframe = [self configLabel:@" max:" frame:frame key:@"smaxLab" addsv:YES];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; 
	
	[self configTextField:frame 
					  key:@"smaxTF" 
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%3.1f",SLIDRMAXDFLT] 
					 text:[self.vo.optDict objectForKey:@"smax"]
					addsv:YES ];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = 8*MARGIN;
	
	labframe = [self configLabel:@"default:" frame:frame key:@"sdfltLab" addsv:YES];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; 
	
	[self configTextField:frame 
					  key:@"sdfltTF" 
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%3.1f",SLIDRDFLTDFLT]
					 text:[self.vo.optDict objectForKey:@"sdflt"]
					addsv:YES ];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	//-- title label
	
	labframe = [self configLabel:@"Other options:" frame:frame key:@"soLab" addsv:YES];
	
	self.lasty = frame.origin.y + labframe.size.height + MARGIN;
	
	
}

#pragma mark textbox options

- (void) drawTextbOpts
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	CGRect labframe = [self configLabel:@"Text box options:" frame:frame key:@"tboLab" addsv:YES];
	frame.origin.y += labframe.size.height + MARGIN;
	labframe = [self configLabel:@"Use number of lines for graph:" frame:frame key:@"tbnlLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[self configCheckButton:frame 
						key:@"tbnlBtn" 
					  state:[[self.vo.optDict objectForKey:@"tbnl"] isEqualToString:@"1"] ]; // default:0
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"Pick names from addressbook:" frame:frame key:@"tbabLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[self configCheckButton:frame 
						key:@"tbabBtn" 
					  state:[[self.vo.optDict objectForKey:@"tbab"] isEqualToString:@"1"] ]; // default:0
	
//	frame.origin.x = MARGIN;
//	frame.origin.y += MARGIN + frame.size.height;
//
//	labframe = [self configLabel:@"Other options:" frame:frame key:@"soLab" addsv:YES];
	
	self.lasty = frame.origin.y + labframe.size.height + MARGIN;
	
}

#pragma mark image options

- (void) drawImageOpts
{
	CGRect labframe = [self configLabel:@"need Image Location -- Options:" 
								  frame:(CGRect) {MARGIN,self.lasty,0.0,0.0}
									key:@"ioLab" 
								  addsv:YES ];
	
	self.lasty += labframe.size.height + MARGIN;
}

#pragma mark function options
- (NSMutableArray*) fnTitles {
	if (fnTitles == nil) {
		fnTitles = [[NSMutableArray alloc] init];
	}
	return fnTitles;
}

- (NSMutableArray*) fnArray {
	if (fnArray == nil) {
		fnArray = [[NSMutableArray alloc] init];
	}
	return fnArray;
}

- (NSMutableArray*) fnStrs {
	if (fnStrs == nil) {
		fnStrs = [[NSMutableArray alloc] initWithObjects:FnArrStrs,nil];
		for (valueObj* valo in self.to.valObjTable) {
			[fnStrs addObject:valo.valueName];
		}
	}
	return fnStrs;
}


- (NSInteger) epToRow:(NSInteger)component {
	NSString *key = [NSString stringWithFormat:@"frep%d",component];
	NSNumber *n = [self.vo.optDict objectForKey:key];
	NSInteger ep = [n integerValue];
	if (n == nil || ep == FREPDFLT) 
		return 0;
	if (ep >= 0)
		return ep+1;
	return (ep * -1) + [self.to.valObjTable count] -1;
}

- (NSString *) fnrRowTitle:(NSInteger)row {
	if (row != 0) {
		NSInteger votc = [self.to.valObjTable count];
		if (row <= votc) {
			return ((valueObj*) [self.to.valObjTable objectAtIndex:row-1]).valueName;
		} else {
			row -= votc;
		}
	}
	return [self.epTitles objectAtIndex:row];
}

- (void) updateValTF:(NSInteger)row component:(NSInteger)component {
	NSInteger votc = [self.to.valObjTable count];

	if (row > votc) {
		NSString *vkey = [NSString stringWithFormat:@"frv%d",component];
		NSString *key = [NSString stringWithFormat:@"frep%d",component];
		NSString *vtfkey = [NSString stringWithFormat:@"fr%dTF",component];
		NSString *pre_vkey = [NSString stringWithFormat:@"frpre%dvLab",component];
		NSString *post_vkey = [NSString stringWithFormat:@"frpost%dvLab",component];
		
		[self.vo.optDict setObject:[NSNumber numberWithInt:(((row - votc) +1) * -1)] forKey:key];
		UITextField *vtf= [self.wDict objectForKey:vtfkey];
		vtf.text = [self.vo.optDict objectForKey:vkey];
		[self.view addSubview:vtf];
		[self.view addSubview:[self.wDict objectForKey:pre_vkey]];
		UILabel *postLab = [self.wDict objectForKey:post_vkey];
		postLab.text = [self fnrRowTitle:row];
		[self.view addSubview:postLab];
	}
}

- (void) drawFuncOptsRange {
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};

	CGRect labframe = [self configLabel:@"Function range endpoints:" 
								  frame:frame
									key:@"freLab" 
								  addsv:YES ];
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;

	labframe = [self configLabel:@"Previous" 
								  frame:frame
									key:@"frpLab" 
								  addsv:YES ];
	frame.origin.x = (self.view.frame.size.width / 2.0) + MARGIN;
					   
	labframe = [self configLabel:@"Current" 
								  frame:frame
									key:@"frcLab" 
						   addsv:YES ];
	
	frame.origin.y += labframe.size.height + MARGIN;
	frame.origin.x = 0.0;
	
	frame = [self configPicker:frame key:@"frPkr"];
	UIPickerView *pkr = [self.wDict objectForKey:@"frPkr"];
	
	[pkr selectRow:[self epToRow:0] inComponent:0 animated:NO];
	[pkr selectRow:[self epToRow:1] inComponent:1 animated:NO];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
		
	labframe = [self configLabel:@"-" 
								  frame:frame
									key:@"frpre0vLab" 
						   addsv:NO ];
	
	frame.origin.x += labframe.size.width + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; 
	
	[self configTextField:frame 
					  key:@"fr0TF" 
				   action:nil
					  num:YES 
					place:nil
					 text:[self.vo.optDict objectForKey:@"frv0"] 
					addsv:NO ];
	
	frame.origin.x += tfWidth + 2*SPACE;
	labframe = [self configLabel:@"months" 
								  frame:frame
									key:@"frpost0vLab" 
						   addsv:NO ];
	
	[self updateValTF:[self epToRow:0] component:0];
	
	frame.origin.x = (self.view.frame.size.width / 2.0) + MARGIN;
	
	labframe = [self configLabel:@"+" 
								  frame:frame
									key:@"frpre1vLab" 
						   addsv:NO ];
	
	frame.origin.x += labframe.size.width + SPACE;
	[self configTextField:frame 
					  key:@"fr1TF" 
				   action:nil
					  num:YES 
					place:nil
					 text:[self.vo.optDict objectForKey:@"frv1"] 
					addsv:NO ];
	
	frame.origin.x += tfWidth + 2*SPACE;
	labframe = [self configLabel:@"months" 
								  frame:frame
									key:@"frpost1vLab" 
						   addsv:NO ];

	[self updateValTF:[self epToRow:1] component:1];
	
}

- (NSString*) voFnDefnStr {
	NSMutableString *fstr = [[NSMutableString alloc] init];
	BOOL closePending = NO;
	
	for (NSNumber *n in self.fnArray) {
		NSInteger i = [n integerValue];
		if (i<0) {
			NSInteger ndx = (i * -1) -1;
			[fstr appendString:[self.fnStrs objectAtIndex:ndx]];
			if (isFnFn(i)) {
				[fstr appendString:@"["];
				closePending=YES;
			}
		} else {
			[fstr appendString:[self.to voGetNameForVID:i]];
			if (closePending) {
				[fstr appendString:@"]"];
				closePending=NO;
			}
		}
		if (! closePending)
			[fstr appendString:@" "];
	}
	return [fstr autorelease];
}


- (void) updateFnTV {
	UITextView *ftv = [self.wDict objectForKey:@"fdefnTV2"];
	ftv.text = [self voFnDefnStr];
}

- (void) btnAdd:(id)sender {
	UIPickerView *pkr = [self.wDict objectForKey:@"fdPkr"];
	NSInteger row = [pkr selectedRowInComponent:0];
	NSNumber *ntok = [self.fnTitles objectAtIndex:row];
	[self.fnArray addObject:ntok];
	[self updateFnTitles];
	[pkr reloadComponent:0];
	[self updateFnTV];
}

- (void) btnDelete:(id)sender {
	UIPickerView *pkr = [self.wDict objectForKey:@"fdPkr"];
	[self.fnArray removeLastObject];
	[self updateFnTitles];
	[pkr reloadComponent:0];
	[self updateFnTV];
}

- (void) drawFuncOptsDefinition {
	[self updateFnTitles];
	
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"Function definition:" 
								  frame:frame
									key:@"fdLab" 
								  addsv:YES ];

	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + labframe.size.height;
	frame.size.width = self.view.frame.size.width - 2*MARGIN; // 300.0f;
	frame.size.height = LFHeight;
	
	[self configTextView:frame key:@"fdefnTV2" text:[self voFnDefnStr]];
	
	frame.origin.x = 0.0;
	frame.origin.y += frame.size.height + MARGIN;
	
	frame = [self configPicker:frame key:@"fdPkr"];
	//UIPickerView *pkr = [self.wDict objectForKey:@"fdPkr"];
	
	//[pkr selectRow:[self epToRow:0] inComponent:0 animated:NO];
	//[pkr selectRow:[self epToRow:1] inComponent:1 animated:NO];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	frame.size.height = labframe.size.height;

	[self configActionBtn:frame key:@"fdaBtn" label:@"Add" action:@selector(btnAdd:)]; 
	frame.origin.x = -1.0f;
	[self configActionBtn:frame key:@"fddBtn" label:@"Delete" action:@selector(btnDelete:)]; 
	
}


- (NSString*) voEpStr:(NSInteger)component {
	NSString *key = [NSString stringWithFormat:@"frep%d",component];
	NSString *vkey = [NSString stringWithFormat:@"frv%d",component];
	NSString *pre = component ? @"current" : @"previous";
	
	NSNumber *n = [self.vo.optDict objectForKey:key];
	NSInteger ep = [n integerValue];
	NSUInteger ep2 = n ? (ep+1)*-1 : 0;
	if (n == nil || ep == FREPDFLT) 
		return [NSString stringWithFormat:@"%@ %@", pre, [self.epTitles objectAtIndex:ep2]];  // FREPDFLT
	if (ep >= 0) 
		return [NSString stringWithFormat:@"%@ %@", pre, ((valueObj*)[self.to.valObjTable objectAtIndex:ep]).valueName];
	
	return [NSString stringWithFormat:@"%@%d %@", 
			(component ? @"+" : @"-"), [[self.vo.optDict objectForKey:vkey] intValue], [self.epTitles objectAtIndex:ep2]];
}

- (NSString*) voRangeStr {
	return [NSString stringWithFormat:@"%@ to %@", [self voEpStr:0], [self voEpStr:1]];
}

- (void) drawFuncOptsOverview {
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	CGRect labframe = [self configLabel:@"Range:" 
								  frame:frame
									key:@"frLab" 
								  addsv:YES ];
	
	//frame = (CGRect) {-1.0f, frame.origin.y, 0.0f,labframe.size.height};
	//[self configActionBtn:frame key:@"frbBtn" label:@"Build" action:@selector(btnBuild:)]; 
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + labframe.size.height;
	frame.size.width = self.view.frame.size.width - 2*MARGIN; // 300.0f;
	frame.size.height = LFHeight;
	
	[self configTextView:frame key:@"frangeTV" text:[self voRangeStr]];
	
	frame.origin.y += frame.size.height + MARGIN;
	labframe = [self configLabel:@"Definition:" 
								  frame:frame
									key:@"fdLab" 
								  addsv:YES];

	frame = (CGRect) {-1.0f, frame.origin.y, 0.0f,labframe.size.height};
	//[self configActionBtn:frame key:@"fdbBtn" label:@"Build" action:@selector(btnBuild:)]; 
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	frame.size.width = 300.0f;
	frame.size.height = LFHeight;
	
	[self configTextView:frame key:@"fdefnTV" text:[self voFnDefnStr]];
	
	frame.origin.y += frame.size.height + MARGIN;
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + labframe.size.height;

	frame = [self yAutoscale:frame];
	
	//frame.origin.y += frame.size.height + MARGIN;
	//frame.origin.x = MARGIN;
	
	self.lasty = frame.origin.y + frame.size.height + MARGIN;
}

- (void) fnSegmentAction:(id)sender
{
	self.fnSegNdx = [sender selectedSegmentIndex];
	NSLog(@"fnSegmentAction: selected segment = %d", self.fnSegNdx);

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self removeSVFields];
	switch (self.fnSegNdx) {
		case 0: 
			[self drawFuncOptsOverview];
			[self drawGeneralVoOpts];			
			break;
		case 1:
			[self drawFuncOptsRange];
			break;
		case 2:
			[self drawFuncOptsDefinition];
			break;
		default:
			NSAssert(0,@"fnSegmentAction bad index!");
			break;
	}
	
	[UIView commitAnimations];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD)
		return 2;
	else 
		return 1;
}

- (void) ftAddFnSet {
	int i;
	for (i=FNFNFIRST;i>=FNFNLAST;i--) {
		[self.fnTitles addObject:[NSNumber numberWithInt:i]];
	}
}

- (void) ftAdd2OpSet {
	int i;
	for (i=FN2OPFIRST;i>=FN2OPLAST;i--) {
		[self.fnTitles addObject:[NSNumber numberWithInt:i]];
	}
}

- (void) ftAddVOs {
	for (valueObj *valo in self.to.valObjTable) {
		[self.fnTitles addObject:[NSNumber numberWithInteger:valo.vid]];
	}
}

- (void) ftAddCloseParen {
	int pcount=0;
	for (NSNumber *ni in self.fnArray) {
		int i = [ni intValue];
		if (i == FNPARENOPEN) {
			pcount++;
		} else if (i == FNPARENCLOSE) {
			pcount--;
		}
	}
	if (pcount > 0) 
		[self.fnTitles addObject:[NSNumber numberWithInt:FNPARENCLOSE]];
}

- (void) ftStartSet {
	[self ftAddFnSet];
	[self.fnTitles addObject:[NSNumber numberWithInt:FNPARENOPEN]];
	[self ftAddVOs];
}

- (void) updateFnTitles {
	[self.fnTitles removeAllObjects];
	if ([self.fnArray count] == 0) {  // state = start
		[self ftStartSet];
	} else {
		int last = [[self.fnArray lastObject] intValue];
		if (last >= 0) { // state = after valObj
			[self ftAdd2OpSet];
			[self ftAddCloseParen];
		} else if (last <= FNFNFIRST && last >= FNFNLAST) {  // state = after fnfn = delta, avg, sum
			[self ftAddVOs];
		} else if (last <= FN2OPFIRST && last >= FN2OPLAST) { // state = after fn2op = +,-,*,/
			[self ftStartSet];
		} else if (last == FNPARENCLOSE) { // state = after close paren
			[self ftAdd2OpSet];
			[self ftAddCloseParen];
		} else if (last == FNPARENOPEN) { // state = after open paren
			[self ftStartSet];
		} else {
			NSAssert(0,@"lost it at updateFnTitles");
		}
	}
}

- (NSString*) fnTokenToStr:(NSInteger)tok {
	if (tok >= 0) {
		for (valueObj *valo in self.to.valObjTable) {
			if (valo.vid == tok)
				return valo.valueName;
		}
		NSAssert(0,@"fnTokenToStr failed to find valObj");
		return @"unknown vid";
	} else {
		tok = (tok * -1) -1;
		return [self.fnStrs objectAtIndex:tok];
	}
}

- (NSString*) fndRowTitle:(NSInteger)row {
	return [self fnTokenToStr:[[self.fnTitles objectAtIndex:row] integerValue]];
}

- (NSInteger) fnrRowCount:(NSInteger)component {
	NSInteger other = (component ? 0 : 1);
	NSString *otherKey = [NSString stringWithFormat:@"frep%d",other];
	id otherObj = [self.vo.optDict objectForKey:otherKey];
	NSInteger otherVal = [otherObj integerValue];
	if (otherVal < -1) {
		return [self.to.valObjTable count]+1;
	} else {
		return [self.to.valObjTable count] + 6;
	}
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) 
		return [self fnrRowCount:component];
	else 
		return [self.fnTitles count];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) {
		return [self fnrRowTitle:row];
	} else {  // FNSEGNDX_FUNCTBLD
		return [self fndRowTitle:row];
	}
	//return [NSString stringWithFormat:@"row %d", row];
}

- (void) updateForPickerRowSelect:(NSInteger)row inComponent:(NSInteger)component {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) {
		[((UIPickerView*) [self.wDict objectForKey:@"frPkr"]) reloadComponent:(component ? 0 : 1)];
	} else {
		//[((UIPickerView*) [self.wDict objectForKey:@"fnPkr"]) reloadComponent:0];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{	
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) {
		NSInteger votc = [self.to.valObjTable count];
		NSString *key = [NSString stringWithFormat:@"frep%d",component];
		NSString *vtfkey = [NSString stringWithFormat:@"fr%dTF",component];
		NSString *pre_vkey = [NSString stringWithFormat:@"frpre%dvLab",component];
		NSString *post_vkey = [NSString stringWithFormat:@"frpost%dvLab",component];
		
		[((UIView*) [self.wDict objectForKey:pre_vkey]) removeFromSuperview];
		[((UIView*) [self.wDict objectForKey:vtfkey]) removeFromSuperview];
		[((UIView*) [self.wDict objectForKey:post_vkey]) removeFromSuperview];
		
		if (row == 0) {
			[self.vo.optDict setObject:[NSNumber numberWithInt:-1.0f] forKey:key];
		} else if (row <= votc) {
			[self.vo.optDict setObject:[NSNumber numberWithInt:row-1] forKey:key];
		} else { 
			[self updateValTF:row component:component];
		}
		NSLog(@"picker sel row %d %@ now= %d", row, key, [[self.vo.optDict objectForKey:key] integerValue] );
	} else {
	}
	
	[self updateForPickerRowSelect:row inComponent:component];
	
}


#pragma mark general options only label

- (void) drawGenOptsOnly 
{
	CGRect labframe = [self configLabel:@"Options:" 
								  frame:(CGRect) {MARGIN,self.lasty,0.0,0.0}
									key:@"gooLab" 
								  addsv:YES ];
	
	self.lasty += labframe.size.height + MARGIN;
}

#pragma mark -
#pragma mark general opts for all 

- (void) drawGeneralVoOpts 
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
		
	CGRect labframe = [self configLabel:@"draw graph:" frame:frame key:@"ggLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	//-- draw graphs button
	
	[self configCheckButton:frame 
						key:@"ggBtn" 
					  state:(![[self.vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) ]; // default = @"1"
	
	//-- privacy level label
	
	frame.origin.x += frame.size.width + MARGIN + SPACE;
	//frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"privacy level:" frame:frame key:@"gpLab" addsv:YES];
	
	//-- privacy level textfield
	
	frame.origin.x += labframe.size.width + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;

	[self configTextField:frame 
					  key:@"gpTF" 
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%d",PRIVDFLT] 
					 text:[self.vo.optDict objectForKey:@"privacy"]
					addsv:YES ];

}

- (void) drawGeneralToOpts 
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"save returns to tracker list:" frame:frame key:@"srLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	//-- draw graphs button
	
	[self configCheckButton:frame 
						key:@"srBtn" 
					  state:(![[self.to.optDict objectForKey:@"savertn"] isEqualToString:@"0"]) ]; // default = @"1"
	
	//-- privacy level label
	
	frame.origin.x = MARGIN;
	//frame.origin.x += frame.size.width + MARGIN + SPACE;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"privacy level:" frame:frame key:@"gpLab" addsv:YES];
	
	//-- privacy level textfield
	
	frame.origin.x += labframe.size.width + SPACE;
	
	CGFloat tfWidth = [[NSString stringWithString:@"9999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"gpTF" 
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%d",PRIVDFLT] 
					 text:[self.to.optDict objectForKey:@"privacy"]
					addsv:YES ];
	
}

#pragma mark main config region methods

- (NSMutableDictionary *) wDict 
{
	if (wDict == nil) {
		wDict = [[NSMutableDictionary alloc] init];
	}
	return wDict;
}


- (void) removeSVFields 
{
	for (NSString *key in self.wDict) {
		//NSLog(@"removing %@",key);
		[(UIView *) [self.wDict valueForKey:key] removeFromSuperview];
	}
	[self.wDict removeAllObjects];
	self.lasty = self.navBar.frame.size.height + MARGIN;	
}



- (void) addVOFields:(NSInteger) vot
{
	switch(vot) {
		case VOT_NUMBER: 
			// uilabel 'autoscale graph'   uibutton checkbutton
			// uilabel 'graph min' uitextfield uilabel 'max' ; enabled/disabled by checkbutton
			[self drawNumOpts];
			break;
		case VOT_TEXT:
			[self drawGenOptsOnly];
			break;
		case VOT_TEXTB:
			[self drawTextbOpts];
			break;
		case VOT_SLIDER:
			// uilabel 'min' uitextfield uilabel 'max' uitextfield uilabel 'default' uitextfield
			[self drawSliderOpts];
			break;
		case VOT_CHOICE:
			// 6 rows uitextfield + button with color ; button cycles color on press ; button blank/off if no text in textfield
			// uilabel 'dynamic width' uibutton checkbutton
			[self drawChoiceOpts];
			break;
		case VOT_BOOLEAN:
			[self drawGenOptsOnly];
			break;
		case VOT_IMAGE:
			[self drawImageOpts];
			break;
		case VOT_FUNC:
			// uitextfield for function, picker or buttons for available valObjs and functions?
			//[self drawFuncOptsOverview];
			if ([self.to.valObjTable count] == 0) {
				[self drawFuncOptsOverview];
				[self drawGeneralVoOpts];				
			}
			break;
		default:
			break;
	}
	
	if (vot != VOT_FUNC)
		[self drawGeneralVoOpts];
	
}

- (void) addTOFields {
	
	[self drawGeneralToOpts];
	
	
}


/*
- (void) updateScrollView:(NSInteger) vot 
{
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//	[UIView setAnimationDuration:kAnimationDuration];
	
	//[self removeSVFields];
	[self addVOFields:vot];
	
//	[UIView commitAnimations];
}
*/


@end
