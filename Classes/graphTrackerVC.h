//
//  graphTracker.h
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"


@interface graphTrackerVC : UIViewController {
	trackerObj *tracker;
}

@property(nonatomic,retain) trackerObj *tracker;

@end
