/***************
 ppwV.m
 Copyright 2011-2016 Robert T. Miller
 
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

@synthesize tob=_tob,parent=_parent,parentAction=_parentAction,topy=_topy,ok=_ok,cancel=_cancel,next=_next,parentView=_parentView;
@synthesize topLabel=_topLabel,topTF=_topTF,cancelBtn=_cancelBtn;
@synthesize activeField=_activeField;
//,saveFrame;

 
// UITextField *activeField;
//BOOL keyboardIsShown=NO;
// CGRect saveFrame;

- (id) initWithParentView:(UIView*)pv {
	CGRect frame = pv.frame;
	DBGLog(@"ppwV parent: x=%f y=%f w=%f h=%f",frame.origin.x,frame.origin.y,frame.size.width, frame.size.height);
    /*
    frame.origin.y = frame.size.height;// - 10.0f;
	if (kIS_LESS_THAN_IOS7) {
        frame.size.height *=0.25f;
        frame.origin.x = frame.size.width * 0.2f;
        frame.size.width *= 0.8f;
	} else {
        frame.size.height *=0.35f;
    }
    */
    frame.origin.x=0.0; frame.origin.y = 372.0; frame.size.width=320.0; frame.size.height=130.0;
	DBGLog(@"ppwV: x=%f y=%f w=%f h=%f",frame.origin.x,frame.origin.y,frame.size.width, frame.size.height);
	
    if ((self = [super initWithFrame:frame])) {
        if (kIS_LESS_THAN_IOS7) {
            self.backgroundColor = [UIColor darkGrayColor];
        } else {
            //self.backgroundColor = [UIColor whiteColor];
            // set graph paper background
            ///*
            UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[rTracker_resource getLaunchImageName]]];
            [self addSubview:bg];
            [self sendSubviewToBack:bg];
            // */
            //self.backgroundColor = [UIColor redColor];
        }
        self.layer.cornerRadius=8;
		self.parentView = pv;
		
		//keyboardIsShown = NO;
		self.activeField = nil;
        self.hidden=YES;

        [self toggleKeyboardNotifications:true];

        //DBGLog(@"ppwv add view; parent has %d subviews",[pv.subviews count]);
		//[pv addSubview:self];

		[pv insertSubview:self atIndex:[pv.subviews count]-1];   // 9.iii.14 change from -1 probably due to keyboard view
                                                                 // 15.xii.14 -2 back to -1
        //[pv addSubview:self];    // <- try for debug!
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

BOOL ObservingKeyboardNotification=false;

- (void) toggleKeyboardNotifications:(BOOL)newState {
    if (resigningActive) newState=NO;  // regardless of input we should not be watching notification if resigningActive
    if (newState == ObservingKeyboardNotification) return;
    if (newState) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:self.window];
        ObservingKeyboardNotification=true;
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:self.window];
        // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:self.window];
        ObservingKeyboardNotification=false;
    }
}

#pragma mark -
#pragma mark external api

- (void) hide {
    
    CGRect f = self.frame;
	//f.origin.y = ((UIView*)self.parent).frame.origin.y + ((UIView*)self.parent).frame.size.height;  // why different with privacyV ????
    //f.origin.y = ((UIView*)self.parent).frame.origin.y + ((UIView*)self.parent).frame.size.height;  // why different with privacyV ????
    
    f.origin.y = self.parentView.frame.size.height;  // self.topy + self.frame.size.height;
    self.frame = f;
    self.hidden = YES;
    
    // unregister for keyboard notifications while not visible.
    [self toggleKeyboardNotifications:false];
}

- (void) show {

    CGRect f = self.frame;
    self.hidden = NO;
    DBGLog(@"show: topy= %f  f= %f %f %f %f",self.topy,f.origin.x,f.origin.y,f.size.width, f.size.height );

    //[rTracker_resource willShowKeyboard:n view:self.view boty:boty];
    
	f.origin.y = self.topy - self.frame.size.height;
    
    
    [self toggleKeyboardNotifications:true];
    
	self.frame = f;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    DBGLog(@"keyboardwillshow");
    //CGRect f = self.topTF.frame;
    //CGRect f2 = self.frame;

    CGFloat boty = self.topTF.frame.origin.y + ( self.topTF.frame.size.height) + MARGIN - ( self.frame.size.height);

    [rTracker_resource willShowKeyboard:n view:self boty:boty];

}

