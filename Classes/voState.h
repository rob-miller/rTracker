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
#import "rTracker-constants.h"

@interface voState : NSObject <voProtocol> {

	valueObj *vo;
}

@property (nonatomic,assign) valueObj *vo;

- (id) init;
- (id) initWithVO:(valueObj*)valo;
- (void) loadConfig;
- (UITableViewCell*) voTVEnabledCell:(UITableView *)tableView;
+ (NSArray*) voGraphSetNum;

@end
