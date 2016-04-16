/***************
 togd.h
 Copyright 2011-2016 Robert T. Miller
 
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
//  togd.h
//
//  Tracker Object Graph Data
//
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "trackerObj.h"

@interface togd : NSObject
/*{
    trackerObj *pto;
    CGRect rect;
    CGRect bbox;
	int firstDate;
	int lastDate;
    double dateScale;
    double dateScaleInv;
}*/

@property(nonatomic,strong) trackerObj *pto;
@property(nonatomic) CGRect rect;
@property(nonatomic) CGRect bbox;
@property(nonatomic) int firstDate;
@property(nonatomic) int lastDate;
@property(nonatomic) double dateScale;
@property(nonatomic) double dateScaleInv;

- (id) initWithData:(trackerObj*)pTracker rect:(CGRect) inRect;
- (void) fillVOGDs;

@end
