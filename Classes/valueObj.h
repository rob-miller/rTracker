//
//  valueObj.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define VOT_NUMBER	0
#define VOT_TEXT	1
#define VOT_SLIDER	2
#define VOT_PICK	3
#define VOT_BOOLEAN	4
#define VOT_IMAGE	5
#define VOT_FUNC	6

#define VOT_MAX		7


@interface valueObj : NSObject <UITextFieldDelegate> {
	NSInteger vid;
	NSInteger vtype;
	NSString *valueName;
	NSDate *valueDate;
	NSString *value;
	NSArray *votArray;
	UIView *display;
}

//+ (NSArray *) votArray;

@property (nonatomic) NSInteger vid;
@property (nonatomic) NSInteger vtype;
@property (nonatomic,retain) NSString *valueName;
@property (nonatomic,retain) NSDate *valueDate;
@property (nonatomic,retain) NSString *value;
@property (nonatomic, retain) NSArray *votArray;
@property (nonatomic, retain) UIView *display;

- (id) init;
- (void) dealloc;
- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname;

- (void) describe;

//- (void) txtDTF:(BOOL)num;

@end
