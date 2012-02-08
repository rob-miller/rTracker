//
//  ppw.m
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ppwV.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"
#import "dbg-defs.h"


@implementation ppwV

@synthesize tob,parent,parentAction,topy,ok,cancel,next,parentView;
@synthesize topLabel,topTF,cancelBtn;
@synthesize activeField;
//,saveFrame;

 
// UITextField *activeField;
//BOOL keyboardIsShown=NO;
// CGRect saveFrame;

- (id) initWithParentView:(UIView*)pv {
	CGRect frame = pv.frame;
	//DBGLog(@"ppwV parent: x=%f y=%f w=%f h=%f",frame.origin.x,frame.origin.y,frame.size.width, frame.size.height);
	frame.origin.y = frame.size.height;// - 10.0f;
	frame.origin.x = frame.size.width * 0.2f;
	frame.size.width *= 0.8f;
	frame.size.height *=0.25f;
	
	//DBGLog(@"ppwV: x=%f y=%f w=%f h=%f",frame.origin.x,frame.origin.y,frame.size.width, frame.size.height);
	
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor lightGrayColor];   //blueColor
        self.layer.cornerRadius=8;
		self.parentView = pv;
		
		//keyboardIsShown = NO;
		self.activeField = nil;
        self.hidden=YES;
/*
 [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:self.window];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillHide:) 
													 name:UIKeyboardWillHideNotification 
												   object:self.window];	
		
*/
		//DBGLog(@"ppwv add view; parent has %d subviews",[pv.subviews count]);
		//[pv addSubview:self];

		[pv insertSubview:self atIndex:[pv.subviews count]-1];
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
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
    self.topTF = nil;
    [topTF release];
    [super dealloc];
}


#pragma mark -
#pragma mark external api

- (void) hide {
	CGRect f = self.frame;
	//f.origin.y = ((UIView*)self.parent).frame.origin.y + ((UIView*)self.parent).frame.size.height;  // why different with privacyV ????
    f.origin.y = ((UIView*)self.parent).frame.origin.y + ((UIView*)self.parent).frame.size.height;  // why different with privacyV ????
    self.frame = f;
    self.hidden = YES;
}

- (void) show {
	CGRect f = self.frame;
    self.hidden = NO;
	f.origin.y = self.topy - self.frame.size.height;
	self.frame = f;
}

- (void) hidePPWVAnimated:(BOOL)animated {
	//DBGLog(@"hide ppwv anim=%d",animated);
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kAnimationDuration];
	}
	
	[self hide];

//	[self.topLabel setHidden:TRUE];
//	[self.topTF setHidden:TRUE];
	[self.topTF resignFirstResponder];
		
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark show the different requesters

- (void) setUpPass:(unsigned int)okState cancel:(unsigned int)cancelState {
	self.ok = okState;
	self.cancel = cancelState;
	//[self.topLabel setHidden:FALSE];
	self.topTF.text = @"";
	//[self.topTF setHidden:FALSE];
	//[self.cancelBtn setHidden:FALSE];
}

- (void) showPassRqstr {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];

	[self show];

	[self.topTF becomeFirstResponder];  //prints warning: @setting the first responder view of the table but we don't know its type (cell/header/footer)@
	[UIView commitAnimations];
}
- (void) checkPass:(unsigned int)okState cancel:(unsigned int)cancelState {
	//DBGLog(@"ppwv check pass");
	[self setUpPass:okState cancel:cancelState];
	self.topLabel.text = @"Please enter password:";
	[self.topTF addTarget:self action:@selector(testp) forControlEvents:UIControlEventEditingDidEnd];
	[self.cancelBtn addTarget:self action:@selector(cancelp) forControlEvents:UIControlEventTouchDown];
	
	[self showPassRqstr];
}
- (void) createPass:(unsigned int)okState cancel:(unsigned int)cancelState {
	//DBGLog(@"ppwv create pass");
	[self setUpPass:okState cancel:cancelState];

	self.topLabel.text = @"Please set a password:";
	[self.topTF addTarget:self action:@selector(setp) forControlEvents:UIControlEventEditingDidEnd];
	[self.cancelBtn addTarget:self action:@selector(cancelp) forControlEvents:UIControlEventTouchDown];
	
	[self showPassRqstr];
	
}

