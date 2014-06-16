//
//  voSlider.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"

@interface voSlider : voState
/*{
    UISlider *sliderCtl;
    CGFloat sdflt;
}*/

@property (nonatomic,strong) UISlider *sliderCtl;
@property (nonatomic) CGFloat sdflt;

@end
