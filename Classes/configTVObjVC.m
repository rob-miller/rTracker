//
//  configTVObjVC.m
//  rTracker
//
//  Created by Robert Miller on 09/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "configTVObjVC.h"

#import "addValObjController.h"
#import "rTracker-constants.h"
#import "voFunction.h"

//  private methods including properties can go here!


@implementation configTVObjVC

@synthesize to, vo, wDict;
@synthesize toolBar, navBar, lasty, saveFrame, LFHeight, vdlConfigVO;

BOOL keyboardIsShown;

//CGFloat LFHeight;  // textfield height based on parent viewcontroller's xib

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
	if (self.vdlConfigVO && self.vo.vtype == VOT_FUNC) {
		[((voFunction*)self.vo.vos) funcDone];
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
		self.vdlConfigVO = NO;
	} else {
		name = self.vo.valueName;
		self.vdlConfigVO = YES;
	}
	
	if ((name == nil) || [name isEqualToString:@""]) 
		name = [NSString stringWithFormat:@"<%@>",[self.to.votArray objectAtIndex:vo.vtype]];
	[[self.navBar.items lastObject] setTitle:[NSString stringWithFormat:@"configure %@",name]];
	name = nil;
	 
	self.LFHeight = 31.0f; 
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
	if (self.vdlConfigVO && self.vo.vtype == VOT_FUNC) {
		[(voFunction*)self.vo.vos funcVDL:self donebutton:doneBtn];
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

- (void) configActionBtn:(CGRect)frame key:(NSString*)key label:(NSString*)label target:(id)target action:(SEL)action {

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
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
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


- (void) configTextField:(CGRect)frame key:(NSString*)key target:(id)target action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text addsv:(BOOL)addsv
{
	frame.origin.y -= TFXTRA;
	UITextField *rtf = [[UITextField alloc] initWithFrame:frame ];
	rtf.clearsOnBeginEditing = NO;
	[rtf setDelegate:self];
	rtf.returnKeyType = UIReturnKeyDone;
	rtf.borderStyle = UITextBorderStyleRoundedRect;
	[self.wDict setObject:rtf forKey:key];
	
	if (action == nil) 
		action = @selector(tfDone:);
	if (target == nil) 
		target = self;
	
	[rtf addTarget:target action:action forControlEvents:UIControlEventEditingDidEndOnExit];
	
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


- (CGRect) configPicker:(CGRect)frame key:(NSString*)key caller:(id)caller {
	UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	frame.size = [myPickerView sizeThatFits:CGSizeZero];;
	myPickerView.frame = frame;
	
	myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	myPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	myPickerView.delegate = caller;
	myPickerView.dataSource = caller;
	
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
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"nminTF" 
				   target:nil
				   action:nil
					  num:YES 
					place:@"<number>" 
					 text:[self.vo.optDict objectForKey:@"ngmin"] 
					addsv:NO ];
	
	frame.origin.x += tfWidth + MARGIN;
	labframe = [self configLabel:@" max:" frame:frame key:@"nmaxLab" addsv:NO];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"nmaxTF"
				   target:nil
				   action:nil
					  num:YES 
					place:@"<number>" 
					 text:[self.vo.optDict objectForKey:@"ngmax"]
					addsv:NO ];
	
	if ([[self.vo.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) 
		[self addGraphMinMax];
	
	return frame;
}



#pragma mark choice valObj options 

#pragma mark slider options

#pragma mark textbox options


#pragma mark image options

#pragma mark function options

#pragma mark general options only label
/*
- (void) drawGenOptsOnly 
{
}
*/
#pragma mark -
#pragma mark general opts for all 

//- (void) drawGeneralVoOpts 
//{
//}

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
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"gpTF" 
				   target:nil
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
			//[self drawNumOpts];
			//[self drawGeneralVoOpts];
			[self.vo.vos voDrawOptions:self];
			break;
		case VOT_TEXT:
			//[self drawGenOptsOnly];
			//[self drawGeneralVoOpts];
			[self.vo.vos voDrawOptions:self];
			break;
		case VOT_TEXTB:
			//[self drawTextbOpts];
			//[self drawGeneralVoOpts];
			[self.vo.vos voDrawOptions:self];
			break;
		case VOT_SLIDER:
			// uilabel 'min' uitextfield uilabel 'max' uitextfield uilabel 'default' uitextfield
			//[self drawSliderOpts];
			//[self drawGeneralVoOpts];
			[self.vo.vos voDrawOptions:self];
			break;
		case VOT_CHOICE:
			// 6 rows uitextfield + button with color ; button cycles color on press ; button blank/off if no text in textfield
			// uilabel 'dynamic width' uibutton checkbutton
			//[self drawChoiceOpts];
			//[self drawGeneralVoOpts];
			[self.vo.vos voDrawOptions:self];
			break;
		case VOT_BOOLEAN:
			[self.vo.vos voDrawOptions:self];
			//[self drawGenOptsOnly];
			//[self drawGeneralVoOpts];
			break;
		case VOT_IMAGE:
			//[self drawImageOpts];
			[self.vo.vos voDrawOptions:self];
			break;
		case VOT_FUNC:
			// uitextfield for function, picker or buttons for available valObjs and functions?
			//[self drawFuncOptsOverview];
			//if ([self.to.valObjTable count] == 0) {
				[self.vo.vos voDrawOptions:self];
			//}
			break;
		default:
			break;
	}
	
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
