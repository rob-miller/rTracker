/***************
 gtYAxV.h
 Copyright 2011-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

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
