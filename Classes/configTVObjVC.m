/***************
 configTVObjVC.m
 Copyright 2010-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

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
#import "rTracker-resource.h"
#import "voFunction.h"
#import "dbg-defs.h"

#import "notifyReminderViewController.h"

//  private methods including properties can go here!


@implementation configTVObjVC

@synthesize to=_to, vo=_vo, wDict=_wDict;
@synthesize toolBar=_toolBar, navBar=_navBar, lasty=_lasty, saveFrame=_saveFrame, LFHeight=_LFHeight, vdlConfigVO=_vdlConfigVO;
@synthesize activeField=_activeField, processingTfDone=_processingTfDone;
@synthesize scroll=_scroll;
@synthesize rDates = _rDates;

//BOOL keyboardIsShown;

//CGFloat LFHeight;  // textfield height based on parent viewcontroller's xib

#pragma mark -
#pragma mark core object methods and support

- (id) init {
    if ((self = [super init])) {
        self.processingTfDone=NO;
        self.rDates = [[NSMutableArray alloc] init];
    }
    return self;
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
    if (self.vdlConfigVO) {
        // done editing value obj
        if (self.vo.vtype == VOT_FUNC) {
            if (![((voFunction*)self.vo.vos) funcDone]) {
                [rTracker_resource alert:@"Invalid Function" msg:@"The function definition is not complete.\n  Please modify it so the '❌' does not show." vc:self];
                return;
            }
        }
    } else {
        // done editing tracker obj
    }
	
	//ios6 [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//- (IBAction) backgroundTap:(id)sender {
//	[activeField resignFirstResponder];
//}
//
/*
- (UIScrollView*) scroll {
    if (_scroll == nil) {
        CGRect svrect= CGRectMake(0,0,
                                  //self.navBar.frame.size.height,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height-(self.navBar.frame.size.height + self.toolBar.frame.size.height));
        _scroll = [[UIScrollView alloc] initWithFrame:svrect];
    }
    return _scroll;
}
*/

- (void) btnChoiceHelp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rob-miller.github.io/rTracker/rTracker/iPhone/QandA/choices.html"]];
}

- (void) btnInfoHelp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rob-miller.github.io/rTracker/rTracker/iPhone/QandA/info.html"]];
}


- (void)viewDidLoad {
	
	NSString *name;
	if (self.vo == nil) {
		name = self.to.trackerName;
		self.vdlConfigVO = NO;
	} else {
		name = self.vo.valueName;
		self.vdlConfigVO = YES;
	}
	
    //DBGLog(@"nav controller= %@",self.navigationController);

    
	if ((name == nil) || [name isEqualToString:@""]) 
        name = [NSString stringWithFormat:@"<%@>",[rTracker_resource vtypeNames][self.vo.vtype]];    // (self.to.votArray)[self.vo.vtype]];
	[[self.navBar.items lastObject] setTitle:[NSString stringWithFormat:@"Configure %@",name]];
	name = nil;
	 
    CGSize tsize = [@"X" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}];
    self.LFHeight = tsize.height +4;
	//self.LFHeight = 31.0f;
    
	//LFHeight = ((addValObjController *) [self parentViewController]).labelField.frame.size.height;
	
	//self.lasty = self.navBar.frame.origin.y + self.navBar.frame.size.height + MARGIN;
    self.lasty=2;
    self.lastx=2;
    
	if (self.vo == nil) {
		[self addTOFields];
	} else {
		[self addVOFields:self.vo.vtype];
	}
    //self.scroll.contentOffset = CGPointMake(0, -self.navBar.frame.size.height);
    CGSize svsize = [rTracker_resource get_visible_size:self];
    if (svsize.width < self.lastx) svsize.width=self.lastx;
    self.scroll.contentSize = CGSizeMake(svsize.width, self.lasty+(3*MARGIN));
    //[self.view addSubview:self.scroll];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
                                initWithTitle:@"\u2611"  // ballot box with check
                                style:UIBarButtonItemStylePlain
								//initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								target:self
								action:@selector(btnDone:)];

    [doneBtn setTitleTextAttributes:@{
                                      NSFontAttributeName: [UIFont systemFontOfSize:28.0]
                                      // doesn't work?  ,NSForegroundColorAttributeName: [UIColor greenColor]
                                      } forState:UIControlStateNormal];
    
	if (self.vdlConfigVO && self.vo.vtype == VOT_FUNC) {
		[(voFunction*)self.vo.vos funcVDL:self donebutton:doneBtn];
    } else 	if (self.vdlConfigVO &&
                ( VOT_CHOICE == self.vo.vtype || VOT_INFO == self.vo.vtype )
                ) {
        // help button links for choice and info types
        UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil action:nil];
        
        UIBarButtonItem *fnHelpButtonItem;
        if ( VOT_CHOICE == self.vo.vtype ) {
            fnHelpButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(btnChoiceHelp)];
        } else {
            fnHelpButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(btnInfoHelp)];
        }
        
        self.toolBar.items = @[doneBtn, flexibleSpaceButtonItem, fnHelpButtonItem];

    } else {
		self.toolBar.items = @[doneBtn];
	}

    bool darkMode = false;

    if (@available(iOS 13.0, *)) {
        darkMode = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    }
    
    if (darkMode) {
        if (@available(iOS 13.0, *)) {
            self.view.backgroundColor = [UIColor systemBackgroundColor];
        }
    } else {
        // set graph paper background
        CGSize vsize = [rTracker_resource get_visible_size:self];

        UIImage *img = [UIImage imageNamed:[rTracker_resource getLaunchImageName] ];
        UIImageView *bg0 = [[UIImageView alloc] initWithImage:img];
        CGFloat scal = bg0.frame.size.width / vsize.width;
        UIImage *img2 = [UIImage imageWithCGImage:img.CGImage scale:scal orientation:UIImageOrientationUp];

        UIImageView *bg = [[UIImageView alloc] initWithImage:img2];
        [self.view addSubview:bg];
        [self.view sendSubviewToBack:bg];
    }

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeRight:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];
    
    
    [super viewDidLoad];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self.view setNeedsDisplay];
}

