//
//  privacyV.h
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tObjBase.h"
#import "tictacV.h"
#import "ppwV.h"

@class RootViewController;

// password states
#define PWNEEDPRIVOK -2
#define PWNEEDPASS  -1
#define PWQUERYPASS  0
#define PWKNOWPASS	 1

// view states
// PVNOSHOW     :  not showing
// PVNEEDPASS   :  no password set
// PVQUERY      :  present tic-tack-toe query screen
// PVCHECKPASS  :  put up password requester prior to config open
// PVCONFIG     :  enable config controls

#define PVNOSHOW	((unsigned int) 0)
#define PVNEEDPASS	((unsigned int) (1<<0))
#define PVQUERY		((unsigned int) (1<<1))
#define PVCHECKPASS ((unsigned int) (1<<2))
#define PVCONFIG	((unsigned int) (1<<3))
#define PVSTARTUP	((unsigned int) (1<<4))


@interface privacyV : UIView <UIActionSheetDelegate>
/*{
	UIView *parentView;
    RootViewController *parent;
	tictacV *ttv;
	ppwV *ppwv;
	tObjBase *tob;
	unsigned int showing;
	int pwState;
}*/

@property (nonatomic,strong) UIView *parentView;
@property (nonatomic,strong) RootViewController *parent;
@property (nonatomic,strong) tictacV *ttv;
@property (nonatomic,strong) ppwV *ppwv;
@property (nonatomic,unsafe_unretained) tObjBase *tob;
@property (nonatomic) unsigned int showing;
@property (nonatomic) int pwState;

// UI element properties 

//  PVQUERY 
@property (nonatomic,strong) UIButton *clearBtn;
@property (nonatomic,strong) UIButton *configBtn;

//  PVCONFIG
@property (nonatomic,strong) UIButton *saveBtn;
@property (nonatomic,strong) UISlider *showSlider;
@property (nonatomic,strong) UILabel *ssValLab;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) UIButton *prevBtn;
 


- (id) initWithParentView:(UIView*)pv;
- (void) togglePrivacySetter;
- (UIButton*) getBtn:(NSString*)btitle borg:(CGPoint)borg;
- (int) lockDown;
- (void) resetPw;

+ (int)getPrivacyValue;
- (void)setPrivacyValue:(int)priv;

+ (void) jumpMaxPriv;
+ (void) restorePriv;

@end
