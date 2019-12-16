/***************
 privacyV.m
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
//  privacyV.m
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "privacyV.h"
#import "rTracker-constants.h"
#import "privDefs.h"
#import "dbg-defs.h"
#import "RootViewController.h"
#import "rTracker-resource.h"

#define CFGBTNCONFIG @" Setup "
#define CFGBTNLOCK   @" Lock  "

@implementation privacyV

@synthesize parentView=_parentView, parent=_parent, ttv=_ttv, ppwv=_ppwv, showing=_showing, pwState=_pwState, tob=_tob;
@synthesize clearBtn=_clearBtn, configBtn=_configBtn,saveBtn=_saveBtn, showSlider=_showSlider, ssValLab=_ssValLab, nextBtn=_nextBtn, prevBtn=_prevBtn;

#define BTNRADIUS 2
#define LBLRADIUS 4

#define NXTBTNLBL @"  >  "
#define PRVBTNLBL @"  <  "

#pragma mark -
#pragma mark singleton privacyValue support

static int privacyValue=PRIVDFLT;

+ (int)getPrivacyValue {
	return privacyValue;
}

- (void)setPrivacyValue:(int)priv {
	privacyValue = priv;
	DBGLog(@"updatePrivacy:%d",[privacyV getPrivacyValue]);
	//[self.pvc.tableView reloadData ];
}

static NSNumber *stashedPriv=nil;

+ (void) jumpMaxPriv {
    if (nil == stashedPriv) {
        stashedPriv = @([privacyV getPrivacyValue]);
        DBGLog(@"stashed priv %@",stashedPriv);
    }
    
    //[self.privacyObj setPrivacyValue:MAXPRIV];  // temporary max privacy level so see all
    privacyValue = MAXPRIV;
    DBGLog(@"priv jump!");
}

+ (void) restorePriv {
    if (nil == stashedPriv) {
        return;
    }
    //if (YES == self.openUrlLock) {
    //    return;
    //}
    DBGLog(@"restore priv to %@",stashedPriv);
    //[self.privacyObj setPrivacyValue:[self.stashedPriv intValue]];  // return to privacy level
    privacyValue = (int) [stashedPriv integerValue];
    stashedPriv = nil;
    
}


- (int) lockDown {
    DBGLog(@"privObj: lockdown");
    int currP = privacyValue;
    
    [self.ttv showKey:0];
    [self setPrivacyValue:MINPRIV];

    if (PWNEEDPRIVOK != self.pwState) {  // 27.v.2013 don't set to query if no pw setup yet
        self.pwState = PWQUERYPASS;
    }

    self.showing = PVNOSHOW;
    //if ([self.configBtn.currentTitle isEqualToString:CFGBTNLOCK]) {
	//	self.showing = PVQUERY;
    //}
    return currP;
}


#pragma mark -
#pragma mark core UIView object methods and support

/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}
*/

// pvh hardcodes portrait keyboard height
#define PVH 0.46f

