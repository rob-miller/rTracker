/***************
 privacyV.h
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
// PWNEEDPRIVOK :  need to introduce privacy with the 'skip for now' requester
// PWNEEDPASS   :  need to set password (first usage)
// PWQUERYPASS  :  user has not authenticated yet for config controls
// PWKNOWPASS   :  user has authenticated with password

#define PWNEEDPRIVOK -2
#define PWNEEDPASS  -1
#define PWQUERYPASS  0
#define PWKNOWPASS	 1

// view states
//
// PVNOSHOW     :  not showing
// PVNEEDPASS   :  no password set, requester to set is showing
// PVQUERY      :  present tic-tack-toe query screen
// PVCHECKPASS  :  put up password requester prior to config open
// PVCONFIG     :  enable config controls
// PVSTARTUP    :

#define PVNOSHOW	((unsigned int) 0)
#define PVNEEDPASS	((unsigned int) (1<<0))
#define PVQUERY		((unsigned int) (1<<1))
#define PVCHECKPASS ((unsigned int) (1<<2))
#define PVCONFIG	((unsigned int) (1<<3))
#define PVSTARTUP	((unsigned int) (1<<4))


@interface privacyV : UIView 
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
