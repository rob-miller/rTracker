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


@interface graphTrackerV : UIScrollView {
	trackerObj *tracker;
    BOOL doDrawGraph;
}

@property(nonatomic,retain) trackerObj *tracker;
@property(nonatomic) BOOL doDrawGraph;

//- (void)setTransform:(CGAffineTransform)newValue;

@end
