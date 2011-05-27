//
//  voChoice.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"

@interface voChoice : voState {
	configTVObjVC *ctvovcp;
    UISegmentedControl *segmentedControl;
    BOOL processingTfDone;
}

@property (nonatomic,assign) configTVObjVC *ctvovcp;
@property (nonatomic,retain) UISegmentedControl *segmentedControl;
@property (nonatomic) BOOL processingTfDone;

@end
