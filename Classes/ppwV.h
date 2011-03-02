//
//  ppw.h
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "tObjBase.h"

@interface ppwV : UIView <UITextFieldDelegate> {
	tObjBase *tob;
	id parent;
	SEL parentAction;
	CGFloat topy;     // top of privacyV
	unsigned int ok;
	unsigned int cancel;
	unsigned int next;
	
	UIView *parentView;
}

@property (nonatomic,retain) tObjBase *tob;
@property (nonatomic,retain) id parent;
@property (nonatomic) SEL parentAction;
@property (nonatomic) CGFloat topy;
@property (nonatomic) unsigned int ok;
@property (nonatomic) unsigned int cancel;
@property (nonatomic) unsigned int next;
@property (nonatomic,retain) UIView *parentView;

// UI elements
@property (nonatomic,retain) UILabel* topLabel;
@property (nonatomic,retain) UITextField* topTF;
@property (nonatomic,retain) UIButton* cancelBtn;

- (id) initWithParentView:(UIView*)pv;

- (void) hidePPWVAnimated:(BOOL)animated;
- (void) createPass:(unsigned int)okState cancel:(unsigned int)cancelState;
- (void) checkPass:(unsigned int)okState cancel:(unsigned int)cancelState;
- (void) changePass:(unsigned int)okState cancel:(unsigned int)cancelState;

- (BOOL) dbExistsPass;
- (BOOL) dbTestPass:(NSString*)try;
- (void) dbSetPass:(NSString*)pass;

- (void) testp;
- (void) setp;
- (void) cancelp;

@end