- (void)handleViewSwipeRight:(UISwipeGestureRecognizer *)gesture {
    [self btnDone:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
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
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear :(BOOL)animated
{
    //DBGLog(@"remove kybd will show notifcation");
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
    
    [super viewWillDisappear:animated];
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

/*
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.wDict = nil;
	self.to = nil;
	self.vo = nil;
	
	self.toolBar = nil;
	self.navBar = nil;

}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#if DEBUGLOG
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	DBGLog(@"I am touched at %f, %f.",touchPoint.x, touchPoint.y);
#endif
    
	[_activeField resignFirstResponder];
}

# pragma mark -
# pragma mark textField support Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	//DBGLog(@"tf begin editing");
    self.activeField = textField;
}

/*
 choice textfields have custom action
 
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	//DBGLog(@"tf end editing");
    if ((nil != activeField) && 
        (NSOrderedSame == [@"choice" 
        [self tfDone:activeField];
    activeField = nil;
}
*/



 
# pragma mark -
# pragma mark keyboard notifications

- (void)keyboardWillShow:(NSNotification *)n
{
    //DBGLog(@"configTVObjVC keyboardwillshow");
    CGFloat boty = self.activeField.frame.origin.y + self.activeField.frame.size.height + MARGIN;
    [rTracker_resource willShowKeyboard:n view:self.scroll boty:boty];
    //[rTracker_resource willShowKeyboard:n view:self.view boty:boty];
    
    /*
    if (keyboardIsShown) { // need bit more logic to handle additional scrolling for another textfield
        return;
    }
	
	//DBGLog(@"handling keyboard will show");
	self.saveFrame = self.view.frame;
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	CGRect viewFrame = self.view.frame;
	//DBGLog(@"k will show, y= %f",viewFrame.origin.y);
	CGFloat boty = activeField.frame.origin.y + activeField.frame.size.height + MARGIN;

    CGFloat topk = viewFrame.size.height - keyboardSize.height;  // - viewFrame.origin.y;
	if (boty <= topk) {
		//DBGLog(@"activeField visible, do nothing  boty= %f  topk= %f",boty,topk);
	} else {
		//DBGLog(@"activeField hidden, scroll up  boty= %f  topk= %f",boty,topk);
		
		viewFrame.origin.y -= (boty - topk);
		//viewFrame.size.height -= self.toolBar.frame.size.height - MARGIN;
        viewFrame.size.height +=  MARGIN;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		[self.view setFrame:viewFrame];
		
		[UIView commitAnimations];
	}
	
    keyboardIsShown = YES;
	*/
}
- (void)keyboardWillHide:(NSNotification *)n
{
	//DBGLog(@"handling keyboard will hide");
	[rTracker_resource willHideKeyboard];
    
    /*
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.view setFrame:self.saveFrame];
	
	[UIView commitAnimations];
	
    keyboardIsShown = NO;	
     */
}



# pragma mark -
# pragma mark config region support Methods

#pragma mark newWidget methods

- (CGRect) configLabel:(NSString *)text frame:(CGRect)frame key:(NSString*)key addsv:(BOOL)addsv
{
    //frame.size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont labelFontSize]]}];
    frame.size = [text sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}];
	
	UILabel *rlab = [[UILabel alloc] initWithFrame:frame];
    rlab.font = PrefBodyFont;
	rlab.text = text;
	rlab.backgroundColor = [UIColor clearColor];

	(self.wDict)[key] = rlab;
	if (addsv)
        [self.scroll addSubview:rlab];
		//[self.view addSubview:rlab];
	
	CGRect retFrame = rlab.frame;
	
	return retFrame;
}

- (void) checkBtnAction:(UIButton*)btn
{
	NSString *okey=nil, *dflt, *ndflt=nil, *img;
	BOOL dfltState=AUTOSCALEDFLT;
	
	if ( btn == (self.wDict)[@"nasBtn"] ) {
		okey = @"autoscale"; dfltState=AUTOSCALEDFLT;
		if ([(NSString*) (self.vo.optDict)[okey] isEqualToString:@"0"]) { // will switch on
			[self removeGraphMinMax];
            //[self addGraphFromZero];  // ASFROMZERO
		} else {
            //[self removeGraphFromZero];
			[self addGraphMinMax];      // ASFROMZERO
		}
	} else if ( btn == (self.wDict)[@"csbBtn"] ) {  
		okey = @"shrinkb"; dfltState=SHRINKBDFLT;
	} else if ( btn == (self.wDict)[@"cevBtn"] ) {
		okey = @"exportvalb"; dfltState=EXPORTVALBDFLT;
	} else if ( btn == (self.wDict)[@"stdBtn"] ) {
		okey = @"setstrackerdate"; dfltState=SETSTRACKERDATEDFLT;
	} else if ( btn == (self.wDict)[@"sisBtn"] ) {
        okey = @"integerstepsb"; dfltState=INTEGERSTEPSBDFLT;
    } else if ( btn == (self.wDict)[@"sdeBtn"] ) {
        okey = @"defaultenabledb"; dfltState=DEFAULTENABLEDBDFLT;
    } else if ( btn == (self.wDict)[@"sswlBtn"] ) {
        okey = @"slidrswlb"; dfltState=SLIDRSWLBDFLT;
    } else if ( btn == (self.wDict)[@"tbnlBtn"] ) {
		okey = @"tbnl"; dfltState=TBNLDFLT;
	} else if ( btn == (self.wDict)[@"tbniBtn"] ) {
		okey = @"tbni"; dfltState=TBNIDFLT;
	} else if ( btn == (self.wDict)[@"tbhiBtn"] ) {
		okey = @"tbhi"; dfltState=TBHIDFLT;
	} else if ( btn == (self.wDict)[@"ggBtn"] ) {
		okey = @"graph"; dfltState=GRAPHDFLT;
	} else if ( btn == (self.wDict)[@"swlBtn"] ) {
		okey = @"nswl"; dfltState=NSWLDFLT;
    } else if ( btn == (self.wDict)[@"srBtn"] ) {
		okey = @"savertn"; dfltState=SAVERTNDFLT;
	} else if ( btn == (self.wDict)[@"graphLastBtn"] ) {
		okey = @"graphlast"; dfltState=GRAPHLASTDFLT;
	} else if ( btn == (self.wDict)[@"infosaveBtn"] ) {
		okey = @"infosave"; dfltState=INFOSAVEDFLT;
    }else {
		dbgNSAssert(0,@"ckButtonAction cannot identify btn");
        okey=@"x"; // make analyze happy
	}
	
	if (dfltState == YES) {
		dflt=@"1"; ndflt = @"0";
	} else {
		dflt=@"0"; ndflt = @"1";
	}
	
	if (self.vo == nil) {
		if ([(NSString*) (self.to.optDict)[okey] isEqualToString:ndflt]) {
			(self.to.optDict)[okey] = dflt; 
			img = (dfltState ? @"checked.png" : @"unchecked.png"); // going to default state
		} else {
			(self.to.optDict)[okey] = ndflt;
			img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
		}
	} else {
		if ([(NSString*) (self.vo.optDict)[okey] isEqualToString:ndflt]) {
			(self.vo.optDict)[okey] = dflt; 
			img = (dfltState ? @"checked.png" : @"unchecked.png"); // going to default state
		} else {
			(self.vo.optDict)[okey] = ndflt;
			img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
		}
	}
	[btn setImage:[UIImage imageNamed:img] forState: UIControlStateNormal];
	
}

- (CGRect) configCheckButton:(CGRect)frame key:(NSString*)key state:(BOOL)state addsv:(BOOL)addsv
{
    /*
    if (frame.origin.x + frame.size.width > [rTracker_resource getKeyWindowWidth]) {
        frame.origin.x = MARGIN;
        frame.origin.y += MARGIN + frame.size.height;
    }
    */
    
	UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	//imageButton.frame = CGRectInset(frame,-3,-3); // a bit bigger please
    imageButton.frame = frame; 
    imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;

	(self.wDict)[key] = imageButton;
	[imageButton addTarget:self action:@selector(checkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[imageButton setImage:[UIImage imageNamed:(state ? @"checked.png" : @"unchecked.png")] 
				 forState: UIControlStateNormal];
	
	if (addsv) {
        //[self.view addSubview:imageButton];
        [self.scroll addSubview:imageButton];
    }
    
    return frame;
}

- (CGRect) configActionBtn:(CGRect)frame key:(NSString*)key label:(NSString*)label target:(id)target action:(SEL)action {
    /*
    if (frame.origin.x + frame.size.width > [rTracker_resource getKeyWindowWidth]) {
        frame.origin.x = MARGIN;
        frame.origin.y += MARGIN + frame.size.height;
    }
    */
    
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.titleLabel.font = PrefBodyFont;
    frame.size.width = [label sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}].width + 4*SPACE;

	if (frame.origin.x == -1.0f) {
		frame.origin.x = self.view.frame.size.width - (frame.size.width + MARGIN); // right justify
	}
	button.frame = frame;
	[button setTitle:label forState:UIControlStateNormal];
	//imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	
	if (nil != key) {
        (self.wDict)[key] = button;
    }
    
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	//[self.view addSubview:button];
    [self.scroll addSubview:button];

    return frame;
}

- (void) tfDone:(UITextField *)tf {
    if (YES == self.processingTfDone)
        return;
    self.processingTfDone = YES;
    
	NSString *okey=nil, *nkey=nil;
	if ( tf == (self.wDict)[@"nminTF"] ) {
		okey = @"gmin";
		nkey = @"nmaxTF";
	} else if ( tf == (self.wDict)[@"nmaxTF"] ) {
		okey = @"gmax";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"sminTF"] ) {
		okey = @"smin";
		nkey = @"smaxTF";
	} else if ( tf == (self.wDict)[@"smaxTF"] ) {
		okey = @"smax";
		nkey = @"sdfltTF";
	} else if ( tf == (self.wDict)[@"sdfltTF"] ) {
		okey = @"sdflt";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"gpTF"] ) {
		okey = @"privacy";
		nkey = nil;
        
        int currPriv = [privacyV getPrivacyValue];
        int newPriv = [tf.text intValue];
        if (newPriv > currPriv) {
            //newPriv = currPriv;
            tf.text = [NSString stringWithFormat:@"%d",currPriv];
            NSString *msg = [NSString stringWithFormat:@"rTracker's privacy level is currently set to %d.  Setting an item to a higher privacy level than the current setting is disallowed.",currPriv];
            [rTracker_resource alert:@"Privacy higher than current" msg:msg vc:self];
        }
        newPriv = [tf.text intValue];
        if (newPriv < PRIVDFLT) {
            tf.text = [NSString stringWithFormat:@"%d",PRIVDFLT];
            NSString *msg = [NSString stringWithFormat:@"Setting a privacy level below %d is disallowed.",PRIVDFLT];
            [rTracker_resource alert:@"Privacy setting too low" msg:msg vc:self];
        }
    } else if ( tf == (self.wDict)[@"gyTF"] ) {
        okey = @"yline1";
        nkey = nil;
	} else if ( tf == (self.wDict)[@"gmdTF"] ) {
		okey = @"graphMaxDays";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"deTF"] ) {
		okey = @"dfltEmail";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"fr0TF"] ) {
		okey = @"frv0";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"fr1TF"] ) {
		okey = @"frv1";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"fnddpTF"] ) {
		okey = @"fnddp";
		nkey = nil;
    } else if ( tf == (self.wDict)[@"numddpTF"] ) {
        okey = @"numddp";
        nkey = nil;
	} else if ( tf == (self.wDict)[@"bvalTF"] ) {
		okey = @"boolval";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"ivalTF"] ) {
		okey = @"infoval";
		nkey = nil;
	} else if ( tf == (self.wDict)[@"iurlTF"] ) {
		okey = @"infourl";
		nkey = nil;
	} else if ( tf == (self.wDict)[CTFKEY] ) {
		okey = LCKEY;
		nkey = nil;
	} else {
		//dbgNSAssert(0,@"mtfDone cannot identify tf");
        okey=@"x"; // make analyze happy
	}

	if (self.vo == nil) {      // tracker config
		DBGLog(@"to set %@: %@", okey, tf.text);
		(self.to.optDict)[okey] = tf.text;
	} else {                   // valobj config
		DBGLog(@"vo set %@: %@", okey, tf.text);
		(self.vo.optDict)[okey] = tf.text;
	}
		
	if (nkey) {
		[(self.wDict)[nkey] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
    
    self.activeField=nil;
    
    self.processingTfDone = NO;
    
}


- (CGRect) configTextField:(CGRect)frame key:(NSString*)key target:(id)target action:(SEL)action num:(BOOL)num place:(NSString*)place text:(NSString*)text addsv:(BOOL)addsv
{
    /*
    if (frame.origin.x + frame.size.width > [rTracker_resource getKeyWindowWidth]) {
        frame.origin.x = MARGIN;
        frame.origin.y += MARGIN + frame.size.height;
    }
    */
    
	frame.origin.y -= TFXTRA;
	UITextField *rtf = [rTracker_resource rrConfigTextField:frame
                                                        key:key target:(target ? target : self)
                                                   delegate:self
                                                     action:(action ? action : @selector(tfDone:))
                                                        num:num
                                                      place:place text:text];
    	
	(self.wDict)[key] = rtf;
    
    if (addsv)
        [self.scroll addSubview:rtf];
		//[self.view addSubview:rtf];

    return frame;
}

- (CGRect) configTextView:(CGRect)frame key:(NSString*)key text:(NSString*)text {
    /*
    if (frame.origin.x + frame.size.width > [rTracker_resource getKeyWindowWidth]) {
        frame.origin.x = MARGIN;
        frame.origin.y += MARGIN + frame.size.height;
    }
    */
	UITextView *rtv = [[UITextView alloc] initWithFrame:frame];
	rtv.editable = NO;
	(self.wDict)[key] = rtv;
	
	rtv.text = text;
    //[rtv scrollRangeToVisible: (NSRange) { (NSUInteger) ([text length]-1), (NSUInteger)1 }];  // works 1st time but text is cached so doesn't work subsequently
	
    //[self.view addSubview:rtv];
    [self.scroll addSubview:rtv];

    return frame;
}


- (CGRect) configPicker:(CGRect)frame key:(NSString*)key caller:(id)caller {
    UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    frame.size = [myPickerView sizeThatFits:CGSizeZero];;
    frame.size.width = self.view.frame.size.width - (2*MARGIN);
    frame.origin.y += frame.size.height/4;  // because origin of picker is centre line
	myPickerView.frame = frame;
    //frame.size.height -= (frame.size.height/4);
    
	myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	myPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	myPickerView.delegate = caller;
	myPickerView.dataSource = caller;
	
	(self.wDict)[key] = myPickerView;
	[self.scroll addSubview:myPickerView];
	
	return frame;
}

#pragma mark autoscale / graph min/max options

- (void) removeGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[(self.wDict)[@"nminLab"] removeFromSuperview];
	[(self.wDict)[@"nminTF"] removeFromSuperview];
	[(self.wDict)[@"nmaxLab"] removeFromSuperview];
	[(self.wDict)[@"nmaxTF"] removeFromSuperview];
	
	[UIView commitAnimations];
}

