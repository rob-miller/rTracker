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
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    
    //CGRect contentFrame = view.bounds;
    CGRect contentFrame = vc.view.bounds;
    contentFrame.size = [rTracker_resource get_visible_size:vc];
    
    DBGLog(@"cf x %f y %f  w %f h %f",contentFrame.origin.x,contentFrame.origin.y,contentFrame.size.width,contentFrame.size.height);
    
    /*
    if (contentFrame.size.width < contentFrame.size.height) {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    */
    
    CGRect bannerFrame = self.bannerView.frame;
    DBGLog(@"bf x %f y %f  w %f h %f",bannerFrame.origin.x,bannerFrame.origin.y,bannerFrame.size.width,bannerFrame.size.height);
    if (self.bannerView.bannerLoaded) {
        contentFrame.size.height -= self.bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
        DBGLog(@"banner is loaded");
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    DBGLog(@"cf x %f y %f  w %f h %f",contentFrame.origin.x,contentFrame.origin.y,contentFrame.size.width,contentFrame.size.height);
    DBGLog(@"bf x %f y %f  w %f h %f",bannerFrame.origin.x,bannerFrame.origin.y,bannerFrame.size.width,bannerFrame.size.height);
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
