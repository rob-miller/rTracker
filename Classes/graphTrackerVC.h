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

#import "gtTitleV.h"
#import "gtVONameV.h"
#import "gtXAxV.h"
#import "gtYAxV.h"


@interface graphTrackerVC : UIViewController <UIScrollViewDelegate> {
	trackerObj *tracker;
    valueObj *currVO;
    UIFont *myFont;
    
    UIScrollView *scrollView;
    graphTrackerV *gtv;
    gtTitleV *titleView;
    gtVONameV *voNameView;
    gtXAxV *xAV;
    gtYAxV *yAV;
}

@property(nonatomic,retain) trackerObj *tracker;
@property(nonatomic,retain) valueObj *currVO;

@property(nonatomic,retain) UIFont *myFont;

@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) graphTrackerV *gtv;
@property(nonatomic,retain) gtTitleV *titleView;
@property(nonatomic,retain) gtVONameV *voNameView;
@property(nonatomic,retain) gtXAxV *xAV;
@property(nonatomic,retain) gtYAxV *yAV;

@end
