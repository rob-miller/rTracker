//
//  voChoice.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"

@interface voChoice : voState
/*{
	configTVObjVC *ctvovcp;
    UISegmentedControl *segmentedControl;
    BOOL processingTfDone;
    BOOL processingTfvDone;
}*/

@property (nonatomic,unsafe_unretained) configTVObjVC *ctvovcp;
@property (nonatomic,strong) UISegmentedControl *segmentedControl;
@property (nonatomic) BOOL processingTfDone;
@property (nonatomic) BOOL processingTfvDone;

@end
