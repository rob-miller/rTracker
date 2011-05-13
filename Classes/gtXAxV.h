//
//  gtXAxV.h
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "togd.h"

@interface gtXAxV : UIView {
    togd *togd;
    UIFont *myFont;
    CGFloat scaleOriginX;
    CGFloat scaleWidthX;
}

@property(nonatomic,retain) togd *togd;
@property(nonatomic,retain) UIFont *myFont;
@property(nonatomic) CGFloat scaleOriginX;
@property(nonatomic) CGFloat scaleWidthX;

- (void) drawXAxis:(CGContextRef)context;
@end
