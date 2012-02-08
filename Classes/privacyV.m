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

#define CFGBTNCONFIG @" Setup "
#define CFGBTNLOCK   @" Lock  "

@implementation privacyV

@synthesize parentView, parent, ttv, ppwv, showing, pwState, tob;
@synthesize clearBtn, configBtn,saveBtn, showSlider, ssValLab, nextBtn, prevBtn;

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

- (void) lockDown {
    DBGLog(@"privObj: lockdown");
    // needs more -- [self setPrivacyValue:MINPRIV]; 
    self.pwState = PWQUERYPASS;
    //self.showing = PVNOSHOW;
    if ([self.configBtn.currentTitle isEqualToString:CFGBTNLOCK]) {
		self.showing = PVQUERY;
    }
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
#define PVH 0.45f

- (id)initWithParentView:(UIView *)pv {
	CGSize pfs = pv.frame.size;
	CGRect frame = CGRectMake(0.0f,pfs.height,pfs.width,(pfs.height * PVH));
	DBGLog(@"privacyV: x=%f y=%f w=%f h=%f",frame.origin.x,frame.origin.y,frame.size.width, frame.size.height);
	if ((self = [super initWithFrame:frame])) {
		self.parentView = pv;
		self.pwState = PWNEEDPRIVOK; //PWNEEDPASS;
		self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 8;
		showing = PVNOSHOW;
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
		
		[self.parentView addSubview:self];
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
    [super dealloc];
}

#pragma mark -
#pragma mark key value db interaction

- (int) dbTestKey:(int)try {
	self.tob.sql = [NSString stringWithFormat: @"select lvl from priv1 where key=%d;",try];
	return [self.tob toQry2Int];
}

- (void) dbSetKey:(int) key level:(int) lvl{
	if (key != 0) {  
		self.tob.sql = [NSString stringWithFormat:@"insert or replace into priv1 (key,lvl) values ('%d','%d');",key,lvl];
	} else {
		self.tob.sql = [NSString stringWithFormat:@"delete from priv1 where lvl=%d;",lvl];
	}
	[self.tob toExecSql];

}

- (unsigned int) dbGetKey:(int)lvl {
    self.tob.sql = [NSString stringWithFormat:@"select key from priv1 where lvl=%d;",lvl];
    return [self.tob toQry2Int];
}

- (unsigned int) dbGetAdjacentKey:(int*)lvl nxt:(BOOL)nxt {
	int rkey;
	if (nxt)
		self.tob.sql = [NSString stringWithFormat:@"select key, lvl from priv1 where lvl>%d order by lvl asc limit 1;",*lvl];
	else
		self.tob.sql = [NSString stringWithFormat:@"select key, lvl from priv1 where lvl<%d order by lvl desc limit 1;",*lvl]; 
    DBGLog(@"getAdjacentVal: next=%d in lvl=%d",nxt,*lvl);
	[self.tob toQry2IntInt:&rkey i2:lvl];
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
#pragma mark -
#pragma mark custom ivar setters and getters

- (int) pwState {
	if ((PWNEEDPASS == pwState) || (PWNEEDPRIVOK == pwState)) {
		if ([self.ppwv dbExistsPass])
			pwState = PWQUERYPASS;
	} 
	return pwState;
}

- (void) ppwvResponse {
	DBGLog(@"ppwvResponse: transition to %d",self.ppwv.next);
	
	self.showing = self.ppwv.next;
}

- (ppwV*) ppwv {
	if (nil == ppwv) {
		ppwv = [[ppwV alloc] initWithParentView:self.parentView];
		//ppwv = [[ppwV alloc] initWithParentView:self];
		ppwv.tob = self.tob;
		ppwv.parent = self;
		ppwv.parentAction = @selector(ppwvResponse);
		ppwv.topy = self.frame.origin.y - self.frame.size.height;  // why different with ppwv????
	}
	return ppwv;
}

- (void) showPVQ:(BOOL)state {
	if (state) {
		[self.configBtn setTitle:CFGBTNCONFIG forState:UIControlStateNormal];
		//self.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * PVH));
        self.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * PVH));
	} else {
		//self.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * PVH));
        self.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * PVH));
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
        self.showing = PVQUERY;
    }
}


// state control for what's showing