- (id)initWithParentView:(UIView *)pv  {
    DBGLog(@"privV enter parent= x=%f y=%f w=%f h=%f",pv.frame.origin.x,pv.frame.origin.y,pv.frame.size.width, pv.frame.size.height);
    //CGRect frame = CGRectMake(0.0f, pv.frame.size.height,pv.frame.size.width,(pv.frame.size.height * PVH));
    // like this but need to re-calc button positions too :-( CGRect frame = CGRectMake(pv.frame.size.width-320.0, pv.frame.size.height,320.0,171.0);
    CGRect frame = CGRectMake(0.0, pv.frame.size.height,320.0,171.0);
	DBGLog(@"privacyV: x=%f y=%f w=%f h=%f",frame.origin.x,frame.origin.y,frame.size.width, frame.size.height);
	if ((self = [super initWithFrame:frame])) {
		self.parentView = pv;
		self.pwState = PWNEEDPRIVOK; //PWNEEDPASS;
       // if (kIS_LESS_THAN_IOS7) {
       //     self.backgroundColor = [UIColor darkGrayColor];
       // } else {
            //self.backgroundColor = [UIColor whiteColor];
            // set graph paper background
            // /*
            UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[rTracker_resource getLaunchImageName]]];
            [self addSubview:bg];
            [self sendSubviewToBack:bg];
             // */
            //self.backgroundColor = [UIColor greenColor];
        //}
        self.layer.cornerRadius = 8;
		self.showing = PVNOSHOW;
        //self.hidden = YES;
        self.alpha = 0.0;

		[self addSubview:self.ttv];
		[self addSubview:self.clearBtn];
		[self addSubview:self.configBtn];
		[self addSubview:self.saveBtn];
		[self addSubview:self.showSlider];
		[self addSubview:self.prevBtn];
		[self addSubview:self.nextBtn];
		[self addSubview:self.ssValLab];
		
        [self bringSubviewToFront:self.ttv];
        
		[self.parentView addSubview:self];
        [self.parentView bringSubviewToFront:self];
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


#pragma mark -
#pragma mark key value db interaction

- (int) dbTestKey:(int)try {
	NSString *sql = [NSString stringWithFormat: @"select lvl from priv1 where key=%d;",try];
	return [self.tob toQry2Int:sql];
}

- (void) dbSetKey:(int) key level:(int) lvl{
    NSString *sql;

	if (key != 0) {  
        sql = [NSString stringWithFormat:@"insert or replace into priv1 (key,lvl) values ('%d','%d');",key,lvl];
	} else {
        sql = [NSString stringWithFormat:@"delete from priv1 where lvl=%d;",lvl];
	}
	[self.tob toExecSql:sql];

}

- (unsigned int) dbGetKey:(int)lvl {
    NSString *sql = [NSString stringWithFormat:@"select key from priv1 where lvl=%d;",lvl];
    return [self.tob toQry2Int:sql];
}

- (unsigned int) dbGetAdjacentKey:(int*)lvl nxt:(BOOL)nxt {
	int rkey;
    NSString *sql;

	if (nxt)
        sql = [NSString stringWithFormat:@"select key, lvl from priv1 where lvl>%d order by lvl asc limit 1;",*lvl];
	else
	sql = [NSString stringWithFormat:@"select key, lvl from priv1 where lvl<%d order by lvl desc limit 1;",*lvl]; 
    DBGLog(@"getAdjacentVal: next=%d in lvl=%d",nxt,*lvl);
	[self.tob toQry2IntInt:&rkey i2:lvl sql:sql];
    DBGLog(@"getAdjacentVal: rtn lvl=%d  key=%d",*lvl,rkey);
	return (unsigned int) rkey;
}


#pragma mark -
#pragma mark show / hide view

- (void)hideConfigBtns:(BOOL)state {
	[self.saveBtn setHidden:state];
	[self.nextBtn setHidden:state];
	[self.prevBtn setHidden:state];
	[self.showSlider setHidden:state];
	[self.ssValLab setHidden:state];
}


- (void)togglePrivacySetter {
	if (PVNOSHOW == self.showing) {
		self.showing = PVQUERY;
	} else {
		self.showing = PVNOSHOW;
	}
}

- (void) resetPw {
    [self.ppwv dbResetPass];
    self.pwState = PWNEEDPRIVOK;
    self.showing = PVNOSHOW;
    [self setPrivacyValue:MINPRIV];
}
     
#pragma mark -
#pragma mark custom ivar setters and getters

- (int) pwState {
	if ((PWNEEDPASS == _pwState) || (PWNEEDPRIVOK == _pwState)) {
		if ([self.ppwv dbExistsPass])
			_pwState = PWQUERYPASS;
	} 
	return _pwState;
}

- (void) ppwvResponse {
	DBGLog(@"ppwvResponse: transition to %d",self.ppwv.next);
	
	self.showing = self.ppwv.next;
}

