/***************
 graphTrackerV.h
 Copyright 2010-2016 Robert T. Miller
 
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
//  graphTrackerV.h
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"
#import "valueObj.h"

#define NOXMARK -1.0f

@interface graphTrackerV : UIScrollView
/*{
	trackerObj *tracker;
    valueObj *gtvCurrVO;
    BOOL selectedVO;
    BOOL doDrawGraph;
    CGFloat xMark;
    id parentGTVC;
}*/

@property(nonatomic,strong) trackerObj *tracker;
@property(nonatomic,strong) valueObj *gtvCurrVO;
@property(nonatomic) BOOL selectedVO;
@property(nonatomic) BOOL doDrawGraph;
@property(nonatomic) CGFloat xMark;
@property(nonatomic,strong) id parentGTVC;
@property(nonatomic,strong) NSArray *searchXpoints;

//- (void)setTransform:(CGAffineTransform)newValue;

@end