- (void) setShowing:(unsigned int)newState {
	DBGLog(@"priv: setShowing %d -> %d  curr priv= %d",showing,newState,[privacyV getPrivacyValue]);
    //[(RootViewController*) self.parent refreshToolBar:YES];
    
	// (showing == newState)
	//	return;
	
	if (PVNOSHOW != newState && PWNEEDPRIVOK == self.pwState) {  // first time if no password set, better warn not secure
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Private but not secure"
                                                        message:@"Privacy: This feature can hide trackers and values from display, but the data will not be secure from a determined attacker."
                                                           delegate:self 
                                                  cancelButtonTitle:@"I'll remember" 
                                                  otherButtonTitles:@"Skip for now",nil];
        [alert show]; 
        [alert release];
        
        
                
    } else if (PVNOSHOW != newState && PWNEEDPASS == self.pwState) {  // must set an initial password to use privacy features        
		showing = PVNEEDPASS;
		[self.ppwv createPass:newState cancel:PVNOSHOW];  // recurse on input newState
		//[self.ppwv createPass:PVCONFIG cancel:PVNOSHOW]; // need more work // recurse on input newState, config on successful new pass

	} else if (PVQUERY == newState) {
        //self.hidden = NO;
        self.alpha = 1.0;
		if (PVNEEDPASS == self.showing) { // if just created, pass is currently up, set up pvquery behind keyboard
			self.pwState = PWKNOWPASS;    // just successfully created password so don't ask again
			[self showPVQ:TRUE];
			//[self.ppwv hidePPWVAnimated:TRUE];  // don't hide and re-show
            // crash[(RootViewController*) self.parentView refreshToolBar:YES];
		} else {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kAnimationDuration];
			
			if (PVCONFIG == self.showing) {
				[self.ppwv hidePPWVAnimated:FALSE];
				[self hideConfigBtns:TRUE];
				[self.configBtn setTitle:CFGBTNCONFIG forState:UIControlStateNormal];
			} else {  // only PVNOSHOW possible ?
				[self showPVQ:TRUE];
			}
			
			[UIView commitAnimations];	
		}
		showing = PVQUERY;

	} else if (PVNOSHOW == newState) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kAnimationDuration];
		
		if (PVNEEDPASS == self.showing) { // if set pass is up, cancelled out of create
            //DBGLog(@"cancelled out of create pass");
			[self.ppwv hidePPWVAnimated:FALSE];
            [self.parentView setNeedsDisplay];  //  privateBtn.title = @"private";
		} else {

			[self setPrivacyValue:(MINPRIV + [self dbTestKey:self.ttv.key])]; // 14.ix.2011 privacy not 0
			
			if (PVCONFIG == self.showing) {
				[self.ppwv hidePPWVAnimated:FALSE];
				[self hideConfigBtns:TRUE];
			}
			[self showPVQ:FALSE];

		}

        //self.hidden = YES;
        self.alpha = 0.0;
		[UIView commitAnimations];
		
		showing = PVNOSHOW;
		
        
	} else if (PVCONFIG == newState) {
		if (PWKNOWPASS == self.pwState || PVCHECKPASS == self.showing) {
			if (PVCHECKPASS == self.showing) {
				self.pwState = PWKNOWPASS;   // just successfully entered password so don't ask again
				[self hideConfigBtns:FALSE];
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:kAnimationDuration];
				//[self.ppwv hidePPWVAnimated:FALSE];
			} else {
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:kAnimationDuration];
				[self hideConfigBtns:FALSE];
			}
			[self.ppwv changePass:PVCONFIG cancel:PVCONFIG];
			[self.configBtn setTitle:CFGBTNLOCK forState:UIControlStateNormal];
            [self setTTV];
			[UIView commitAnimations];
			showing = PVCONFIG;
            [(RootViewController*) self.parent refreshToolBar:YES];

		} else {
			showing = PVCHECKPASS;
			[self.ppwv checkPass:PVCONFIG cancel:PVQUERY];
		}
	
	}
    [(RootViewController*) self.parent refreshToolBar:YES];
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
	if (ttv == nil) {
		ttv = [[tictacV alloc] initWithPFrame:self.frame];
		ttv.tob = self.tob;
	}
	return ttv;
}

- (UIButton*) getBtn:(NSString*)btitle borg:(CGPoint)borg {
	UIButton *rbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect ];
	CGRect bframe = (CGRect) {borg, [btitle sizeWithFont:[UIFont systemFontOfSize:18]]};
	bframe.origin.x -= bframe.size.width/2.0f;  // center now we know btn title size
	rbtn.frame = bframe;
	[rbtn setTitle:btitle forState:UIControlStateNormal];
    // doesn't work here : rbtn.layer.cornerRadius = BTNRADIUS;
	return rbtn;
}

