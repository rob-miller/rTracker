//
//  gtYAxV.h
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "vogd.h"
@interface gtYAxV : UIView
/*{
    vogd *vogd;
    UIFont *myFont;
    CGFloat scaleOriginY;
    CGFloat scaleHeightY;
    UIScrollView *graphSV;
    
    id parentGTVC;
}*/

//@property(nonatomic,retain) UIColor *backgroundColor;

@property(nonatomic,strong) vogd *vogd;
@property(nonatomic,strong) UIFont *myFont;
@property(nonatomic) CGFloat scaleOriginY;
@property(nonatomic) CGFloat scaleHeightY;
@property(nonatomic,strong) UIScrollView *graphSV;

@property(nonatomic,strong) id parentGTVC;

@end
