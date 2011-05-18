//
//  gtYAxV.h
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "vogd.h"
@interface gtYAxV : UIView {
    vogd *vogd;
    UIFont *myFont;
    CGFloat scaleOriginY;
    CGFloat scaleHeightY;
    UIScrollView *graphSV;
    
    id parentGTVC;
}

@property(nonatomic,retain) vogd *vogd;
@property(nonatomic,retain) UIFont *myFont;
@property(nonatomic) CGFloat scaleOriginY;
@property(nonatomic) CGFloat scaleHeightY;
@property(nonatomic,retain) UIScrollView *graphSV;

@property(nonatomic,retain) id parentGTVC;

@end