- (UIButton *) clearBtn {
	if (clearBtn == nil) {
		clearBtn = [self getBtn:@" Clear " 
						   borg: (CGPoint) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), 
							   self.frame.size.height * TICTACVRTFRAC}];
		[clearBtn addTarget:self action:@selector(doClear:) forControlEvents:UIControlEventTouchUpInside ];		
        clearBtn.layer.cornerRadius = BTNRADIUS;
	}
	return clearBtn;
}

- (UIButton *) configBtn {
	if (configBtn == nil) {
        
		configBtn = [self getBtn:CFGBTNCONFIG
							borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), 
								self.frame.size.height * TICTACVRTFRAC}];
         
        /*
         // use button title for state info
        configBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        configBtn.frame = CGRectMake(self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))),
                                     self.frame.size.height * TICTACVRTFRAC,
                                     44, 44);
         */
		[configBtn addTarget:self action:@selector(showConfig:) forControlEvents:UIControlEventTouchUpInside ];
        configBtn.layer.cornerRadius = BTNRADIUS;
	}
	return configBtn;
}

- (UIButton *) saveBtn {
	if (saveBtn == nil) {
		saveBtn = [self getBtn:@" Save "
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), 
							  self.frame.size.height * ((1.0f - TICTACVRTFRAC) - (1.0f - TICTACHGTFRAC))}];
		[saveBtn addTarget:self action:@selector(saveConfig:) forControlEvents:UIControlEventTouchUpInside ];
        saveBtn.layer.cornerRadius = BTNRADIUS;
		[saveBtn setHidden:TRUE];
	}
	return saveBtn;
}

- (UIButton *) prevBtn {
	if (prevBtn == nil) {
		prevBtn = [self getBtn:PRVBTNLBL 
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), // x= same as clearBtn
							  (TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height}];  // y= same as showslider
		[prevBtn addTarget:self action:@selector(adjustTTV:) forControlEvents:UIControlEventTouchUpInside ];
        prevBtn.layer.cornerRadius = BTNRADIUS;
		[prevBtn setHidden:TRUE];
	}
	return prevBtn;
}
- (UIButton *) nextBtn {
	if (nextBtn == nil) {
		nextBtn = [self getBtn:NXTBTNLBL
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), // x= same as saveBtn
							  (TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height}];  // y= same as showslider
		[nextBtn addTarget:self action:@selector(adjustTTV:) forControlEvents:UIControlEventTouchUpInside ];
        nextBtn.layer.cornerRadius = BTNRADIUS;
		[nextBtn setHidden:TRUE];
	}
	return nextBtn;
}

- (UILabel*) ssValLab {
	if (ssValLab == nil) {
		CGRect lframe = (CGRect) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), // x= same as clearBtn
			self.frame.size.height * ((1.0f - TICTACVRTFRAC) - (1.0f - TICTACHGTFRAC)), // y = same as saveBtn
			[@"100" sizeWithFont:[UIFont systemFontOfSize:18]]};
		lframe.origin.x -= lframe.size.width/2.0f;
		ssValLab = [[UILabel alloc] initWithFrame:lframe];
		ssValLab.textAlignment = UITextAlignmentRight;
		ssValLab.text = @"2";  // MINPRIV +1
        ssValLab.layer.cornerRadius = LBLRADIUS;
		[ssValLab setHidden:TRUE];
		
	}
	return ssValLab;

}

- (UISlider*) showSlider {
	if (showSlider == nil) {
		CGRect sframe = {TICTACHRZFRAC * self.frame.size.width, // x orig = same as ttv
			(TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height, // y orig = same below ttv as ttv is down from top
			TICTACWIDFRAC * self.frame.size.width,  // width = same as ttv
			TICTACVRTFRAC * self.frame.size.height * 0.8f};  // height = 80% of dstance to ttv
										
		showSlider = [[UISlider alloc] initWithFrame:sframe];
		showSlider.backgroundColor = [UIColor clearColor];
		showSlider.minimumValue = MINPRIV+1;
		showSlider.maximumValue = MAXPRIV;
		//showSlider.continuous = FALSE;
		[showSlider addTarget:self action:@selector(ssAction:) forControlEvents:UIControlEventValueChanged];
		[showSlider setHidden:TRUE];
		
	}
	return showSlider;
}


@end
