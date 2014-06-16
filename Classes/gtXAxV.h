//
//  gtXAxV.h
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "togd.h"


@interface gtXAxV : UIView
/*{
    togd *mytogd;
    UIFont *myFont;
    CGFloat scaleOriginX;
    CGFloat scaleWidthX;
    UIScrollView *graphSV;
}*/

@property(nonatomic,strong) togd *mytogd;
@property(nonatomic,strong) UIFont *myFont;
@property(nonatomic) CGFloat scaleOriginX;
@property(nonatomic) CGFloat scaleWidthX;
@property(nonatomic,strong) UIScrollView *graphSV;

- (void) drawXAxis:(CGContextRef)context;
@end
