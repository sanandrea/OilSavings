//
//  APLine.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APLine.h"

@implementation APLine


- (id) initWithDistance:(APDistance*) d andDuration:(APDuration*) t andSrc:(APPosition*) src andDst:(APPosition*)dst andSrcA:(NSString*) srcA andDstA:(NSString*) dstA{
    
    self = [super init];
    
    self.distance = d;
    self.duration = t;
    
    self.srcPos = src;
    self.dstPos = dst;
    
    self.srcAddress = srcA;
    self.dstAddress = dstA;
    
    self.steps = [[NSMutableArray alloc]init];
    
    return self;
}

- (void) addStep:(APStep*) step{
    [self.steps addObject:step];
}

- (float) getVelocity{
    return (float)self.distance.distance / self.duration.duration;
}
@end