- (ppwV*) ppwv {
	if (nil == _ppwv) {
		_ppwv = [[ppwV alloc] initWithParentView:self.parentView];
		//ppwv = [[ppwV alloc] initWithParentView:self];
		_ppwv.tob = self.tob;
		_ppwv.parent = self;
		_ppwv.parentAction = @selector(ppwvResponse);
        
		_ppwv.topy = self.parentView.frame.size.height - self.frame.size.height;
        DBGLog(@"pv.y = %f  s.h = %f  ty= %f",self.parentView.frame.size.height,self.frame.size.height,_ppwv.topy);
	}
	return _ppwv;
}

static NSTimeInterval lastShow=0;

- (void) showPVQ:(BOOL)state {
    DBGLog(@"parent v h= %f  pvh= %f  prod= %f",self.parentView.frame.size.height,PVH,self.parentView.frame.size.height * PVH );
    DBGLog(@"x= %f  y= %f  w= %f  h= %f",self.frame.origin.x, self.frame.origin.y, self.frame.size.width,self.frame.size.height);
	if (state) {
        // show
        lastShow = [[NSDate date] timeIntervalSinceReferenceDate];
		[self.configBtn setTitle:CFGBTNCONFIG forState:UIControlStateNormal];
		//self.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * PVH));
        //self.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * PVH));
        self.transform = CGAffineTransformMakeTranslation(0, -(self.frame.size.height));
        //self.parentView.userInteractionEnabled=NO;  // sadly kills interaction for child view as well
	} else {
        // hide
        NSTimeInterval thisHide = [[NSDate date] timeIntervalSinceReferenceDate];
        DBGLog(@"lastShow= %lf thisHide= %lf delta= %lf",lastShow,thisHide,(thisHide-lastShow));
        if ((thisHide - lastShow) <= 0.6) {
            [self.ttv showKey:0]; 
            [self setPrivacyValue:PRIVDFLT];
        }
        [self.ppwv hide];
        
		//self.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * PVH));
        //self.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * PVH));
        self.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height));
        //self.parentView.userInteractionEnabled=YES;
    }
}

// make ttv match slider
- (void) setTTV {
	int lvl = (int) (self.showSlider.value + 0.5f);
	unsigned int k;
    k = [self dbGetKey:lvl];
	if (lvl > 0) {
		[self.ttv showKey:k];
		self.showSlider.value = lvl;
		self.ssValLab.text = [NSString stringWithFormat:@"%d", (int) lvl];
	}
}

// alert to inform privacy limits and use

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) {
        self.pwState = PWNEEDPASS;
        //self.showing = PVSTARTUP;
        self.showing = PVQUERY;
    }
}