- (void) addGraphMinMax 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	/*
	[self.view addSubview:(self.wDict)[@"nminLab"]];
	[self.view addSubview:(self.wDict)[@"nminTF"]];
	[self.view addSubview:(self.wDict)[@"nmaxLab"]];
	[self.view addSubview:(self.wDict)[@"nmaxTF"]];
	*/
    [self.scroll addSubview:(self.wDict)[@"nminLab"]];
    [self.scroll addSubview:(self.wDict)[@"nminTF"]];
    [self.scroll addSubview:(self.wDict)[@"nmaxLab"]];
    [self.scroll addSubview:(self.wDict)[@"nmaxTF"]];

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
					  state:(![(self.vo.optDict)[@"autoscale"] isEqualToString:@"0"])  // default:1
                      addsv:YES
     ];
	
	//if (! autoscale) {  still need to calc lasty, make room before general options
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"min:" frame:frame key:@"nminLab" addsv:NO];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
    CGFloat tfWidth = [@"9999999999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
	frame.size.width = tfWidth;
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self configTextField:frame 
					  key:@"nminTF" 
				   target:nil
				   action:nil
					  num:YES 
					place:@"<number>" 
					 text:(self.vo.optDict)[@"gmin"]  //was ngmin
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
					 text:(self.vo.optDict)[@"gmax"]  // was ngmax
					addsv:NO ];
	
	if ([(self.vo.optDict)[@"autoscale"] isEqualToString:@"0"]) 
		[self addGraphMinMax];
	
	return frame;
}



