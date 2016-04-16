/***************
 IAHelper.m
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
//  IAPHelper.m
//  rTracker
//
//  Created by Rob Miller on 09/05/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "dbg-defs.h"
//#import "rTracker-resource.h"

@implementation IAPHelper {
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                DBGLog(@"Previously purchased: %@", productIdentifier);
                //[rTracker_resource alert:@"Previously Purchased" msg:@"Previous rTracker purchase found." vc:nil];
            } else {
                DBGLog(@"Not purchased: %@", productIdentifier);
                //[rTracker_resource alert:@"Not Previously Purchased" msg:@"No previous rTracker purchase found." vc:nil];
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self]; 
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    DBGLog(@"rpwch");
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    DBGLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    
#if DEBUGLOG
    for (SKProduct * skProduct in skProducts) {
        DBGLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
#endif

    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    DBGLog(@"Failed to load list of products.");
    //[rTracker_resource alert:@"Connection failure" msg:@"Failed to load list of available products." vc:nil];
    
    _productsRequest = nil;
    
    if (_completionHandler) {  // can be nil already if user repeatedly presses button on timeout
        _completionHandler(NO, nil);
    }
    _completionHandler = nil;
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    DBGLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    DBGLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    DBGLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreCompletedTransactions {
    DBGLog(@"restore completed Transactions...");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    DBGLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        DBGLog(@"Transaction error: %@", transaction.error.localizedDescription);
        //[rTracker_resource alert:@"In-App Purchase Transaction Failed" msg:[@"Transaction error: " stringByAppendingString:transaction.error.localizedDescription] vc:nil];
        
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}


@end
