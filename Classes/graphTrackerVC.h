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

@property (atomic)     int32_t shakeLock;

- (void) yavTap;
- (void) gtvTap:(NSSet *)touches;
- (void) buildView;

@end
