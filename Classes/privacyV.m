//
//  privacyV.m
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "privacyV.h"
#import "rTracker-constants.h"

@implementation privacyV

@synthesize parentView, ttv, ppwv, shown;

#pragma mark -
#pragma mark singleton privacyValue support

static int privacyValue=0;

+ (int)getPrivacyValue {
	return privacyValue;
}

- (void)setPrivacyValue:(int)priv {
	privacyValue = priv;
}

/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}
*/
#define PVH 0.3333f

- (id)initWithParentView:(UIView *)pv {
	CGSize pfs = pv.frame.size;
	CGRect frame = CGRectMake(0.0f,pfs.height,pfs.width,(pfs.height * PVH));
	if ((self = [super initWithFrame:frame])) {
		self.parentView = pv;
		self.backgroundColor = [UIColor redColor];
		self.shown = false;
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


- (void)displayPrivacySetter {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	self.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * PVH));
	[UIView commitAnimations];
	self.shown = true;
}

- (void)hidePrivacySetter {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	self.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * PVH));
	[UIView commitAnimations];	
	self.shown = false;
}

- (void)togglePrivacySetter {
	if (self.shown) {
		[self hidePrivacySetter];
	} else {
		[self displayPrivacySetter];
	}
}



@end
