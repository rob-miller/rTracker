/***************
 graphTrackerVC.h
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
//  graphTracker.h
//  rTracker
//
//
//  need a view controller for presentModalViewController
//  but work is done in view
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"
#import "valueObj.h"

#import "graphTrackerV.h"

#import "useTrackerController.h"

#import "dpRslt.h"

#import "gtTitleV.h"
#import "gtVONameV.h"
#import "gtXAxV.h"
#import "gtYAxV.h"


@interface graphTrackerVC : UIViewController <UIScrollViewDelegate>
/*{
	trackerObj *tracker;
    valueObj *currVO;
    UIFont *myFont;
    
    UIScrollView *scrollView;
    graphTrackerV *gtv;
    gtTitleV *titleView;
    gtVONameV *voNameView;
    gtXAxV *xAV;
    gtYAxV *yAV;
    
    dpRslt *dpr;
    
    useTrackerController *parentUTC;
    
    int32_t shakeLock;

}
*/

@property(nonatomic,strong) trackerObj *tracker;
@property(nonatomic,strong) valueObj *currVO;

@property(nonatomic,strong) UIFont *myFont;

@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) graphTrackerV *gtv;
@property(nonatomic,strong) gtTitleV *titleView;
@property(nonatomic,strong) gtVONameV *voNameView;
@property(nonatomic,strong) gtXAxV *xAV;
@property(nonatomic,strong) gtYAxV *yAV;
@property(nonatomic,strong) dpRslt *dpr;
@property(nonatomic,strong) useTrackerController *parentUTC;

//@property (atomic)     int32_t shakeLock;

- (void) yavTap;
- (void) gtvTap:(NSSet *)touches;
- (void) buildView;

@end
