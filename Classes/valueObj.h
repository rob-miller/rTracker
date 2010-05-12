//
//  valueObj.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface valueObj : NSObject {
	NSString *valueName;
}
@property (nonatomic,retain) NSString *valueName;

- (id) init;
- (void) dealloc;

@end
