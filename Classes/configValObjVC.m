//
//  configValObjVC.m
//  rTracker
//
//  Created by Robert Miller on 09/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "configValObjVC.h"

#import "addValObjController.h"

@implementation configValObjVC

@synthesize to, vo, wDict;
@synthesize toolBar, navBar;
@synthesize lasty, saveFrame;

BOOL keyboardIsShown;

#define MARGIN 10.0f
#define SPACE 3.0f
#define TFXTRA 2.0f;

CGFloat LFHeight;  // textfield height based on parent viewcontroller's xib

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
    [super dealloc];

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
	NSLog(@"configValObjVC: btnDone pressed.");
	[self dismissModalViewControllerAnimated:YES];
}

//- (IBAction) backgroundTap:(id)sender {
//	[activeField resignFirstResponder];
//}
//

- (void)viewDidLoad {

	
	NSString *name = self.vo.valueName;
	if ((name == nil) || [name isEqualToString:@""]) 
		name = [NSString stringWithFormat:@"<%@>",[self.to.votArray objectAtIndex:vo.vtype]];
	[[self.navBar.items lastObject] setTitle:[NSString stringWithFormat:@"configure %@",name]];
	name = nil;
	 
	LFHeight = 31.0f; 
	//LFHeight = ((addValObjController *) [self parentViewController]).labelField.frame.size.height;
	
	self.lasty = self.navBar.frame.size.height + MARGIN;
	[self addSVFields:self.vo.vtype];

	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								target:self
								action:@selector(btnDone:)];
	self.toolBar.items = [NSArray arrayWithObjects: doneBtn, nil];
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
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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
		viewFrame.size.height -= self.toolBar.frame.size.height;
		
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
	}else {
		NSAssert(0,@"ckButtonAction cannot identify btn");
	}
	
	if (dfltState == YES) {
		dflt=@"1"; ndflt = @"0";
	} else {
		dflt=@"0"; ndflt = @"1";
	}
	
	if ([(NSString*) [self.vo.optDict objectForKey:okey] isEqualToString:ndflt]) {
		[self.vo.optDict setObject:dflt forKey:okey]; 
		img = (dfltState ? @"checked.png" : @"unchecked.png"); // going to default state
	} else {
		[self.vo.optDict setObject:ndflt forKey:okey];
		img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
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

- (void) tfDone:(UITextField *)tf
{
	NSString *okey, *nkey;
	if ( tf == [self.wDict objectForKey:@"nminTF"] ) {
		okey = @"ngmin";
		nkey = @"nmaxTF";
	} else if ( tf == [self.wDict objectForKey:@"nmaxTF"] ) {
		okey = @"ngmax";
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

- (void) drawNumOpts 
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"Graph Y axis:" frame:frame key:@"ngLab" addsv:YES];
	
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

- (void) drawFuncOpts
{
	CGRect labframe = [self configLabel:@"need function defn -- Options:" 
								  frame:(CGRect) {MARGIN,self.lasty,0.0,0.0}
									key:@"foLab" 
								  addsv:YES ];
	
	self.lasty += labframe.size.height + MARGIN;
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

- (void) drawGeneralOpts 
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
	labframe = [self configLabel:@" privacy level:" frame:frame key:@"gpLab" addsv:YES];
	
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
}



- (void) addSVFields:(NSInteger) vot
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
			[self drawFuncOpts];
			break;
		default:
			break;
	}
	
	[self drawGeneralOpts];
	
}

- (void) updateScrollView:(NSInteger) vot 
{
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//	[UIView setAnimationDuration:kAnimationDuration];
	
	//[self removeSVFields];
	[self addSVFields:vot];
	
//	[UIView commitAnimations];
}



@end
