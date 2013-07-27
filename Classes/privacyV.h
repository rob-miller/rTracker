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

// password states
#define PWNEEDPRIVOK -2
#define PWNEEDPASS  -1
#define PWQUERYPASS  0
#define PWKNOWPASS	 1

// view states
#define PVNOSHOW	((unsigned int) 0)
#define PVNEEDPASS	((unsigned int) (1<<0))
#define PVQUERY		((unsigned int) (1<<1))
#define PVCHECKPASS ((unsigned int) (1<<2))
#define PVCONFIG	((unsigned int) (1<<3))

@interface privacyV : UIView <UIActionSheetDelegate> {
	UIView *parentView;
    id *parent;
	tictacV *ttv;
	ppwV *ppwv;
	tObjBase *tob;
	unsigned int showing;
	int pwState;
}

@property (nonatomic,retain) UIView *parentView;
@property (nonatomic) id *parent;
@property (nonatomic,retain) tictacV *ttv;
@property (nonatomic,retain) ppwV *ppwv;
@property (nonatomic,assign) tObjBase *tob;
@property (nonatomic) unsigned int showing;
@property (nonatomic) int pwState;

// UI element properties 

//  PVQUERY 
@property (nonatomic,retain) UIButton *clearBtn;
@property (nonatomic,retain) UIButton *configBtn;

//  PVCONFIG
@property (nonatomic,retain) UIButton *saveBtn;
@property (nonatomic,retain) UISlider *showSlider;
@property (nonatomic,retain) UILabel *ssValLab;
@property (nonatomic,retain) UIButton *nextBtn;
@property (nonatomic,retain) UIButton *prevBtn;
 


- (id) initWithParentView:(UIView*)pv;
- (void) togglePrivacySetter;
- (UIButton*) getBtn:(NSString*)btitle borg:(CGPoint)borg;
- (void) lockDown;
- (void) resetPw;

+ (int)getPrivacyValue;
- (void)setPrivacyValue:(int)priv;

@end
