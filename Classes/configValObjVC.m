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
@synthesize lasty;

//BOOL keyboardIsShown;

#define kAnimationDuration 0.3

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

- (IBAction) backgroundTap:(id)sender {
	[activeField resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	NSString *name = self.vo.valueName;
	if ((name == nil) || [name isEqualToString:@""]) 
		name = [NSString stringWithFormat:@"<%@>",[self.to.votArray objectAtIndex:vo.vtype]];
	
	
	[[self.navBar.items lastObject] setTitle:[NSString stringWithFormat:@"configure %@",name]];
	name = nil;
	 
	LFHeight = 31.0f; //((addValObjController *) [self parentViewController]).labelField.frame.size.height;

	self.lasty = self.navBar.frame.size.height;
	[self addSVFields:self.vo.vtype];

	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								target:self
								action:@selector(btnDone:)];
	self.toolBar.items = [NSArray arrayWithObjects: doneBtn, nil];
	[doneBtn release];
	
	//[(UIControl *)self.view addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventTouchDown];
	
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

	/*
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
	*/
	
	self.wDict = nil;
	self.to = nil;
	self.vo = nil;
	
	self.toolBar = nil;
	self.navBar = nil;

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



/*
 
# pragma mark -
# pragma mark keyboard notifications

//#define kKeyboardAnimationDuration 0.3

- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) {
        return;
    }
	
	NSLog(@"handling keyboard will show");
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	
//	 // resize the noteView
//	 CGRect viewFrame = self.scrollView.frame;
//	 viewFrame.size.height -= keyboardSize.height;
//	 
//	 [UIView beginAnimations:nil context:NULL];
//	 [UIView setAnimationBeginsFromCurrentState:YES];
//	 [UIView setAnimationDuration:kKeyboardAnimationDuration];
//	 [self.scrollView setFrame:viewFrame];
//	 [UIView commitAnimations];
	 
	
	if (activeField.tag == SCROLLTAG) {
		CGRect viewFrame = self.view.frame;
		viewFrame.origin.y -= keyboardSize.height; // animatedDistance;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kKeyboardAnimationDuration];
		
		[self.view setFrame:viewFrame];
		[self.scrollView scrollRectToVisible:[activeField frame] animated:YES];
		
		[UIView commitAnimations];
	}
	
    keyboardIsShown = YES;
	
}
- (void)keyboardWillHide:(NSNotification *)n
{
	NSLog(@"handling keyboard will hide");
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	
//	 // resize the scrollview
//	 CGRect viewFrame = self.scrollView.frame;
//	 viewFrame.size.height += keyboardSize.height;
//	 
//	 [UIView beginAnimations:nil context:NULL];
//	 [UIView setAnimationBeginsFromCurrentState:YES];
//	 
//	 [UIView setAnimationDuration:kKeyboardAnimationDuration];
//	 [self.scrollView setFrame:viewFrame];
//	 [UIView commitAnimations];
	 
	
	if (activeField.tag == SCROLLTAG) {
		CGRect viewFrame = self.view.frame;
		viewFrame.origin.y += keyboardSize.height; // animatedDistance;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kKeyboardAnimationDuration];
		
		[self.view setFrame:viewFrame];
		[self.scrollView setContentOffset:(CGPoint) {0.0f,0.0f}];
		
		[UIView commitAnimations];
	}
	
    keyboardIsShown = NO;	
}
*/


# pragma mark -
# pragma mark config region support Methods

#pragma mark newWidget methods

- (UILabel *) newConfigLabel:(NSString *) text frame:(CGRect)frame
{
	frame.size = [text sizeWithFont:[UIFont systemFontOfSize:[UIFont labelFontSize]]];
	
	UILabel *rlab = [[UILabel alloc] initWithFrame:frame];
	rlab.text = text;
	rlab.backgroundColor = [UIColor clearColor];
	rlab.tag = SCROLLTAG;
	return rlab;
}

- (UIButton *) newConfigButton:(CGRect) frame
{
	UIButton *imageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	imageButton.frame = frame;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	imageButton.tag = SCROLLTAG;
	//[imageButton addTarget:self action:@selector(configCheckButtonAction:) forControlEvents:UIControlEventTouchDown];
	
	return imageButton;
}


- (UITextField *) newConfigTextField:(CGRect) frame
{
	UITextField *rtf = [[UITextField alloc] initWithFrame:frame ];
	rtf.clearsOnBeginEditing = NO;
	[rtf setDelegate:self];
	rtf.returnKeyType = UIReturnKeyDone;
	//[rtf addTarget:self action:@selector(configTextFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	rtf.borderStyle = UITextBorderStyleRoundedRect;
	rtf.tag = SCROLLTAG;
	return rtf;
}


#define MARGIN 10.0f
#define SPACE 3.0f

#pragma mark autoscale / graph min/max options

- (void) removeGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[[self.wDict objectForKey:@"minLab"] removeFromSuperview];
	[[self.wDict objectForKey:@"minTF"] removeFromSuperview];
	[[self.wDict objectForKey:@"maxLab"] removeFromSuperview];
	[[self.wDict objectForKey:@"maxTF"] removeFromSuperview];
	
	[UIView commitAnimations];
}

