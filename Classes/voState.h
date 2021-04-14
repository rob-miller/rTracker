/***************
 voState.h
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
//  voState.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "valueObj.h"
#import "trackerObj.h"
#import "configTVObjVC.h"
#import "vogd.h"

#import "rTracker-constants.h"

#define MyTracker ((trackerObj*) self.vo.parentTracker)

@interface voState : NSObject <voProtocol>
/*{

	valueObj *vo;
    CGRect vosFrame;
    
}*/

@property (nonatomic,unsafe_unretained) valueObj *vo;
@property (nonatomic) CGRect vosFrame;
@property (nonatomic,weak) UIViewController *vc;

- (id) init;
- (id) initWithVO:(valueObj*)valo;
- (void) loadConfig;
- (void) setOptDictDflts;
- (BOOL) cleanOptDictDflts:(NSString*)key;

- (UITableViewCell*) voTVEnabledCell:(UITableView *)tableView;
+ (NSArray*) voGraphSetNum;
/*
- (void) transformVO_num:(NSMutableArray *)xdat 
                    ydat:(NSMutableArray *)ydat 
                  dscale:(double)dscale 
                  height:(CGFloat)height 
                  border:(float)border 
               firstDate:(int)firstDate;

- (void) transformVO_note:(NSMutableArray *)xdat 
                    ydat:(NSMutableArray *)ydat 
                  dscale:(double)dscale 
                  height:(CGFloat)height 
                  border:(float)border 
               firstDate:(int)firstDate;

- (void) transformVO_bool:(NSMutableArray *)xdat 
                    ydat:(NSMutableArray *)ydat 
                  dscale:(double)dscale 
                  height:(CGFloat)height 
                  border:(float)border 
               firstDate:(int)firstDate;
*/

@end
