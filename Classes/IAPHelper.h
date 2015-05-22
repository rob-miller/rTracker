//
//  IAPHelper.h
//  rTracker
//
//  Created by Rob Miller on 09/05/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//

#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end

/*
#import <Foundation/Foundation.h>

@interface IAPHelper : NSObject

@end
*/
