/***************
 togd.m
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
//  togd.m
//
//  Tracker Object Graph Data
//
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "togd.h"
#import "valueObj.h"
#import "voState.h"

#import "rTracker-constants.h"
#import "dbg-defs.h"

@implementation togd
@synthesize pto=_pto, rect=_rect, bbox=_bbox, firstDate=_firstDate, lastDate=_lastDate, dateScale=_dateScale, dateScaleInv=_dateScaleInv;

- (id) init {
    return ([self initWithData:nil rect:CGRectZero]);
}

- (id) initWithData:(trackerObj*)pTracker rect:(CGRect) inRect {
    NSString *sql;

    if ((self = [super init])) {
        self.pto = pTracker;
        self.rect = inRect;
        self.bbox = inRect;
       
        sql = @"select max(date) from voData;";
        self.lastDate =  [self.pto toQry2Int:sql];
        
        int gmd = [[self.pto.optDict valueForKey:@"graphMaxDays"] intValue];
        if (0 != gmd) {
            int tFirstDate;
            gmd *= 60*60*24; // secs per day
            tFirstDate = self.lastDate - gmd;
           sql = [NSString stringWithFormat:@"select min(date) from voData where date >= %d;",tFirstDate];
        } else {
           sql = @"select min(date) from voData;";
        }
        self.firstDate = [self.pto toQry2Int:sql];
       sql = nil;
        
        if (self.firstDate == self.lastDate) {
            self.firstDate -= 60*60*24; // secs per day -- single data point so arbitrarily set scale to 1 day
        }
        
        int dateScaleExpand = (int) ((((double) self.lastDate - self.firstDate) * GRAPHSCALE) + d(0.5));
        self.lastDate += dateScaleExpand;
        self.firstDate -= dateScaleExpand;
        
        self.dateScale = d(self.rect.size.width) / (d(self.lastDate) - d(self.firstDate));
        self.dateScaleInv = d(self.lastDate - self.firstDate) / d(self.rect.size.width);
        
    }
    return self;
}

- (void) fillVOGDs {
    for (valueObj *vo in self.pto.valObjTable) {
        id tvogd = [vo.vos newVOGD];
        vo.vogd = tvogd;
        //[vo.vogd release]; // rtm 05 feb 2012  +1 for new (alloc), +1 for vo retain
    }    
}


@end
