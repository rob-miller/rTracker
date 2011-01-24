//
//  privacy.h
//  rTracker
//
//  Created by Robert Miller on 14/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface privacy : NSObject {
	UIView *tictacView;
	UIViewController *privacyVC;
	UIView *parentView;
	BOOL pSetterShown;
}

@property (nonatomic,retain) UIView* tictacView;
@property (nonatomic,retain) UIViewController* privacyVC;
@property (nonatomic,retain) UIView* parentView;
@property (nonatomic) BOOL pSetterShown;

- (id) initWithView:(UIView*)pView;
- (void)displayPrivacySetter;
- (void)hidePrivacySetter;
- (void)togglePrivacySetter;

+ (int)getPrivacyValue;
//+ (void)setPrivacyValue:(int)priv;

@end
