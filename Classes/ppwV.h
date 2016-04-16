/***************
 ppwV.h
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
