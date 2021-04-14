/***************
 dpRslt.m
 Copyright 2011-2021 Robert T. Miller
 
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
//  dpRslt.m
//  rTracker
//
//  Created by Rob Miller on 18/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "dpRslt.h"


@implementation dpRslt

@synthesize date=_date,action=_action;

- (id) init {
    if ((self = [super init])) {
        _action=DPA_CANCEL;
    }
    return self;
}

@end