- (void)keyboardWillHide:(NSNotification *)n
{
    DBGLog(@"handling keyboard will hide");
    [rTracker_resource willHideKeyboard];
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

    //self.hidden = YES;
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
    if (kIS_LESS_THAN_IOS7) {
        self.topLabel.textColor = [UIColor whiteColor];
    }
	[self.topTF addTarget:self action:@selector(testp) forControlEvents:UIControlEventEditingDidEnd];
	[self.cancelBtn addTarget:self action:@selector(cancelp) forControlEvents:UIControlEventTouchDown];
	
	[self showPassRqstr];
}
- (void) createPass:(unsigned int)okState cancel:(unsigned int)cancelState {
	//DBGLog(@"ppwv create pass");
	[self setUpPass:okState cancel:cancelState];

	self.topLabel.text = @"Please set a password:";
    if (kIS_LESS_THAN_IOS7) {
        self.topLabel.textColor = [UIColor whiteColor];
    }
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
	NSString *sql = @"create table if not exists priv0 (key integer primary key, val text);";
	[self.tob toExecSql:sql];
	sql = @"select count(*) from priv0 where key=0;";
	if ([self.tob toQry2Int:sql]) {
        DBGLog(@"password exists");
		return TRUE;
	} else {
        DBGLog(@"password does not exist");
	sql = @"create table if not exists priv1 (key integer primary key, lvl integer unique);";
		[self.tob toExecSql:sql];
		
		return FALSE;
	}
}

- (BOOL) dbTestPass:(NSString*)try {
	NSString *sql = @"select val from priv0 where key=0;";
    if ([try isEqualToString:[rTracker_resource fromSqlStr:[self.tob toQry2Str:sql]]])
		return TRUE;
	else 
		return FALSE;
}

- (void) dbSetPass:(NSString*)pass {
	NSString *sql = [NSString stringWithFormat:@"insert or replace into priv0 (key,val) values (0,'%@');",[rTracker_resource toSqlStr:pass]];
	[self.tob toExecSql:sql];
}

- (void) dbResetPass {
	NSString *sql = [NSString stringWithFormat:@"delete from priv0 where key=0;"];
	[self.tob toExecSql:sql];
    DBGLog(@"password reset");
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

	//[self.parent performSelector:self.parentAction];
    IMP imp = [self.parent methodForSelector:self.parentAction];
    void (*func)(id, SEL) = (void *)imp;
    func(self.parent, self.parentAction);
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

	//[self.parent performSelector:self.parentAction];
    IMP imp = [self.parent methodForSelector:self.parentAction];
    void (*func)(id, SEL) = (void *)imp;
    func(self.parent, self.parentAction);
}

# pragma mark -
# pragma mark UI element getters

- (CGRect) genFrame:(CGFloat)vert {
	CGRect f = self.frame;
	f.origin.x = 0.05f * f.size.width;
	f.origin.y = vert * f.size.height;
	f.size.width *= 0.9f;
    f.size.height = [@"X" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].height *1.2;
	//DBGLog(@"genframe: x: %f  y: %f  w: %f  h: %f",f.origin.x,f.origin.y,f.size.width,f.size.height);
	return f;
}

- (UILabel*) topLabel {
	if (nil == _topLabel) {
        if (kIS_LESS_THAN_IOS7) {
            _topLabel = [[UILabel alloc] initWithFrame:[self genFrame:0.05f]];
        } else {
            _topLabel = [[UILabel alloc] initWithFrame:[self genFrame:0.15f]];
        }
		//[topLabel setHidden:TRUE];
		_topLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_topLabel];
	}
	return _topLabel;
}


- (UITextField*) topTF {
	if (nil == _topTF) {
		_topTF = [[UITextField alloc] initWithFrame:[self genFrame:0.4f]];
		//[topTF setHidden:TRUE];
		_topTF.backgroundColor = [UIColor whiteColor];
		_topTF.returnKeyType = UIReturnKeyDone;
		_topTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_topTF.clearButtonMode = UITextFieldViewModeWhileEditing;
		_topTF.delegate = self;
        _topTF.layer.cornerRadius = 4;
        [_topTF setBorderStyle:UITextBorderStyleLine];
		
		[self addSubview:_topTF];
	}
	return _topTF;
}


- (UIButton*) cancelBtn {
	if (nil == _cancelBtn) {
		NSString* ttl=@" Cancel ";
		_cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_cancelBtn setTitle:ttl forState:UIControlStateNormal];
		CGRect f = CGRectZero;
		f.origin.x = 0.4f * self.frame.size.width;
		f.origin.y = 0.65f * self.frame.size.height;
        f.size = [ttl sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}];
		_cancelBtn.frame = f;
		//DBGLog(@"cancel frame: x: %f  y: %f  w: %f  h: %f",f.origin.x,f.origin.y,f.size.width,f.size.height);
		[_cancelBtn addTarget:self action:@selector(cancelp) forControlEvents:UIControlEventTouchDown];
		
		[self addSubview:_cancelBtn];
	}
	return _cancelBtn;
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
