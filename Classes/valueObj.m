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
@synthesize valueType;
@synthesize valueDate;
@synthesize value;


+ (NSArray *) votArray {
	NSString *votS[VOT_MAX];
	votS[VOT_NUMBER] = @"number";
	votS[VOT_SLIDER] = @"slider";
	votS[VOT_TEXT] = @"text";
	votS[VOT_PICK] = @"multiple choice";
	votS[VOT_BOOLEAN] = @"yes/no";
	votS[VOT_IMAGE] = @"image";
	votS[VOT_FUNC] = @"function";
	
	static NSArray *votA = nil;
	
	if (votA == nil) {
		votA = [[NSArray arrayWithObjects:votS count:VOT_MAX] retain];
	}
	
	return votA;
}


- (id) init {
	NSLog(@"init valueObj: %@", valueName);
	if (self = [super init]) {
		valueDate = [[NSDate alloc] init];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc valueObj: %@",valueName);
	[super dealloc];
	[valueName release];
	//[valueType release];
	[valueDate release];
	//[value release];
}


@end