#pragma mark -
#pragma mark general opts for all 

- (void) notifyReminderView {
    DBGLog(@"notify reminder view!");
    notifyReminderViewController *nrvc = [[notifyReminderViewController alloc] initWithNibName:@"notifyReminderViewController" bundle:nil ];
    //nrvc.view.hidden = NO;
    nrvc.tracker = self.to;
    nrvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
        [self presentViewController:nrvc animated:YES completion:NULL];
    //} else {
    //    [self presentModalViewController:nrvc animated:YES];
    //}
        //[self.navigationController pushViewController:nrvc animated:YES];
    
    
}


/* prefer don't do this - better to just reload plist */
// added plist/dict load code so match on vid and valueName='recover%d' will overwrite
- (void) recoverValuesBtn {
    int recoverCount=0;
    NSMutableArray *Ids = [[NSMutableArray alloc]init];
    NSString *sql = @"select distinct id from voData order by id";
    [self.to toQry2AryI:Ids sql:sql];
    for (NSNumber *ni in Ids) {
        int i = [ni intValue];
       sql = [NSString stringWithFormat:@"select id from voConfig where id=%d",i];
        if (i != [self.to toQry2Int:sql]) {
            NSString *recoverName = [NSString stringWithFormat:@"recover%d",i];
           sql = [NSString stringWithFormat:@"insert into voConfig (id, rank, type, name, color, graphtype,priv) values (%d, %d, %d, '%@', %d, %d, %d);",
                           i, 0, VOT_NUMBER, recoverName, 0, VOG_DOTS, PRIVDFLT];
            [self.to toExecSql:sql];
            recoverCount++;
        }
    }
    NSString *msg;
    if (recoverCount) {
        msg = [NSString stringWithFormat:@"%d",recoverCount];
        [self.to loadConfig];
    } else {
        msg = @"no";
    }
    
    [rTracker_resource alert:@"Recovered Values" msg:[msg stringByAppendingString:@" values recovered"] vc:self];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 != buttonIndex) {
        [self recoverValuesBtn];
    }
}

