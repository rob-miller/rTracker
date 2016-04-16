/***************
 adsupport.m
 Copyright 2015-2016 Robert T. Miller
 
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
//  adSupport.m
//  rTracker
//
//  Created by Rob Miller on 02/04/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//

#import "adSupport.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation adSupport

@synthesize bannerView=_bannerView;

-(ADBannerView*) bannerView
{
    if (_bannerView == nil) {
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _bannerView = [[ADBannerView alloc] init];
        }
    }
    return _bannerView;
}
-(void)initBannerView:(id< ADBannerViewDelegate >)delegate
{
    self.bannerView.delegate = delegate;
}

-(void)layoutAnimated:(UIViewController*)vc tableview:(UITableView*)tableview animated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    
    //CGRect contentFrame = view.bounds;
    CGRect contentFrame = vc.view.bounds;
    contentFrame.size = [rTracker_resource get_visible_size:vc];
    CGRect bannerFrame = self.bannerView.frame;
    
    DBGLog(@"in: cf x %f y %f  w %f h %f",contentFrame.origin.x,contentFrame.origin.y,contentFrame.size.width,contentFrame.size.height);
    DBGLog(@"in: bf x %f y %f  w %f h %f",bannerFrame.origin.x,bannerFrame.origin.y,bannerFrame.size.width,bannerFrame.size.height);

    if (self.bannerView.bannerLoaded) {
        contentFrame.size.height -= self.bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
        DBGLog(@"banner is loaded");
    } else {
        DBGLog(@"banner not loaded");
        bannerFrame.origin.y = contentFrame.size.height;
    }
    DBGLog(@"out: cf x %f y %f  w %f h %f",contentFrame.origin.x,contentFrame.origin.y,contentFrame.size.width,contentFrame.size.height);
    DBGLog(@"out: bf x %f y %f  w %f h %f",bannerFrame.origin.x,bannerFrame.origin.y,bannerFrame.size.width,bannerFrame.size.height);
    //DBGLog(@"foo");
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //_contentView.frame = contentFrame;
        //[_contentView layoutIfNeeded];
        tableview.frame = contentFrame;
        [tableview layoutIfNeeded];
        self.bannerView.frame = bannerFrame;
    }];
}

@end
