//
//  gtTitleV.h
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "trackerObj.h"
#import "dbg-defs.h"

@interface gtTitleV : UIView
/*{
    trackerObj *tracker;
    UIFont *myFont;    
}*/

@property (nonatomic,strong) trackerObj *tracker;
// UI element properties 
@property(nonatomic,strong) UIFont *myFont;

@end
