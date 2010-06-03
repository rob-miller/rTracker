//
//  valueObj.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "valueObj.h"


@implementation valueObj

@synthesize vid;
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

- (id) init :(int)in_vid in_vtype:(int) in_vtype in_vname:(NSString *) in_vname {
	NSLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	vid = in_vid;
	valueType = in_vtype;
	valueName = in_vname;
	[valueName retain];
	return [self init];
}

- (void) dealloc {
	NSLog(@"dealloc valueObj: %@",valueName);
	[super dealloc];
	[valueName release];
	[valueDate release];
	[value release];
}


@end
