//
//  toReminder.m
//  rTracker
//
//  Created by Rob Miller on 07/08/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import "toReminder.h"

#define MONFLAG ((unsigned int) 0x1<<0)
#define TUEFLAG ((unsigned int) 0x1<<1)
#define WEDFLAG ((unsigned int) 0x1<<2)
#define THUFLAG ((unsigned int) 0x1<<3)
#define FRIFLAG ((unsigned int) 0x1<<4)
#define SATFLAG ((unsigned int) 0x1<<5)
#define SUNFLAG ((unsigned int) 0x1<<6)

#define RANDOMFLAG ((unsigned int) 0x1<<7)
#define BOUNDFLAG  ((unsigned int) 0x1<<8)

@implementation toReminder
{
    unsigned int    flags;
    
}
@end
