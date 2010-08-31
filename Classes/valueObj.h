//
//  valueObj.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>


#define VOT_NUMBER	0
#define VOT_SLIDER	1
#define VOT_TEXT	2
#define VOT_PICK	3
#define VOT_BOOLEAN	4
#define VOT_IMAGE	5
#define VOT_FUNC	6

#define VOT_MAX		7


@interface valueObj : NSObject {
	NSInteger vid;
	NSInteger vtype;
	NSString *valueName;
	NSDate *valueDate;
	NSString *value;
}
@property (nonatomic) NSInteger vid;
@property (nonatomic) NSInteger vtype;
@property (nonatomic,retain) NSString *valueName;
@property (nonatomic,retain) NSDate *valueDate;
@property (nonatomic,retain) NSString *value;

+ (NSArray *) votArray;

- (id) init;
- (void) dealloc;
- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname;



@end