// state control for what's showing
- (void) setShowing:(unsigned int)newState {
	DBGLog(@"priv: setShowing %d -> %d  curr priv= %d",_showing,newState,[privacyV getPrivacyValue]);
    if ((PVNOSHOW == _showing) && (PVNOSHOW == newState))
        return;  // this happens when closing down.
    
    //[(RootViewController*) self.parent refreshToolBar:YES];
    
	// (showing == newState)
	//	return;
	
	if (PVNOSHOW != newState && PWNEEDPRIVOK == self.pwState) {  // first time if no password set, give some instructions
        NSString *title = @"Privacy";
        NSString *msg = @"This feature is for hiding trackers and values from display, with up to 99 filter levels.\nThe first step is to set a configuration password, then associate patterns with privacy levels as desired.\nThe password can be reset in System Preferences.";
        NSString *btn0 = @"Let's go";
        NSString *btn1 = @"Skip for now";
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                           delegate:self 
                                                  cancelButtonTitle:btn0
                                                  otherButtonTitles:btn1,nil];
            [alert show];
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:btn0 style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      self.pwState = PWNEEDPASS;
                                                                      //self.showing = PVSTARTUP;
                                                                      self.showing = PVQUERY;
                                                                  }];
            
            UIAlertAction* skipAction = [UIAlertAction actionWithTitle:btn1 style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [alert addAction:skipAction];
            
            /*
            UIViewController *vc;
            UIWindow *w = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            w.rootViewController = [UIViewController new];
            w.windowLevel = UIWindowLevelAlert +1;
            [w makeKeyAndVisible];
            vc = w.rootViewController;
            //vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
            [vc presentViewController:alert animated:YES completion:nil];
            */
            
            UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
            [vc presentViewController:alert animated:YES completion:nil];
            
        }
        
        
                
    } else if (PVNOSHOW != newState && PWNEEDPASS == self.pwState) {  // must set an initial password to use privacy features        
		_showing = PVNEEDPASS;
        [self.ppwv createPass:newState cancel:PVNOSHOW];  // recurse on input newState
		//[self.ppwv createPass:PVCONFIG cancel:PVNOSHOW]; // need more work // recurse on input newState, config on successful new pass

	} else if (PVQUERY == newState) {
        //self.hidden = NO;
        self.alpha = 1.0;
		if (PVNEEDPASS == _showing) { // if just created, pass is currently up, set up pvquery behind keyboard
			self.pwState = PWKNOWPASS;    // just successfully created password so don't ask again
			[self showPVQ:TRUE];
			//[self.ppwv hidePPWVAnimated:TRUE];  // don't hide and re-show
            // crash[(RootViewController*) self.parentView refreshToolBar:YES];
            //self.showing = PVCONFIG;
		} else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kAnimationDuration];
			
            if (PVCONFIG == _showing) {
                [self.ppwv hidePPWVAnimated:FALSE];
                [self hideConfigBtns:TRUE];
                [self.configBtn setTitle:CFGBTNCONFIG forState:UIControlStateNormal];
            } else {  // only PVNOSHOW possible ?
                [self showPVQ:TRUE];
            }
			
            [UIView commitAnimations];	
		}
        if (PVNEEDPASS == _showing) {
            _showing = PVQUERY;
            self.showing = PVCONFIG;
            return;
        }
        _showing = PVQUERY;

	} else if (PVNOSHOW == newState) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kAnimationDuration];
		
		if (PVNEEDPASS == _showing) { // if set pass is up, cancelled out of create
            DBGLog(@"cancelled out of create pass");
			[self.ppwv hidePPWVAnimated:FALSE];
            [self.parentView setNeedsDisplay];  //  privateBtn.title = @"private";
		} else {

			[self setPrivacyValue:(MINPRIV + [self dbTestKey:self.ttv.key])]; // 14.ix.2011 privacy not 0
			
			if (PVCONFIG == _showing) {
				[self.ppwv hidePPWVAnimated:FALSE];
				[self hideConfigBtns:TRUE];
			}
			[self showPVQ:FALSE];

		}

        //self.hidden = YES;
        self.alpha = 0.0;
		[UIView commitAnimations];
        
		_showing = PVNOSHOW;
		
        
	} else if (PVCONFIG == newState) {
        if (PWKNOWPASS == self.pwState || (PVCHECKPASS == _showing && self.ppwv.ok == self.ppwv.next)) {
			if (PVCHECKPASS == _showing) {
				self.pwState = PWKNOWPASS;   // just successfully entered password so don't ask again
			//	[self hideConfigBtns:FALSE];
			//	[UIView beginAnimations:nil context:NULL];
			//	[UIView setAnimationDuration:kAnimationDuration];
			//	//[self.ppwv hidePPWVAnimated:FALSE];
			} //else {
				[self hideConfigBtns:FALSE];
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:kAnimationDuration];
			//}

			[self.ppwv changePass:PVCONFIG cancel:PVCONFIG];
			[self.configBtn setTitle:CFGBTNLOCK forState:UIControlStateNormal];
            [self setTTV];
			[UIView commitAnimations];
			_showing = PVCONFIG;
            [self.parent refreshToolBar:YES];

		} else {
			_showing = PVCHECKPASS;
			[self.ppwv checkPass:PVCONFIG cancel:PVQUERY];
		}
	
	}
    [self.parent refreshToolBar:YES];
    //DBGLog(@"leaving setshowing, noshow= %d",(PVNOSHOW == showing));
}

