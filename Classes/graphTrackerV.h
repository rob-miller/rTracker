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


@interface graphTrackerV : UIView {
	trackerObj *tracker;
	int firstDate;
	int lastDate;
    BOOL doDrawGraph;
}

@property(nonatomic,retain) trackerObj *tracker;
@property(nonatomic) int firstDate;
@property(nonatomic) int lastDate;
@property(nonatomic) BOOL doDrawGraph;

// UI element properties 
@property(nonatomic) CGContextRef context;
@property(nonatomic,retain) UIFont *myFont;


@end
