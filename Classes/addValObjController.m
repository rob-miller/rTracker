//
//  addValObjController.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addValObjController.h"

@implementation addValObjController

@synthesize tempValObj;
@synthesize parentTrackerObj;
@synthesize graphTypes;

@synthesize labelField;
@synthesize votPicker;
@synthesize scrollView;
@synthesize svDict;

CGSize sizeVOTLabel;
CGSize sizeGTLabel;

NSInteger colorCount;  // count of entries to show in center color picker spinner.

BOOL keyboardIsShown;

#define FONTSIZE 20.0f
//#define FONTSIZE [UIFont labelFontSize]


#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	NSLog(@"avoc dealloc");
	
	self.votPicker = nil;
	[votPicker release];
	self.labelField = nil;
	[labelField release];
	self.scrollView = nil;
	[scrollView release];
	self.svDict = nil;
	[svDict release];
	
	self.tempValObj = nil;
	[tempValObj release];
	self.graphTypes = nil;
	[graphTypes release];
	self.parentTrackerObj = nil;
	[parentTrackerObj release];
	
    [super dealloc];
}


# pragma mark -
# pragma mark utility routines

+(CGSize) maxLabelFromArray:(const NSArray *)arr 
{
	CGSize rsize = {0.0f, 0.0f};
	//NSEnumerator *e = [arr objectEnumerator];
	//NSString *s;
	//while ( s = (NSString *) [e nextObject]) {
	for (NSString *s in arr) {
		CGSize tsize = [s sizeWithFont:[UIFont systemFontOfSize:FONTSIZE]];
		if (tsize.width > rsize.width) {
			rsize = tsize;
		}
	}
	
	return rsize;
}

# pragma mark -
# pragma mark view support

//#define SCROLLVIEW_HEIGHT 100
//#define SCROLLVIEW_WIDTH  320

//#define SCROLLVIEW_CONTENT_HEIGHT 720
//#define SCROLLVIEW_CONTENT_WIDTH  320



- (void)viewDidLoad {
	
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								  target:self
								  action:@selector(btnCancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	[cancelBtn release];
	
	UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								target:self
								action:@selector(btnSave)];
	self.navigationItem.rightBarButtonItem = saveBtn;
	[saveBtn release];

	[self.navigationController setToolbarHidden:YES animated:YES];
	
	/*
	UIBarButtonItem *configBtn = [[UIBarButtonItem alloc]
								initWithTitle:@"Configure"
								style:UIBarButtonItemStyleBordered
								target:self
								action:@selector(btnConfigure)];

	self.toolbarItems = [NSArray arrayWithObjects: configBtn, nil];
	[configBtn release];
	*/
	
	sizeVOTLabel = [addValObjController maxLabelFromArray:parentTrackerObj.votArray];
	NSArray *allGraphs = [valueObj graphsForVOTCopy:-1];
	sizeGTLabel = [addValObjController maxLabelFromArray:allGraphs];
	
	colorCount = [self.parentTrackerObj.colorSet count];

	//scrollView = [[UIScrollView alloc] init];      
	//scrollView.contentSize = CGSizeMake(320.0,720.0); //scrollView.frame.size;
	self.scrollView.contentSize = self.scrollView.frame.size;
    //scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
		
	if (self.tempValObj == nil) {
		tempValObj = [[valueObj alloc] init];
		self.graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:VOT_NUMBER];
		[self updateScrollView:(NSInteger)VOT_NUMBER];
		[self.votPicker selectRow:self.parentTrackerObj.nextColor inComponent:1 animated:NO];
	} else {
		self.labelField.text = self.tempValObj.valueName;
		[self.votPicker selectRow:self.tempValObj.vcolor inComponent:1 animated:NO]; // first as no picker update effects
		[self.votPicker selectRow:self.tempValObj.vtype inComponent:0 animated:NO];
		[self updateForPickerRowSelect:self.tempValObj.vtype inComponent:0];
		[self.votPicker selectRow:self.tempValObj.vGraphType inComponent:2 animated:NO];
		[self updateForPickerRowSelect:self.tempValObj.vGraphType inComponent:2];
		[self updateScrollView:self.tempValObj.vtype];
		 
		NSString *g = [allGraphs objectAtIndex:self.tempValObj.vGraphType];
		self.graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:tempValObj.vtype];

		NSInteger row=0;
		//while ( s = (NSString *) [e nextObject]) {
		for (NSString *s in self.graphTypes) {
			if ([g isEqual:s])
				break;
			row++;
		}

		[self.votPicker reloadComponent:2];
		[self.votPicker selectRow:row inComponent:2 animated:NO];
	}

	[allGraphs release];
	
	self.title = @"value";
	
	self.labelField.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	self.labelField.clearsOnBeginEditing = NO;
	[self.labelField setDelegate:self];
	self.labelField.returnKeyType = UIReturnKeyDone;
	[self.labelField addTarget:self
				  action:@selector(labelFieldDone:)
		forControlEvents:UIControlEventEditingDidEndOnExit];
	
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


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.

	parentTrackerObj.colorSet = nil;
	parentTrackerObj.votArray = nil;
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	NSLog(@"avoc didUnload");

    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
	
	self.votPicker = nil;
	self.labelField = nil;
	self.tempValObj = nil;
	self.graphTypes = nil;
	self.parentTrackerObj = nil;

	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	//[self setToolbarItems:nil
	//			 animated:NO];
	self.title = nil;
	
	[super viewDidUnload];
}