- (void) addGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.view addSubview:[self.wDict objectForKey:@"minLab"]];
	[self.view addSubview:[self.wDict objectForKey:@"minTF"]];
	[self.view addSubview:[self.wDict objectForKey:@"maxLab"]];
	[self.view addSubview:[self.wDict objectForKey:@"maxTF"]];
	
	[UIView commitAnimations];
}

- (void) updateAutoscaleBtn:(UIButton*)btn state:(BOOL)state
{
	if (state) {
		[btn setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];
	} else {
		[btn setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	}
}

- (void)autoscaleButtonAction:(UIButton *)btn
{
	if ([(NSString*) [self.vo.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) {
		[self.vo.optDict setObject:@"1" forKey:@"autoscale"];  //default is 1 if not set
		[self updateAutoscaleBtn:btn state:YES];
		[self removeGraphMinMax];
	} else {
		[self.vo.optDict setObject:@"0" forKey:@"autoscale"];
		[self updateAutoscaleBtn:btn state:NO];
		[self addGraphMinMax];
	}
}


- (void) mtfDone:(UITextField *)tf
{
	if ( tf == [self.wDict objectForKey:@"minTF"] ) {
		NSLog(@"set gmin: %@", tf.text);
		[self.vo.optDict setObject:tf.text forKey:@"gmin"];
		[[self.wDict objectForKey:@"maxTF"] becomeFirstResponder];
	} else if ( tf == [self.wDict objectForKey:@"maxTF"] ) {
		NSLog(@"set gmax: %@", tf.text);
		[self.vo.optDict setObject:tf.text forKey:@"gmax"];
		[tf resignFirstResponder];
	} else {
		NSAssert(0,@"mtfDone cannot identify tf");
	}
	
}

- (void) drawSVGraphMinMax 
{
	BOOL autoscale;
	CGRect frame = {MARGIN,self.lasty + MARGIN,0.0,0.0};
	
	UILabel *lab = [self newConfigLabel:@"Graphing:" frame:frame ];
	[self.wDict setObject:lab forKey:@"gLab"];
	//[self.scrollView addSubview:lab];
	[self.view addSubview:lab];
	
	//frame = (CGRect) {MARGIN,frame.origin.y + lab.frame.size.height+(2*MARGIN),0.0,0.0};
	frame.origin.y += lab.frame.size.height + MARGIN;
	[lab release];
	
	lab = [self newConfigLabel:@"  Auto Scale:" frame:frame ];
	[self.wDict setObject:lab forKey:@"asLab"];
	//[self.scrollView addSubview:lab];
	[self.view addSubview:lab];
	
	frame = (CGRect) {lab.frame.size.width+MARGIN+SPACE, frame.origin.y,lab.frame.size.height,lab.frame.size.height};
	[lab release];
	
	UIButton *btn = [self newConfigButton:frame];
	[btn addTarget:self action:@selector(autoscaleButtonAction:) forControlEvents:UIControlEventTouchDown];
	
	[self.wDict setObject:btn forKey:@"asBtn"];
	if ([[self.vo.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) {
		autoscale=NO;
		[self updateAutoscaleBtn:btn state:NO];
	} else {
		autoscale=YES;
		[self.vo.optDict setObject:@"1" forKey:@"autoscale"];  // confirm default setting
		[self updateAutoscaleBtn:btn state:YES];
	}
	//[self.scrollView addSubview:btn];
	[self.view addSubview:btn];
	[btn release];

	//if (! autoscale) {  still need to calc lasty, make room before general options
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	lab = [self newConfigLabel:@" min:" frame:frame];
	[self.wDict setObject:lab forKey:@"minLab"];
	//[self.scrollView addSubview:lab];
	
	frame.origin.x = lab.frame.size.width + MARGIN + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	[lab release];
	
	UITextField *tf = [self newConfigTextField:frame];
	[self.wDict setObject:tf forKey:@"minTF"];
	[tf addTarget:self action:@selector(mtfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
	tf.placeholder = @"<number>";
	tf.textAlignment = UITextAlignmentRight;
	
	NSString *s;
	if (s = [self.vo.optDict objectForKey:@"gmin"]) {
		NSLog(@"gmin found val: %@",s);
		tf.text = s;
	}
	//[self.scrollView addSubview:tf];
	[tf release];
	
	frame.origin.x += tfWidth + MARGIN;
	lab = [self newConfigLabel:@" max:" frame:frame];
	[self.wDict setObject:lab forKey:@"maxLab"];
	//[self.scrollView addSubview:lab];
	
	frame.origin.x += lab.frame.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	[lab release];
	
	tf = [self newConfigTextField:frame];
	[self.wDict setObject:tf forKey:@"maxTF"];
	[tf addTarget:self action:@selector(mtfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
	tf.placeholder = @"<number>";
	tf.textAlignment = UITextAlignmentRight;
	
	if (s = [self.vo.optDict objectForKey:@"gmax"]) {
		NSLog(@"gmax found val: %@",s);
		tf.text = s;
	}
	//[self.scrollView addSubview:tf];
	[tf release];
	
	if (! autoscale) {
		[self addGraphMinMax];
	}
	
	self.lasty = frame.origin.y + frame.size.height;
	
}

#pragma mark choice valObj options 

/*
#define SVINC 100.0

//CGFloat origFrameY;

- (void)upDownButtonAction:(UIButton *)btn
{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	CGRect frame = self.scrollView.frame;
	if (self.scrollView.contentSize.height == self.scrollView.frame.size.height) {
		frame.size.height -= SVINC; 
		frame.origin.y += SVINC;
		self.scrollView.frame = frame;
		[btn setImage:[UIImage imageNamed:@"up.png"] forState: UIControlStateNormal];
	} else {
		frame.size.height += SVINC;
		frame.origin.y -= SVINC;
		self.scrollView.frame = frame;
		[btn setImage:[UIImage imageNamed:@"down.png"] forState: UIControlStateNormal];
	}
	
	[UIView commitAnimations];	
}
*/

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

- (void) drawSVChoiceOpts 
{
	//CGSize siz = self.scrollView.contentSize;
	//siz.height += SVINC;
	//self.scrollView.contentSize = siz;
	
	//origFrameY = self.scrollView.frame.origin.y;
	
	CGRect frame = {MARGIN,self.lasty + MARGIN,0.0,0.0};
	
	UILabel *lab = [self newConfigLabel:@"Choices:" frame:frame ];
	[self.wDict setObject:lab forKey:@"coLab"];
	[self.view addSubview:lab];
	
	/*
	frame.origin.x = 300;
	frame.size.height = 16.0;
	frame.size.width = 10.0;
	
	UIButton *btn = [self newConfigButton:frame];
	[btn addTarget:self action:@selector(upDownButtonAction:) forControlEvents:UIControlEventTouchDown];
	
	[btn setImage:[UIImage imageNamed:@"up.png"] forState: UIControlStateNormal];
	[self.wDict setObject:btn forKey:@"udBtn"];
	[self.scrollView addSubview:btn];
	[btn release];
	*/
	
	frame.origin.x = MARGIN;
	frame.origin.y += lab.frame.size.height + MARGIN;
	[lab release];
	
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	int i,j=1;
	UITextField *tf;
	for (i=0; i<CHOICES; i++) {
		
		tf = [self newConfigTextField:frame];
		[self.wDict setObject:tf forKey:[NSString stringWithFormat:@"%dtf",i]];
		[tf addTarget:self action:@selector(ctfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		tf.text = [self.vo.optDict objectForKey:[NSString stringWithFormat:@"c%d",i]];
		tf.placeholder = [NSString stringWithFormat:@"choice %d",i+1];
		[self.view addSubview:tf];
		
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
		
		frame.origin.x = MARGIN + (j * (tfWidth + tf.frame.size.height + 2*MARGIN));
		j = ( j ? 0 : 1 ); // j toggles 0-1
		frame.origin.y += j * ((2*MARGIN) + tf.frame.size.height);
		frame.size.width = tfWidth;
		//frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
		
		[tf release];
	}

	self.lasty = frame.origin.y - (2*MARGIN);  // allready added  + frame.size.height; in loop
	
}	

#pragma mark -
#pragma mark general opts for all 

- (void) updateGraphBtn:(UIButton*)btn state:(BOOL)state
{
	if (state) {
		[btn setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];
	} else {
		[btn setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	}
}

- (void) graphButtonAction:(UIButton*)btn 
{
	if ([(NSString*) [self.vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) {
		[self.vo.optDict setObject:@"1" forKey:@"graph"];  //default is 1 if not set
		[self updateGraphBtn:btn state:YES];
	} else {
		[self.vo.optDict setObject:@"0" forKey:@"graph"];
		[self updateGraphBtn:btn state:NO];
	}
}

- (void) drawGeneralOpts 
{
	CGRect frame = {MARGIN,self.lasty + MARGIN,0.0,0.0};
	
	UILabel *lab = [self newConfigLabel:@"Options:" frame:frame ];
	[self.wDict setObject:lab forKey:@"goLab"];
	[self.view addSubview:lab];
	
	frame.origin.y += lab.frame.size.height + MARGIN;
	[lab release];
	
	lab = [self newConfigLabel:@"draw graph:" frame:frame ];
	[self.wDict setObject:lab forKey:@"ggLab"];
	[self.view addSubview:lab];
	
	frame = (CGRect) {lab.frame.size.width+MARGIN+SPACE, frame.origin.y,lab.frame.size.height,lab.frame.size.height};
	[lab release];
	
	UIButton *btn = [self newConfigButton:frame];
	[btn addTarget:self action:@selector(graphButtonAction:) forControlEvents:UIControlEventTouchDown];
	
	[self.wDict setObject:btn forKey:@"asBtn"];
	if ([[self.vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) {
		[self updateGraphBtn:btn state:NO];
	} else {
		[self.vo.optDict setObject:@"1" forKey:@"graph"];  // confirm default setting
		[self updateGraphBtn:btn state:YES];
	}
	//[self.scrollView addSubview:btn];
	[self.view addSubview:btn];
	
	self.lasty = btn.frame.origin.y + btn.frame.size.height;
	
	[btn release];
	
	
}

#pragma mark main scrollView methods

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
	//self.scrollView.contentSize = self.scrollView.frame.size;
}



- (void) addSVFields:(NSInteger) vot
{
	switch(vot) {
		case VOT_NUMBER: 
			// uilabel 'autoscale graph'   uibutton checkbutton
			// uilabel 'graph min' uitextfield uilabel 'max' ; enabled/disabled by checkbutton
			[self drawSVGraphMinMax];
			break;
		case VOT_TEXT:
			break;
		case VOT_TEXTB:
			break;
		case VOT_SLIDER:
			// uilabel 'min' uitextfield uilabel 'max' uitextfield uilabel 'default' uitextfield
			break;
		case VOT_CHOICE:
			// 6 rows uitextfield + button with color ; button cycles color on press ; button blank/off if no text in textfield
			// uilabel 'dynamic width' uibutton checkbutton
			[self drawSVChoiceOpts];
			break;
		case VOT_BOOLEAN:
			break;
		case VOT_IMAGE:
			break;
		case VOT_FUNC:
			// uitextfield for function, picker or buttons for available valObjs and functions?
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
