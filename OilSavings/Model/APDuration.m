//
//  APDuration.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APDuration.h"


@implementation APDuration

- (id) initWithDuration:(int) t andText:(NSString*) someText{
    self = [super init];
    self.duration = t;
    self.text = someText;
    return self;
}

@end