#pragma mark -
#pragma mark UI element target actions

- (void) ssAction:(id) sender {
	self.ssValLab.text = [NSString stringWithFormat:@"%d", (int) (self.showSlider.value + 0.5f)];
}

- (void) showConfig:(UIButton*)btn {
	
	if ([btn.currentTitle isEqualToString:CFGBTNCONFIG]) {
		self.showing = PVCONFIG;
	} else if ([btn.currentTitle isEqualToString:CFGBTNLOCK]) {
		self.showing = PVQUERY;
	}
}

- (void) doClear:(UIButton*)btn {
	[self.ttv showKey:0]; 
}

- (void) saveConfig:(UIButton*)btn {
    unsigned int ttvkey;
    
    if ((ttvkey=self.ttv.key) != 0) {  // don't allow saving blank tt for a privacy level
        [self dbSetKey:ttvkey level:(int) (self.showSlider.value + 0.5f)];
    }
}

- (void) adjustTTV:(UIButton*)btn {
	int lvl = (int) (self.showSlider.value + 0.5f);
    ///*
	unsigned int k;
    BOOL dir;
	if ([btn.currentTitle isEqualToString:NXTBTNLBL]) { // next
        dir = TRUE;
	} else {  // prev
        dir = FALSE;
	}
    
    DBGLog(@"adjustTTv: slider lvl= %d dir=%d",lvl,dir);
    
    k = [self dbGetAdjacentKey:&lvl nxt:dir];

    if (k == 0) { // if getAdjacent failed = no next/prev key for curr slider value
        lvl = (int) (self.showSlider.value + 0.5f); // got wiped so reload
        if (0 == [self dbGetKey:lvl]) { // and no existing key for curr slider
            //k = 
            [self dbGetAdjacentKey:&lvl nxt:!dir];  // go for prev/next (opposite dir)
        }
    }
	//*/
    
    if (lvl > 0) {
		self.showSlider.value = lvl;
		//[self.ttv showKey:k];
        [self setTTV];  // display key if exists for slider value whatever it is now
		self.ssValLab.text = [NSString stringWithFormat:@"%d", (int) lvl];
	}
}


#pragma mark -
#pragma mark UI element getters

- (tictacV *) ttv {
	if (_ttv == nil) {
		_ttv = [[tictacV alloc] initWithPFrame:self.frame];
		_ttv.tob = self.tob;
	}
	return _ttv;
}

- (UIButton*) getBtn:(NSString*)btitle borg:(CGPoint)borg {
	UIButton *rbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect ];
    CGRect bframe;
    //if (kIS_LESS_THAN_IOS7) {
    //    bframe = (CGRect) {borg, [btitle sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}]};
    //} else {
        bframe = (CGRect) {borg, [btitle sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}]};
    //}
	bframe.origin.x -= bframe.size.width/2.0f;  // center now we know btn title size
	rbtn.frame = bframe;
	[rbtn setTitle:btitle forState:UIControlStateNormal];
    // doesn't work here : rbtn.layer.cornerRadius = BTNRADIUS;
	return rbtn;
}

- (UIButton *) clearBtn {
	if (_clearBtn == nil) {
		_clearBtn = [self getBtn:@" Clear "
						   borg: (CGPoint) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), 
							   self.frame.size.height * TICTACVRTFRAC}];
		[_clearBtn addTarget:self action:@selector(doClear:) forControlEvents:UIControlEventTouchUpInside ];
        _clearBtn.layer.cornerRadius = BTNRADIUS;
        //clearBtn.backgroundColor = [UIColor whiteColor];
	}
	return _clearBtn;
}