#pragma change password

#define ChangePassTxt @"Replace password:"

- (void) cpSetTopLabel {
	self.topLabel.text = ChangePassTxt;
}

- (void) changePAction {
	//[self.topTF resignFirstResponder];
	//DBGLog(@"change p to .%@.",self.topTF.text);
	if (! [self.topTF.text isEqualToString:@""]) {  // no empty passwords
        if (! [self dbTestPass:self.topTF.text]) {  // skip if the same (spurious editingdidend event on start)
            [self setp];
            self.topLabel.text = @"password changed";
            [self performSelector:@selector(cpSetTopLabel) withObject:nil afterDelay:1.0];
        }
	}
}

- (void) changePass:(unsigned int)okState cancel:(unsigned int)cancelState {
	//DBGLog(@"ppwv change pass");
	[self setUpPass:okState cancel:cancelState];
	[self cpSetTopLabel];
	[self.topTF removeTarget:self action:nil forControlEvents:UIControlEventEditingDidEnd];
	[self.topTF addTarget:self action:@selector(changePAction) forControlEvents:UIControlEventEditingDidEnd];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	[self show];

	[UIView commitAnimations];
}

#pragma mark -
#pragma mark password db interaction : password and key table creation as necessary 

- (BOOL) dbExistsPass {
	self.tob.sql = @"create table if not exists priv0 (key integer primary key, val text);";
	[self.tob toExecSql];
	self.tob.sql = @"select count(*) from priv0 where key=0;";
	if ([self.tob toQry2Int])
		return TRUE;
	else {
		self.tob.sql = @"create table if not exists priv1 (key integer primary key, lvl integer unique);";
		[self.tob toExecSql];
		
		return FALSE;
	}
}

- (BOOL) dbTestPass:(NSString*)try {
	self.tob.sql = @"select val from priv0 where key=0;";
	if ([try isEqualToString:[self.tob toQry2Str]])
		return TRUE;
	else 
		return FALSE;
}

- (void) dbSetPass:(NSString*)pass {
	self.tob.sql = [NSString stringWithFormat:@"insert or replace into priv0 (key,val) values (0,'%@');",pass];
	[self.tob toExecSql];
}

# pragma mark button Actions

- (void) setp {
    DBGLog(@"enter");
    if ([@"" isEqualToString:self.topTF.text]) {  // "" not valid password, or cancel
        self.next = self.cancel;
    } else {
        [self dbSetPass:self.topTF.text];
        self.next = self.ok;
    }
	if (![self.topLabel.text isEqualToString:ChangePassTxt]) {
		[self hide];
	}
	[parent performSelector:parentAction];
}

- (void) cancelp {
	self.topTF.text = @"";
	[self.topTF resignFirstResponder];  // closing topTF triggers setp action above
}

- (void) testp {
	//DBGLog(@"testp: %@",self.topTF.text);
	if ([self dbTestPass:self.topTF.text]) {
		self.next = self.ok;
	} else {
		self.next = self.cancel;
		[self hide];
	}
	[self.topTF resignFirstResponder];  // ???
	[parent performSelector:parentAction];
	
}

# pragma mark -
# pragma mark UI element getters

- (CGRect) genFrame:(CGFloat)vert {
	CGRect f = self.frame;
	f.origin.x = 0.05f * f.size.width;
	f.origin.y = vert * f.size.height;
	f.size.width *= 0.9f;
	f.size.height = [@"X" sizeWithFont:[UIFont systemFontOfSize:18]].height;
	//DBGLog(@"genframe: x: %f  y: %f  w: %f  h: %f",f.origin.x,f.origin.y,f.size.width,f.size.height);
	return f;
}

- (UILabel*) topLabel {
	if (nil == topLabel) {
		topLabel = [[UILabel alloc] initWithFrame:[self genFrame:0.05f]];
		//[topLabel setHidden:TRUE];
		topLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:topLabel];
	}
	return topLabel;
}

