//
//  rt_IAPHelper.h
//  rTracker
//
//  Created by Rob Miller on 09/05/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//
// original source: http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
//

#import "IAPHelper.h"
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface rt_IAPHelper : IAPHelper

+ (rt_IAPHelper *)sharedInstance;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

@end
