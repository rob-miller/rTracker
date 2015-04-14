//
//  adSupport.h
//  rTracker
//
//  Created by Rob Miller on 02/04/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface adSupport : NSObject

@property (nonatomic,strong) ADBannerView *bannerView;

-(void)initBannerView:(id< ADBannerViewDelegate >)delegate;
-(void)layoutAnimated:(UIViewController*)vc tableview:(UITableView*)tableview animated:(BOOL)animated;

@end