- (void) setRemindersBtn {
    [self.to reminders2db];
    [self.to setReminders];
}

- (void) displayDbInfo {
       NSString *titleStr;
       
        NSString *sql = @"select count(*) from trkrData";
        int dateEntries = [self.to toQry2Int:sql];
        sql = @"select count(*) from voData";
        int dataPoints = [self.to toQry2Int:sql];
        sql = @"select count(*) from voConfig";
        int itemCount = [self.to toQry2Int:sql];
        
        titleStr = [NSString stringWithFormat:@"tracker number %ld\n%d items\n%d date entries\n%d data points",
                    (long)self.to.toid, itemCount, dateEntries,dataPoints];
       
        sql = @"select count(*) from (select * from voData where id not in (select id from voConfig))";
        int orphanDatapoints = [self.to toQry2Int:sql];
        
        if (0 < orphanDatapoints) {
            titleStr = [titleStr stringByAppendingString:[NSString stringWithFormat:@"\n%d missing item data points",orphanDatapoints]];
        }

        sql = @"select count(*) from reminders";
        int reminderCount = [self.to toQry2Int:sql];

        int scheduledReminderCount = (int) [self.rDates count];
        titleStr = [titleStr stringByAppendingString:[NSString stringWithFormat:@"\n\n%d stored reminders\n%d scheduled reminders",reminderCount,scheduledReminderCount]];
        for (NSDate* date in self.rDates) {
            titleStr = [titleStr stringByAppendingString:[NSString stringWithFormat:@"\n%@",
                                                          [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle]]];
        }
      
        __block UIUserNotificationSettings* uns;
        safeDispatchSync(^{
            uns = [[UIApplication sharedApplication] currentUserNotificationSettings];
        });
        if (! ([uns types] & (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge))) {
            titleStr = [titleStr stringByAppendingString:@"\n\n- Notifications Disabled -\nEnable in System Preferences."];
        }

        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
                                  
        titleStr = [titleStr stringByAppendingString:[NSString stringWithFormat:@"\n\n%@ %@ [%@]",infoDict[@"CFBundleDisplayName"], infoDict[@"CFBundleShortVersionString"], infoDict[@"CFBundleVersion"]]];
        
    //#endif
        safeDispatchSync(^{
            if (0 < orphanDatapoints) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.to.trackerName
                                                                               message:titleStr
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                UIAlertAction* recoverAction = [UIAlertAction actionWithTitle:@"recover missing items" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) { [self recoverValuesBtn]; }];
                
                [alert addAction:defaultAction];
                [alert addAction:recoverAction];
                
                [self presentViewController:alert animated:YES completion:nil];
                    
            } else {
                [rTracker_resource alert:self.to.trackerName msg:titleStr vc:self];
            }
        });
}


