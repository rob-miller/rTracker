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

BOOL keyboardIsShown;

#define kAnimationDuration 0.3

#define MARGIN 10.0f
#define SPACE 3.0f
#define TFXTRA 2.0f;

CGFloat LFHeight;  // textfield height based on parent viewcontroller's xib
CGRect saveFrame;

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
	 
	LFHeight = 31.0f; //((addValObjController *) [self parentViewController]).labelField.frame.size.height;

	//self.scrollView.contentSize = self.scrollView.frame.size;
	self.lasty = self.navBar.frame.size.height;
	[self addSVFields:self.vo.vtype];

	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								target:self
								action:@selector(btnDone:)];
	self.toolBar.items = [NSArray arrayWithObjects: doneBtn, nil];
	[doneBtn release];
	
	//[(UIControl *)self.view addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventTouchDown];

	keyboardIsShown = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:self.view.window];
	// register for keyboard notifications
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
    if (keyboardIsShown) { // need bit more logic to handle additional scrolling
        return;
    }
	
	//NSLog(@"handling keyboard will show");
	saveFrame = self.view.frame;
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	if (activeField.tag == SCROLLTAG) {
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
	}
	
    keyboardIsShown = YES;
	
}
- (void)keyboardWillHide:(NSNotification *)n
{
	NSLog(@"handling keyboard will hide");
	
	if (activeField.tag == SCROLLTAG) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		[self.view setFrame:saveFrame];

		[UIView commitAnimations];
	}
	
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
	rlab.tag = SCROLLTAG;

	[self.wDict setObject:rlab forKey:key];
	if (addsv)
		[self.view addSubview:rlab];
	
	CGRect retFrame = rlab.frame;
	[rlab release];
	
	return retFrame;
}

- (UIButton *) newConfigButton:(CGRect)frame key:(NSString*)key action:(SEL)action
{
	UIButton *imageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	imageButton.frame = frame;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	imageButton.tag = SCROLLTAG;
	//[imageButton addTarget:self action:@selector(configCheckButtonAction:) forControlEvents:UIControlEventTouchDown];

	[self.wDict setObject:imageButton forKey:key];
	[imageButton addTarget:self action:action forControlEvents:UIControlEventTouchDown];
	
	return imageButton;
}

- (void) configTextField:(CGRect)frame key:(NSString*)key action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text addsv:(BOOL)addsv
{
	frame.origin.y -= TFXTRA;
	UITextField *rtf = [[UITextField alloc] initWithFrame:frame ];
	rtf.clearsOnBeginEditing = NO;
	[rtf setDelegate:self];
	rtf.returnKeyType = UIReturnKeyDone;
	//[rtf addTarget:self action:@selector(configTextFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	rtf.borderStyle = UITextBorderStyleRoundedRect;
	rtf.tag = SCROLLTAG;
	[self.wDict setObject:rtf forKey:key];
	[rtf addTarget:self action:action forControlEvents:UIControlEventEditingDidEndOnExit];
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
	
	CGRect labframe = [self configLabel:@"Graphing:" frame:frame key:@"gLab" addsv:YES];
	
	//frame = (CGRect) {MARGIN,frame.origin.y + lab.frame.size.height+(2*MARGIN),0.0,0.0};
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [self configLabel:@"  Auto Scale:" frame:frame key:@"asLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	UIButton *btn = [self newConfigButton:frame key:@"asBtn" action:@selector(autoscaleButtonAction:)];
	
	if ([[self.vo.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) {
		autoscale=NO;
		[self updateAutoscaleBtn:btn state:NO];
	} else {
		autoscale=YES;
		[self.vo.optDict setObject:@"1" forKey:@"autoscale"];  // confirm default setting
		[self updateAutoscaleBtn:btn state:YES];
	}
	[self.view addSubview:btn];
	[btn release];

	//if (! autoscale) {  still need to calc lasty, make room before general options
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"min:" frame:frame key:@"minLab" addsv:NO];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"minTF" 
				   action:@selector(mtfDone:) 
					  num:YES place:@"<number>" 
					 text:[self.vo.optDict objectForKey:@"gmin"] 
					addsv:NO ];

	frame.origin.x += tfWidth + MARGIN;
	labframe = [self configLabel:@" max:" frame:frame key:@"maxLab" addsv:NO];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;

	[self configTextField:frame 
					  key:@"maxTF" 
				   action:@selector(mtfDone:) 
					  num:YES place:@"<number>" 
					 text:[self.vo.optDict objectForKey:@"gmax"]
					addsv:NO ];

	if (! autoscale) {
		[self addGraphMinMax];
	}
	
	self.lasty = frame.origin.y + frame.size.height;
	
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

- (void) drawSVChoiceOpts 
{
	
	CGRect frame = {MARGIN,self.lasty + MARGIN,0.0,0.0};
	
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
						  action:@selector(ctfDone:) num:NO 
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


- (void) ptfDone:(UITextField *)tf
{
	CGFloat in_val = [tf.text floatValue];
	CGFloat curr_val = [[self.vo.optDict objectForKey:@"privacy"] floatValue];

	if (in_val != curr_val) {
		NSLog(@"vo %@ old priv= %f new priv= %f", vo.valueName, curr_val, in_val);
		[self.vo.optDict setObject:tf.text forKey:@"privacy"];
	}
}

- (void) drawGeneralOpts 
{
	CGRect frame = {MARGIN,self.lasty + MARGIN,0.0,0.0};
	
	//-- title label
	
	CGRect labframe = [self configLabel:@"Options:" frame:frame key:@"goLab" addsv:YES];
	
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [self configLabel:@"draw graph:" frame:frame key:@"ggLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	//-- draw graphs button
	
	UIButton *btn = [self newConfigButton:frame key:@"ggBtn" action:@selector(graphButtonAction:) ];

	
	if ([[self.vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) {
		[self updateGraphBtn:btn state:NO];
	} else {
		[self.vo.optDict setObject:@"1" forKey:@"graph"];  // confirm default setting
		[self updateGraphBtn:btn state:YES];
	}
	//[self.scrollView addSubview:btn];
	[self.view addSubview:btn];
	
	[btn release];
	
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
				   action:@selector(ptfDone:) 
					  num:YES 
					place:@"0" 
					 text:[self.vo.optDict objectForKey:@"privacy"]
					addsv:YES ];

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
