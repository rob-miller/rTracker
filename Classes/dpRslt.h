//
//  dpRslt.h
//  rTracker
//
//  Created by Rob Miller on 18/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DPA_CANCEL		0
#define DPA_NEW			1
#define DPA_SET			2
#define DPA_GOTO		3


@interface dpRslt : NSObject {
	NSDate *date;
	NSInteger action;
}

@property (nonatomic,retain) NSDate *date;
@property (nonatomic) NSInteger action;

@end
