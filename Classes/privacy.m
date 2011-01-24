//
//  privacy.m
//  rTracker
//
//  Created by Robert Miller on 14/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "privacy.h"
#import "rTracker-constants.h"

@implementation privacy

@synthesize tictacView, privacyVC, parentView, pSetterShown;

#pragma mark -
#pragma mark singleton privacyValue support

static int privacyValue=0;

+ (int)getPrivacyValue {
	return privacyValue;
}

- (void)setPrivacyValue:(int)priv {
	privacyValue = priv;
}

#pragma mark -
#pragma mark core object methods and support


- (id) init {
	return [self initWithView:nil];
}

- (id) initWithView:(UIView*)pView {
	if (self = [super init]) {
		self.parentView = pView;
		pSetterShown = false;
	}
	
	return self;
}				


#define TTVH 0.3333f


- (UIView*) tictacView {
	if (tictacView == nil) {
		CGRect vbounds = self.parentView.frame;
		
		CGRect tictacRect = CGRectMake(0.0f,vbounds.size.height,vbounds.size.width,(vbounds.size.height * TTVH));
		self.tictacView = [[UIView alloc] initWithFrame:tictacRect];
		tictacView.backgroundColor = [UIColor whiteColor];
		
		
		
		[self.parentView addSubview:tictacView];
	}
	return tictacView;
}


- (void)displayPrivacySetter {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	self.tictacView.transform = CGAffineTransformMakeTranslation(0, -(self.parentView.frame.size.height * TTVH));
	[UIView commitAnimations];
	self.pSetterShown = true;
}

- (void)hidePrivacySetter {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	self.tictacView.transform = CGAffineTransformMakeTranslation(0, (self.parentView.frame.size.height * TTVH));
	[UIView commitAnimations];	
	self.pSetterShown = false;
}

- (void)togglePrivacySetter {
	if (self.pSetterShown) {
		[self hidePrivacySetter];
	} else {
		[self displayPrivacySetter];
	}
}


@end