- (UITextField*) topTF {
	if (nil == topTF) {
		topTF = [[UITextField alloc] initWithFrame:[self genFrame:0.3f]];
		//[topTF setHidden:TRUE];
		topTF.backgroundColor = [UIColor whiteColor];
		topTF.returnKeyType = UIReturnKeyDone;
		topTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
		topTF.clearButtonMode = UITextFieldViewModeWhileEditing;
		topTF.delegate = self;
        topTF.layer.cornerRadius = 4;
		
		[self addSubview:topTF];
	}
	return topTF;
}


- (UIButton*) cancelBtn {
	if (nil == cancelBtn) {
		NSString* ttl=@" Cancel ";
		cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[cancelBtn setTitle:ttl forState:UIControlStateNormal];
		CGRect f = CGRectZero;
		f.origin.x = 0.4f * self.frame.size.width;
		f.origin.y = 0.65f * self.frame.size.height;
		f.size = [ttl sizeWithFont:[UIFont systemFontOfSize:18]];
		cancelBtn.frame = f;
		//DBGLog(@"cancel frame: x: %f  y: %f  w: %f  h: %f",f.origin.x,f.origin.y,f.size.width,f.size.height);
		[cancelBtn addTarget:self action:@selector(cancelp) forControlEvents:UIControlEventTouchDown];
		
		[self addSubview:cancelBtn];
	}
	return cancelBtn;
}


# pragma mark -
# pragma mark keyboard notifications


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	DBGLog(@"ppwv: tf begin editing");
	self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	DBGLog(@"ppwv: tf end editing");
	self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// the user pressed the "Done" button, so dismiss the keyboard
	DBGLog(@"textField done: %@", textField.text);
	//[target ppwvResponse];
	//[target performSelector:action];
	
	[textField resignFirstResponder];
	return YES;
}

/*
- (void)keyboardWillShow:(NSNotification *)n
{
    DBGLog(@"ppwV keyboardwillshow");
    
    if (keyboardIsShown) { // need bit more logic to handle additional scrolling for another textfield
        return;
    }
	
	DBGLog(@"handling keyboard will show: %@",[n object]);
	saveFrame = self.frame;
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];  //FrameBeginUserInfoKey 
	// convertRect accounts for size of toolbar at top
	CGRect kbdFrame = [self.parentView convertRect:[boundsValue CGRectValue] fromView:nil];
	
	CGRect viewFrame = self.frame;
	CGFloat boty= viewFrame.origin.y + viewFrame.size.height;
	CGFloat topk = kbdFrame.origin.y; 
	DBGLog(@"kybd frame: x: %f  y: %f  w: %f  h: %f",kbdFrame.origin.x,kbdFrame.origin.y,kbdFrame.size.width,kbdFrame.size.height);
	DBGLog(@"ppwv frame: x: %f  y: %f  w: %f  h: %f",viewFrame.origin.x,viewFrame.origin.y,viewFrame.size.width,viewFrame.size.height);
	if (boty <= topk) {
		//DBGLog(@"ppwv visible, do nothing  boty= %f  topk= %f",boty,topk);
	} else {
		//DBGLog(@"ppwv hidden, scroll up  boty= %f  topk= %f",boty,topk);
		DBGLog(@"new ppwv y = %f", viewFrame.origin.y - (boty - topk));
		
		viewFrame.origin.y -= (boty - topk + 10.0f);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		[self setFrame:viewFrame];
		
		[UIView commitAnimations];
	}
	
    keyboardIsShown = YES;
	
}
- (void)keyboardWillHide:(NSNotification *)n
{
	DBGLog(@"handling keyboard will hide");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self setFrame:saveFrame];
	
	[UIView commitAnimations];
	
    keyboardIsShown = NO;	
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#if DEBUGLOG
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	DBGLog(@"I am touched at %f, %f.",touchPoint.x, touchPoint.y);
#endif
    
	[self resignFirstResponder];
}


@end
