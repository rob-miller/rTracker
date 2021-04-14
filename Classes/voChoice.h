/***************
 voChoice.h
 Copyright 2010-2021 Robert T. Miller
 
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
