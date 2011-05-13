//
//  togd.h
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "trackerObj.h"

@interface togd : NSObject {
    trackerObj *pto;
    CGRect rect;
	int firstDate;
	int lastDate;
    double dateScale;
}

@property(nonatomic,retain) trackerObj *pto;
@property(nonatomic) CGRect rect;
@property(nonatomic) int firstDate;
@property(nonatomic) int lastDate;
@property(nonatomic) double dateScale;

- (id) initWithData:(trackerObj*)pTracker rect:(CGRect) inRect;
- (void) fillVOGDs;

@end