#pragma mark -
#pragma mark button press action methods

- (void) leave
{
	[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnCancel {
	NSLog(@"addVObjC: btnCancel was pressed!");
	[self leave];
}

- (IBAction)btnSave {
	NSLog(@"addVObjC: btnSave was pressed!");
	self.tempValObj.valueName = self.labelField.text;  // in case neglected to 'done' keyboard
	
	NSUInteger row = [self.votPicker selectedRowInComponent:0];
	self.tempValObj.vtype = row;  // works because vtype defs are same order as rt-types.plist entries
	row = [self.votPicker selectedRowInComponent:1];
	self.tempValObj.vcolor = row; // works because vColor defs are same order as trackerObj.colorSet creator 
	row = [self.votPicker selectedRowInComponent:2];
	self.tempValObj.vGraphType = [valueObj mapGraphType:[self.graphTypes objectAtIndex:row]];
	
	if (self.tempValObj.vid == 0) {
		self.tempValObj.vid = [self.parentTrackerObj getUnique];
	}
	
	NSString *selected = [self.parentTrackerObj.votArray objectAtIndex:row];
	NSLog(@"label: %@ id: %d row: %d = %@",self.tempValObj.valueName,self.tempValObj.vid, row,selected);
	
	[self.parentTrackerObj addValObj:tempValObj];
	
	[self leave];
	//[self.navigationController popViewControllerAnimated:YES];
	//[parent.tableView reloadData];
}

- (void) myButtonAction:(id)sender
{
	NSLog(@"pressed!");
	[sender removeFromSuperview];
}

/*
- (IBAction)btnConfigure {
	NSLog(@"addVObjC: config was pressed!");
	CGRect frame = {25.0, 125.0, 50.0, 50.0 };
	UIView *myView = [[UIView alloc] initWithFrame:frame];

	UIButton *myButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	myButton.frame = CGRectZero;
	myButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	myButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[myButton addTarget:self action:@selector(myButtonAction:) forControlEvents:UIControlEventTouchDown];
	[myButton setTitle:@"button" forState:UIControlStateNormal];
	//[myView addSubview:myButton];
	
	//[self.scrollView addSubview:myButton];
	
}
*/

# pragma mark -
# pragma mark textField support Methods

- (IBAction) labelFieldDone:(id)sender {
	[sender resignFirstResponder];
	self.tempValObj.valueName = self.labelField.text;
}

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

#define kKeyboardAnimationDuration 0.3

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
	
	/*
    // resize the noteView
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
	*/
	
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
	
	/*
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];

    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
	*/

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


# pragma mark -
# pragma mark scrollView (config region) support Methods

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
	[UIView setAnimationDuration:kKeyboardAnimationDuration];
    	
	[[self.svDict objectForKey:@"minLab"] removeFromSuperview];
	[[self.svDict objectForKey:@"minTF"] removeFromSuperview];
	[[self.svDict objectForKey:@"maxLab"] removeFromSuperview];
	[[self.svDict objectForKey:@"maxTF"] removeFromSuperview];
	
	[UIView commitAnimations];
}

- (void) addGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kKeyboardAnimationDuration];
    	
	[self.scrollView addSubview:[self.svDict objectForKey:@"minLab"]];
	[self.scrollView addSubview:[self.svDict objectForKey:@"minTF"]];
	[self.scrollView addSubview:[self.svDict objectForKey:@"maxLab"]];
	[self.scrollView addSubview:[self.svDict objectForKey:@"maxTF"]];

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
	if ([(NSString*) [self.tempValObj.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) {
		[self.tempValObj.optDict setObject:@"1" forKey:@"autoscale"];  //default is 1 if not set
		[self updateAutoscaleBtn:btn state:YES];
		[self removeGraphMinMax];
	} else {
		[self.tempValObj.optDict setObject:@"0" forKey:@"autoscale"];
		[self updateAutoscaleBtn:btn state:NO];
		[self addGraphMinMax];
	}
}


- (void) mtfDone:(UITextField *)tf
{
	if ( tf == [self.svDict objectForKey:@"minTF"] ) {
		NSLog(@"set gmin: %@", tf.text);
		[self.tempValObj.optDict setObject:tf.text forKey:@"gmin"];
		[[self.svDict objectForKey:@"maxTF"] becomeFirstResponder];
	} else if ( tf == [self.svDict objectForKey:@"maxTF"] ) {
		NSLog(@"set gmax: %@", tf.text);
		[self.tempValObj.optDict setObject:tf.text forKey:@"gmax"];
		[tf resignFirstResponder];
	} else {
		NSAssert(0,@"mtfDone cannot identify tf");
	}
	
}

- (void) drawSVGraphMinMax 
{
	BOOL autoscale;
	CGRect frame = {MARGIN,MARGIN,0.0,0.0};
	
	UILabel *lab = [self newConfigLabel:@"Graph Options:" frame:frame ];
	[self.svDict setObject:lab forKey:@"goLab"];
	[self.scrollView addSubview:lab];
	
	frame = (CGRect) {MARGIN,lab.frame.size.height+(2*MARGIN),0.0,0.0};
	[lab release];
	
	lab = [self newConfigLabel:@"  Auto Scale:" frame:frame ];
	[self.svDict setObject:lab forKey:@"asLab"];
	[self.scrollView addSubview:lab];
	
	frame = (CGRect) {lab.frame.size.width+MARGIN+SPACE,lab.frame.origin.y,lab.frame.size.height,lab.frame.size.height};
	[lab release];
	
	UIButton *btn = [self newConfigButton:frame];
	[btn addTarget:self action:@selector(autoscaleButtonAction:) forControlEvents:UIControlEventTouchDown];
	
	[self.svDict setObject:btn forKey:@"asBtn"];
	if ([[self.tempValObj.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) {
		autoscale=NO;
		[self updateAutoscaleBtn:btn state:NO];
	} else {
		autoscale=YES;
		[self.tempValObj.optDict setObject:@"1" forKey:@"autoscale"];  // confirm default setting
		[self updateAutoscaleBtn:btn state:YES];
	}
	[self.scrollView addSubview:btn];
	[btn release];
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	lab = [self newConfigLabel:@" min:" frame:frame];
	[self.svDict setObject:lab forKey:@"minLab"];
	//[self.scrollView addSubview:lab];
	
	frame.origin.x = lab.frame.size.width + MARGIN + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
	[lab release];
	
	UITextField *tf = [self newConfigTextField:frame];
	[self.svDict setObject:tf forKey:@"minTF"];
	[tf addTarget:self action:@selector(mtfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
	tf.placeholder = @"<number>";
	tf.textAlignment = UITextAlignmentRight;
	
	NSString *s;
	if (s = [self.tempValObj.optDict objectForKey:@"gmin"]) {
		NSLog(@"gmin found val: %@",s);
		tf.text = s;
	}
	//[self.scrollView addSubview:tf];
	[tf release];
	
	frame.origin.x += tfWidth + MARGIN;
	lab = [self newConfigLabel:@" max:" frame:frame];
	[self.svDict setObject:lab forKey:@"maxLab"];
	//[self.scrollView addSubview:lab];
	
	frame.origin.x += lab.frame.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
	[lab release];
	
	tf = [self newConfigTextField:frame];
	[self.svDict setObject:tf forKey:@"maxTF"];
	[tf addTarget:self action:@selector(mtfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
	tf.placeholder = @"<number>";
	tf.textAlignment = UITextAlignmentRight;
	
	if (s = [self.tempValObj.optDict objectForKey:@"gmax"]) {
		NSLog(@"gmax found val: %@",s);
		tf.text = s;
	}
	//[self.scrollView addSubview:tf];
	[tf release];
	
	if (! autoscale) 
		[self addGraphMinMax];
}

#pragma mark choice valObj options 

#define SVINC 100.0

//CGFloat origFrameY;

- (void)upDownButtonAction:(UIButton *)btn
{

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kKeyboardAnimationDuration];
		
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

- (void) ctfDone:(UITextField *)tf
{
	int i=0;
	NSString *key;
	for (key in self.svDict) {
		if ([self.svDict objectForKey:key] == tf) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dtf",&i);
			break;
		}
	}

	NSLog(@"set choice %d: %@",i, tf.text);
	[self.tempValObj.optDict setObject:tf.text forKey:[NSString stringWithFormat:@"c%d",i]];
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	UIButton *b = [self.svDict objectForKey:[NSString stringWithFormat:@"%dbtn",i]];
	if ([tf.text isEqualToString:@""]) {
		b.backgroundColor = [UIColor clearColor];
		[self.tempValObj.optDict removeObjectForKey:cc];
		// TODO: should offer to delete any stored data
	} else {
		NSNumber *ncol = [self.tempValObj.optDict objectForKey:cc];
		
		if (ncol == nil) {
			NSInteger col = [self.parentTrackerObj nextColor];
			[self.tempValObj.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
			b.backgroundColor = [self.parentTrackerObj.colorSet objectAtIndex:col];
		} 
	}
	if (++i<CHOICES) {
		[[self.svDict objectForKey:[NSString stringWithFormat:@"%dtf",i]] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
}

- (void) choiceColorButtonAction:(UIButton *)btn
{
	int i=0;

	for (NSString *key in self.svDict) {
		if ([self.svDict objectForKey:key] == btn) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dbtn",&i);
			break;
		}
	}

	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	NSNumber *ncol = [self.tempValObj.optDict objectForKey:cc];
	if (ncol == nil) {
		// do nothing as no choice label set so button not active
	} else {
		NSInteger col = [ncol integerValue];
		if (++col >= [self.parentTrackerObj.colorSet count])
			col=0;
		[self.tempValObj.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
		btn.backgroundColor = [self.parentTrackerObj.colorSet objectAtIndex:col];
	}
	
}

- (void) drawSVChoiceOpts 
{
	CGSize siz = self.scrollView.contentSize;
	siz.height += SVINC;
	self.scrollView.contentSize = siz;

	//origFrameY = self.scrollView.frame.origin.y;
	
	CGRect frame = {MARGIN,MARGIN,0.0,0.0};
	
	UILabel *lab = [self newConfigLabel:@"Choices and Options:" frame:frame ];
	[self.svDict setObject:lab forKey:@"coLab"];
	[self.scrollView addSubview:lab];
	
	frame.origin.x = 300;
	frame.size.height = 16.0;
	frame.size.width = 10.0;
	
	UIButton *btn = [self newConfigButton:frame];
	[btn addTarget:self action:@selector(upDownButtonAction:) forControlEvents:UIControlEventTouchDown];

	[btn setImage:[UIImage imageNamed:@"up.png"] forState: UIControlStateNormal];
	[self.svDict setObject:btn forKey:@"udBtn"];
	[self.scrollView addSubview:btn];
	[btn release];

	frame.origin.x = MARGIN;
	frame.origin.y = (2*MARGIN) + lab.frame.size.height;
	[lab release];

	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
	
	int i,j=1;
	UITextField *tf;
	for (i=0; i<CHOICES; i++) {
		
		tf = [self newConfigTextField:frame];
		[self.svDict setObject:tf forKey:[NSString stringWithFormat:@"%dtf",i]];
		[tf addTarget:self action:@selector(ctfDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		tf.text = [self.tempValObj.optDict objectForKey:[NSString stringWithFormat:@"c%d",i]];
		tf.placeholder = [NSString stringWithFormat:@"choice %d",i+1];
		[self.scrollView addSubview:tf];
		
		frame.origin.x += MARGIN + tfWidth;
		
		//frame.size.height = 1.2* frame.size.height;
		frame.size.width = frame.size.height;
		btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = frame;
		[[btn layer] setCornerRadius:8.0f];
		[[btn layer] setMasksToBounds:YES];
		[[btn layer] setBorderWidth:1.0f];
		NSNumber *cc = [self.tempValObj.optDict objectForKey:[NSString stringWithFormat:@"cc%d",i]];
		if (cc == nil) {
			btn.backgroundColor = [UIColor clearColor];
		} else {
			btn.backgroundColor = [self.parentTrackerObj.colorSet objectAtIndex:[cc integerValue]];
		}
		
		[btn addTarget:self action:@selector(choiceColorButtonAction:) forControlEvents:UIControlEventTouchDown];
		[self.svDict setObject:btn forKey:[NSString stringWithFormat:@"%dbtn",i]];
		[self.scrollView addSubview:btn];
		
		frame.origin.x = MARGIN + (j * (tfWidth + tf.frame.size.height + 2*MARGIN));
		j = ( j ? 0 : 1 ); // j toggles 0-1
		frame.origin.y += j * ((2*MARGIN) + tf.frame.size.height);
		frame.size.width = tfWidth;
		//frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;

		[tf release];
		
		
	}
}	

#pragma mark main scrollView methods

- (NSMutableDictionary *) svDict 
{
	if (svDict == nil) {
		svDict = [[NSMutableDictionary alloc] init];
	}
	return svDict;
}


- (void) removeSVFields 
{
	for (NSString *key in self.svDict) {
		//NSLog(@"removing %@",key);
		[(UIView *) [self.svDict valueForKey:key] removeFromSuperview];
	}
	[self.svDict removeAllObjects];
	self.scrollView.contentSize = self.scrollView.frame.size;
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
}

- (void) updateScrollView:(NSInteger) vot 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kKeyboardAnimationDuration];

	[self removeSVFields];
	[self addSVFields:vot];
	
	[UIView commitAnimations];
	
	lastVOT = vot;
}

#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	switch (component) {
		case 0:
			return [self.parentTrackerObj.votArray count];
			break;
		case 1:
			//return [self.parentTrackerObj.colorSet count];
			return colorCount;
			break;
		case 2:
			return [self.graphTypes count];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return 0;
			break;
	}
}

#pragma mark Picker Delegate Methods

#define TEXTPICKER 0
#if TEXTPICKER

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return [self.parentTrackerObj.votArray objectAtIndex:row];
			break;
		case 1:
			//return [self.paretntTrackerObj.colorSet objectAtIndex:row];
			return @"color";
			break;
		case 2:
			return [self.graphTypes objectAtIndex:row];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return @"boo.";
			break;
	}
}

#else 

#define COLORSIDE FONTSIZE

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label;
	CGRect frame;
	
	
	switch (component) {
		case 0:
			frame.size = sizeVOTLabel;
			frame.size.width += FONTSIZE;
			//CGFloat lfs = [UIFont labelFontSize]; // 17
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
			label.backgroundColor = [UIColor clearColor] ; //]greenColor];
			label.text = [self.parentTrackerObj.votArray objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:FONTSIZE];
			break;
		case 1:
			frame.size.height = 1.2*COLORSIDE;
			frame.size.width = 2.0*COLORSIDE;
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
			//label = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			//[label retain];
			//label.frame = frame;
			label.backgroundColor = [self.parentTrackerObj.colorSet objectAtIndex:row];
			break;
		case 2:
			frame.size = sizeGTLabel;
			frame.size.width += FONTSIZE;
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
									  label.backgroundColor = [UIColor clearColor]; //greenColor];
			label.text = [self.graphTypes objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:FONTSIZE];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			break;
	}
	[label autorelease];
	return label;
	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	//CGSize siz;
	switch (component) {
		case 0:
			return sizeVOTLabel.width + (2.0f * FONTSIZE);
			break;
		case 1:
			return 3.0f * COLORSIDE;
			break;
		case 2:
			return sizeGTLabel.width + (2.0f * FONTSIZE);
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return 0.0f;
			break;
	}
}

#endif

- (void) updateColorCount {
	NSInteger oldcc = colorCount;
	
	if (self.tempValObj.vtype == VOT_CHOICE) {
		colorCount = 0;
	} else if (self.tempValObj.vGraphType == VOG_NONE) {
		colorCount = 0;
	} else if (colorCount == 0) {
		colorCount = [self.parentTrackerObj.colorSet count];
	}
	
	if (oldcc != colorCount) 
		[self.votPicker reloadComponent:1];
}

- (void) updateForPickerRowSelect:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		self.graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:row];
		
		[self.votPicker reloadComponent:2];
		[self updateColorCount];
		[self updateScrollView:row];
	} else if (component == 1) {
	} else if (component == 2) {
		[self updateColorCount];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		self.tempValObj.vtype = row;
	} else if (component == 1) {
		self.tempValObj.vcolor = row;
	} else if (component == 2) {
		self.tempValObj.vGraphType = [valueObj mapGraphType:[self.graphTypes objectAtIndex:row]];
	}
	
	[self updateForPickerRowSelect:row inComponent:component];
}


@end
