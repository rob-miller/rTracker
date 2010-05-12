//
//  valueObj.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "valueObj.h"


@implementation valueObj

@synthesize valueName;

- (id) init {
	NSLog(@"init valueObj: %@", valueName);
	if (self = [super init]) {
	}
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc valueObj: %@",valueName);
	[super dealloc];
	[valueName release];
}


@end