- (UIButton *) configBtn {
	if (_configBtn == nil) {
        
		_configBtn = [self getBtn:CFGBTNCONFIG
							borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), 
								self.frame.size.height * TICTACVRTFRAC}];
         
        /*
         // use button title for state info
        configBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        configBtn.frame = CGRectMake(self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))),
                                     self.frame.size.height * TICTACVRTFRAC,
                                     44, 44);
         */
		[_configBtn addTarget:self action:@selector(showConfig:) forControlEvents:UIControlEventTouchUpInside ];
        _configBtn.layer.cornerRadius = BTNRADIUS;
        //configBtn.backgroundColor = [UIColor whiteColor];
	}
	return _configBtn;
}

- (UIButton *) saveBtn {
	if (_saveBtn == nil) {
		_saveBtn = [self getBtn:@" Save "
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), 
							  self.frame.size.height * ((1.0f - TICTACVRTFRAC) - (1.0f - TICTACHGTFRAC))}];
		[_saveBtn addTarget:self action:@selector(saveConfig:) forControlEvents:UIControlEventTouchUpInside ];
        _saveBtn.layer.cornerRadius = BTNRADIUS;
		[_saveBtn setHidden:TRUE];
	}
	return _saveBtn;
}

- (UIButton *) prevBtn {
	if (_prevBtn == nil) {
		_prevBtn = [self getBtn:PRVBTNLBL
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), // x= same as clearBtn
							  (TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height}];  // y= same as showslider
		[_prevBtn addTarget:self action:@selector(adjustTTV:) forControlEvents:UIControlEventTouchUpInside ];
        _prevBtn.layer.cornerRadius = BTNRADIUS;
		[_prevBtn setHidden:TRUE];
	}
	return _prevBtn;
}
- (UIButton *) nextBtn {
	if (_nextBtn == nil) {
		_nextBtn = [self getBtn:NXTBTNLBL
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), // x= same as saveBtn
							  (TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height}];  // y= same as showslider
		[_nextBtn addTarget:self action:@selector(adjustTTV:) forControlEvents:UIControlEventTouchUpInside ];
        _nextBtn.layer.cornerRadius = BTNRADIUS;
		[_nextBtn setHidden:TRUE];
	}
	return _nextBtn;
}

- (UILabel*) ssValLab {
	if (_ssValLab == nil) {
		CGRect lframe = (CGRect) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), // x= same as clearBtn
			self.frame.size.height * ((1.0f - TICTACVRTFRAC) - (1.0f - TICTACHGTFRAC)), // y = same as saveBtn
            [@"100" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}]};
		lframe.origin.x -= lframe.size.width/2.0f;
		_ssValLab = [[UILabel alloc] initWithFrame:lframe];
        _ssValLab.textAlignment = NSTextAlignmentRight;  // ios6 UITextAlignmentRight;
		_ssValLab.text = @"2";  // MINPRIV +1
        _ssValLab.layer.cornerRadius = LBLRADIUS;
		[_ssValLab setHidden:TRUE];
		
	}
	return _ssValLab;

}

- (UISlider*) showSlider {
	if (_showSlider == nil) {
		CGRect sframe = {TICTACHRZFRAC * self.frame.size.width, // x orig = same as ttv
			(TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height, // y orig = same below ttv as ttv is down from top
			TICTACWIDFRAC * self.frame.size.width,  // width = same as ttv
			TICTACVRTFRAC * self.frame.size.height * 0.8f};  // height = 80% of dstance to ttv
										
		_showSlider = [[UISlider alloc] initWithFrame:sframe];
		_showSlider.backgroundColor = [UIColor clearColor];
		_showSlider.minimumValue = MINPRIV+1;
		_showSlider.maximumValue = MAXPRIV;
		//showSlider.continuous = FALSE;
		[_showSlider addTarget:self action:@selector(ssAction:) forControlEvents:UIControlEventValueChanged];
		[_showSlider setHidden:TRUE];
		
	}
	return _showSlider;
}


@end
