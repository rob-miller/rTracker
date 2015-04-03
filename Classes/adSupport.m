//
//  adSupport.m
//  rTracker
//
//  Created by Rob Miller on 02/04/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//

#import "adSupport.h"

@implementation adSupport

@synthesize bannerView=_bannerView;
@synthesize timer=_timer;
@synthesize ticks=_ticks;


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

-(void)layoutAnimated:(UIView*)view tableview:(UITableView*)tableview animated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    
    CGRect contentFrame = view.bounds;
    /*
    if (contentFrame.size.width < contentFrame.size.height) {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    */
    
    CGRect bannerFrame = self.bannerView.frame;
    if (self.bannerView.bannerLoaded) {
        contentFrame.size.height -= self.bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //_contentView.frame = contentFrame;
        //[_contentView layoutIfNeeded];
        tableview.frame = contentFrame;
        [tableview layoutIfNeeded];
        self.bannerView.frame = bannerFrame;
    }];
}


-(void)startTimer
{
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerTick:(NSTimer *)timer
{
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    
    self.ticks += 0.1;
    /*
     double seconds = fmod(_ticks, 60.0);
     double minutes = fmod(trunc(_ticks / 60.0), 60.0);
     double hours = trunc(_ticks / 3600.0);
     self.timerLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
     */
}


@end
