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

@interface privacyV : UIView {
	UIView *parentView;
	tictacV *ttv;
	ppwV *ppwv;
	BOOL shown;
}

@property (nonatomic,retain) UIView *parentView;
@property (nonatomic,retain) tictacV *ttv;
@property (nonatomic,retain) ppwV *ppwv;
@property (nonatomic) BOOL shown;

- (id) initWithParentView:(UIView*)pv;
- (void) togglePrivacySetter;

+ (int)getPrivacyValue;

@end
