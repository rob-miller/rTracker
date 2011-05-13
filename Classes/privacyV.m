//
//  privacyV.m
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "privacyV.h"
#import "rTracker-constants.h"
#import "privDefs.h"
#import "dbg-defs.h"

@implementation privacyV

@synthesize parentView, ttv, ppwv, showing, pwState, tob;
@synthesize clearBtn, configBtn,saveBtn, showSlider, ssValLab, nextBtn, prevBtn;

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
		self.pwState = PWNEEDPASS;
		self.backgroundColor = [UIColor brownColor];
		showing = PVNOSHOW;
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

- (unsigned int) dbGetAdjacentKey:(int*)lvl nxt:(BOOL)nxt {
	int rval;
	if (nxt)
		self.tob.sql = [NSString stringWithFormat:@"select key, lvl from priv1 where lvl>%d order by lvl asc limit 1;",*lvl];
	else
		self.tob.sql = [NSString stringWithFormat:@"select key, lvl from priv1 where lvl<%d order by lvl desc limit 1;",*lvl]; 
	[self.tob toQry2IntInt:&rval i2:lvl];
	return (unsigned int) rval;
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
	if (pwState == PWNEEDPASS) {
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
		[self.configBtn setTitle:@"config" forState:UIControlStateNormal];
		self.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * PVH));
	} else {
		self.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * PVH));
	}
}


// state control for what's showing

- (void) setShowing:(unsigned int)newState {
	DBGLog(@"priv: setShowing %d -> %d",showing,newState);
	// (showing == newState)
	//	return;
	
	if (PVNOSHOW != newState && PWNEEDPASS == self.pwState) {  // must set an initial password to use privacy features

		showing = PVNEEDPASS;
		[self.ppwv createPass:newState cancel:PVNOSHOW];  // recurse on input newState
		//[self.ppwv createPass:PVCONFIG cancel:PVNOSHOW]; // need more work // recurse on input newState, config on successful new pass

	} else if (PVQUERY == newState) {

		if (PVNEEDPASS == self.showing) { // if just created, pass is currently up, set up pvquery behind keyboard
			self.pwState = PWKNOWPASS;    // just successfully created password so don't ask again
			[self showPVQ:TRUE];
			//[self.ppwv hidePPWVAnimated:TRUE];  // don't hide and re-show
		} else {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kAnimationDuration];
			
			if (PVCONFIG == self.showing) {
				[self.ppwv hidePPWVAnimated:FALSE];
				[self hideConfigBtns:TRUE];
				[self.configBtn setTitle:@"config" forState:UIControlStateNormal];
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
			[self.ppwv hidePPWVAnimated:FALSE];
		} else {

			[self setPrivacyValue:[self dbTestKey:self.ttv.key]];
			
			if (PVCONFIG == self.showing) {
				[self.ppwv hidePPWVAnimated:FALSE];
				[self hideConfigBtns:TRUE];
			}
			[self showPVQ:FALSE];

		}

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
			[self.configBtn setTitle:@"lock" forState:UIControlStateNormal];
			[UIView commitAnimations];
			showing = PVCONFIG;
		} else {
			showing = PVCHECKPASS;
			[self.ppwv checkPass:PVCONFIG cancel:PVQUERY];
		}
	
	}
}

#pragma mark -
#pragma mark UI element target actions

- (void) ssAction:(id) sender {
	self.ssValLab.text = [NSString stringWithFormat:@"%d", (int) (self.showSlider.value + 0.5f)];
}

- (void) showConfig:(UIButton*)btn {
	
	if ([btn.currentTitle isEqualToString:@"config"]) {
		self.showing = PVCONFIG;
	} else if ([btn.currentTitle isEqualToString:@"lock"]) {
		self.showing = PVQUERY;
	}
}

- (void) doClear:(UIButton*)btn {
	[self.ttv showKey:0];
}

- (void) saveConfig:(UIButton*)btn {
	[self dbSetKey:self.ttv.key level:(int) (self.showSlider.value + 0.5f)];
}

- (void) adjustTTV:(UIButton*)btn {
	int lvl = (int) (self.showSlider.value + 0.5f);
	unsigned int k;
	if ([btn.currentTitle isEqualToString:@">"]) { // next
		k = [self dbGetAdjacentKey:&lvl nxt:TRUE];
	} else {  // prev
		k = [self dbGetAdjacentKey:&lvl nxt:FALSE];
	}
	if (lvl > 0) {
		[self.ttv showKey:k];
		self.showSlider.value = lvl;
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
	return rbtn;
}

- (UIButton *) clearBtn {
	if (clearBtn == nil) {
		clearBtn = [self getBtn:@"clear" 
						   borg: (CGPoint) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), 
							   self.frame.size.height * TICTACVRTFRAC}];
		[clearBtn addTarget:self action:@selector(doClear:) forControlEvents:UIControlEventTouchUpInside ];		
	}
	return clearBtn;
}

- (UIButton *) configBtn {
	if (configBtn == nil) {
		configBtn = [self getBtn:@"config"
							borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), 
								self.frame.size.height * TICTACVRTFRAC}];

		[configBtn addTarget:self action:@selector(showConfig:) forControlEvents:UIControlEventTouchUpInside ];
	}
	return configBtn;
}

- (UIButton *) saveBtn {
	if (saveBtn == nil) {
		saveBtn = [self getBtn:@"save"
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), 
							  self.frame.size.height * ((1.0f - TICTACVRTFRAC) - (1.0f - TICTACHGTFRAC))}];
		[saveBtn setHidden:TRUE];
		[saveBtn addTarget:self action:@selector(saveConfig:) forControlEvents:UIControlEventTouchUpInside ];
		
	}
	return saveBtn;
}

- (UIButton *) prevBtn {
	if (prevBtn == nil) {
		prevBtn = [self getBtn:@"<" 
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (TICTACHRZFRAC/2.0f)), // x= same as clearBtn
							  (TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height}];  // y= same as showslider
		[prevBtn addTarget:self action:@selector(adjustTTV:) forControlEvents:UIControlEventTouchUpInside ];
		[prevBtn setHidden:TRUE];
	}
	return prevBtn;
}
- (UIButton *) nextBtn {
	if (nextBtn == nil) {
		nextBtn = [self getBtn:@">"
						  borg:(CGPoint) {self.frame.origin.x+(self.frame.size.width * (1.0f - (TICTACHRZFRAC/2.0f))), // x= same as saveBtn
							  (TICTACVRTFRAC+TICTACHGTFRAC+TICTACVRTFRAC) * self.frame.size.height}];  // y= same as showslider
		[nextBtn addTarget:self action:@selector(adjustTTV:) forControlEvents:UIControlEventTouchUpInside ];
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
		ssValLab.text = @"1";
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
