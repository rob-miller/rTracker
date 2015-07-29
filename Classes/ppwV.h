//
//  ppw.h
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "tObjBase.h"

@interface ppwV : UIView <UITextFieldDelegate>
/*{
	tObjBase *tob;
	id parent;
	SEL parentAction;
	CGFloat topy;     // top of privacyV
	unsigned int ok;
	unsigned int cancel;
	unsigned int next;
	
	UIView *parentView;
    
    UITextField *activeField;
    //CGRect saveFrame;
    
}*/

@property (nonatomic,strong) tObjBase *tob;
@property (nonatomic,strong) id parent;
@property (nonatomic) SEL parentAction;
@property (nonatomic) CGFloat topy;
@property (nonatomic) unsigned int ok;
@property (nonatomic) unsigned int cancel;
@property (nonatomic) unsigned int next;
@property (nonatomic,strong) UIView *parentView;

@property (nonatomic,strong) UITextField *activeField;
//@property (nonatomic) CGRect saveFrame;

// UI elements
@property (nonatomic,strong) UILabel* topLabel;
@property (nonatomic,strong) UITextField* topTF;
@property (nonatomic,strong) UIButton* cancelBtn;

- (id) initWithParentView:(UIView*)pv;

- (void) hidePPWVAnimated:(BOOL)animated;
- (void) createPass:(unsigned int)okState cancel:(unsigned int)cancelState;
- (void) checkPass:(unsigned int)okState cancel:(unsigned int)cancelState;
- (void) changePass:(unsigned int)okState cancel:(unsigned int)cancelState;

- (BOOL) dbExistsPass;
- (BOOL) dbTestPass:(NSString*)try;
- (void) dbSetPass:(NSString*)pass;
- (void) dbResetPass;

- (void) testp;
- (void) setp;
- (void) cancelp;

- (void) hide;

@end
