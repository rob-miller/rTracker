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

#define MyTracker ((trackerObj*) self.vo.parentTracker)

@interface voState : NSObject <voProtocol> {

	valueObj *vo;
    CGRect voFrame;
    
}

@property (nonatomic,assign) valueObj *vo;
@property (nonatomic) CGRect voFrame;

- (id) init;
- (id) initWithVO:(valueObj*)valo;
- (void) loadConfig;
- (void) setOptDictDflts;
- (BOOL) cleanOptDictDflts:(NSString*)key;

- (UITableViewCell*) voTVEnabledCell:(UITableView *)tableView;
+ (NSArray*) voGraphSetNum;

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

@end
