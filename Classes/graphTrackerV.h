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
}

@property(nonatomic,retain) trackerObj *tracker;
@property(nonatomic) CGContextRef context;
@property(nonatomic) int firstDate;
@property(nonatomic) int lastDate;


@end
