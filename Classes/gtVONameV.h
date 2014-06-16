//
//  gtVONameV.h
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "valueObj.h"

#import "dbg-defs.h"

@interface gtVONameV : UIView
/*{
    valueObj *currVO;
    UIFont *myFont;
    UIColor *voColor;
}*/

@property(nonatomic,strong) valueObj *currVO;
@property(nonatomic,strong) UIFont *myFont;
@property(nonatomic,strong) UIColor *voColor;


@end