- (void) dbInfoBtn {
    // wait for checking notifications, then display above

    [self.rDates removeAllObjects];

     UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
     [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray *notifications) {
         for (int i=0;
              i<[notifications count];
              i++)
         {
             UNNotificationRequest *oneEvent = notifications[i];
             NSDictionary *userInfoCurrent = oneEvent.content.userInfo;
             //DBGLog(@"pending reminder for %ld my tid %ld", (long) [userInfoCurrent[@"tid"] integerValue], (long) self.to.toid);
             if ([userInfoCurrent[@"tid"] integerValue] == self.to.toid) {
                 NSDate *nextTD =  [((UNCalendarNotificationTrigger*)oneEvent.trigger) nextTriggerDate];
                 //DBGLog(@"td = %@", nextTD);
                 [self.rDates addObject:nextTD];
             }
         }
         [self displayDbInfo];
     }];

 }


//- (void) drawGeneralVoOpts 
//{
//}

- (void) drawGeneralToOpts 
{
	CGRect frame = {MARGIN,self.lasty,0.0,0.0};
	
	CGRect labframe = [self configLabel:@"save returns to tracker list:" frame:frame key:@"srLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	/*
    if (frame.origin.x + frame.size.width > [rTracker_resource getKeyWindowWidth]) {
        frame.origin.x = MARGIN;
        frame.origin.y += MARGIN + frame.size.height;
    }
    */
	//-- draw graphs button
	
	frame = [self configCheckButton:frame
						key:@"srBtn" 
					  state:(![(self.to.optDict)[@"savertn"] isEqualToString:@"0"]) // default = @"1"
                      addsv:YES
     ];
	
	//-- privacy level label
	
	frame.origin.x = MARGIN;
	//frame.origin.x += frame.size.width + MARGIN + SPACE;
	frame.origin.y += MARGIN + frame.size.height;
    labframe = [self configLabel:@"Privacy level:" frame:frame key:@"gpLab" addsv:YES];
	
	//-- privacy level textfield
	
	frame.origin.x += labframe.size.width + SPACE;
	
    CGFloat tfWidth = [@"9999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
	frame.size.width = tfWidth;
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	frame = [self configTextField:frame
					  key:@"gpTF" 
				   target:nil
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%d",PRIVDFLT] 
					 text:(self.to.optDict)[@"privacy"]
					addsv:YES ];
   
    //TODO: privacy values when password not set up....
    // if password not set could disable privacy setting here but have to pass pwset bool all over
    //  alternatively, don't allow setting privacy val higher than current?
    // ((UITextField*) [self.wDict objectForKey:@"gpTF"]).enabled = NO;

    //-- graph max _ days label
	
	frame.origin.x = MARGIN;
	//frame.origin.x += frame.size.width + MARGIN + SPACE;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"Graph limit:" frame:frame key:@"glLab" addsv:YES];
	
	//-- graph max _ days textfield
	
	frame.origin.x += labframe.size.width + SPACE;
	
    tfWidth = [@"999999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
	frame.size.width = tfWidth;
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
    NSString *gMaxDays = (self.to.optDict)[@"graphMaxDays"];
    if ([gMaxDays isEqualToString:@"0"]) {
            gMaxDays = @"";
    }
    
	frame = [self configTextField:frame
					  key:@"gmdTF"
				   target:nil
				   action:nil
					  num:YES
					place:@" "
					 text:gMaxDays
					addsv:YES ];
    
    //-- graph max _ days label 2  
    
    frame.origin.x += tfWidth + SPACE;
    //labframe =
    frame = [self configLabel:@"days" frame:frame key:@"gl2Lab" addsv:YES];
    
	
    //-- default email label
	
	frame.origin.x = MARGIN;
	//frame.origin.x += frame.size.width + MARGIN + SPACE;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [self configLabel:@"Default email:" frame:frame key:@"deLab" addsv:YES];
	
	//-- default email _ textfield
	
	frame.origin.x += labframe.size.width + SPACE;
	
	//tfWidth = [@"" sizeWithFont:PrefBodyFont].width;
	frame.size.width = self.view.frame.size.width - (2*SPACE) - labframe.size.width - MARGIN;
	frame.size.height = self.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
    NSString *dfltEmail = (self.to.optDict)[@"dfltEmail"];
        
	frame = [self configTextField:frame
					  key:@"deTF"
				   target:nil
				   action:nil
					  num:NO
					place:@" "
					 text:dfltEmail
					addsv:YES ];
    

    if (nil == self.vo) {
        
        frame.origin.x = MARGIN;
        //frame.origin.x += frame.size.width + MARGIN + SPACE;
        frame.origin.y += MARGIN + frame.size.height;
        
        if (nil != self.to.dbName) {
            
            // reminder config button:
            
            frame = [self configActionBtn:frame key:nil label:@"Reminders" target:self action:@selector(notifyReminderView)];
            
            // dbInfo values button:
            
            frame.origin.x = MARGIN;
            //frame.origin.x += frame.size.width + MARGIN + SPACE;
            frame.origin.y += MARGIN + frame.size.height;
            
            frame = [self configActionBtn:frame key:nil label:@"database info" target:self action:@selector(dbInfoBtn)];
            
            // 'reset reminders' button
            
            frame.origin.x = MARGIN;
            //frame.origin.x += frame.size.width + MARGIN + SPACE;
            frame.origin.y += MARGIN + frame.size.height;
            
            frame = [self configActionBtn:frame key:nil label:@"set reminders" target:self action:@selector(setRemindersBtn)];
        } else {

            frame.origin.y += MARGIN + frame.size.height;
            //labframe =
            frame = [self configLabel:@"(Save to enable reminders)" frame:frame key:@"erLab" addsv:YES];
            
        }
    }
    
    self.lasty = frame.origin.y + frame.size.height + (3*MARGIN);
    self.lastx = frame.origin.x + frame.size.width + (3*MARGIN);
}

#pragma mark main config region methods

- (NSMutableDictionary *) wDict 
{
	if (_wDict == nil) {
		_wDict = [[NSMutableDictionary alloc] init];
	}
	return _wDict;
}


- (void) removeSVFields 
{
	for (NSString *key in self.wDict) {
		//DBGLog(@"removing %@",key);
		[(UIView *) [self.wDict valueForKey:key] removeFromSuperview];
	}
	[self.wDict removeAllObjects];
	self.lasty = self.navBar.frame.origin.y + self.navBar.frame.size.height + MARGIN;
}



- (void) addVOFields:(NSInteger) vot
{
    [self.vo.vos voDrawOptions:self];
/*
 
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
            / *
		case VOT_IMAGE:
			//[self drawImageOpts];
			[self.vo.vos voDrawOptions:self];
			break;
             * /
		case VOT_FUNC:
			// uitextfield for function, picker or buttons for available valObjs and functions?
			//[self drawFuncOptsOverview];
			//if ([self.to.valObjTable count] == 0) {
				[self.vo.vos voDrawOptions:self];
			//}
			break;
        case VOT_INFO:
            [self.vo.vos voDrawOptions:self];
            break;
		default:
			break;
	}
 */
	
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
