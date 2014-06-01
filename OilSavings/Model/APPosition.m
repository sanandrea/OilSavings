//
//  APPosition.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPosition.h"

@implementation APPosition

- (id) initWithLat:(double)lat andLong:(double)aLong{
    self = [super init];
    self.latitude = lat;
    self.longitude = aLong;
    
    return self;
}

@end
