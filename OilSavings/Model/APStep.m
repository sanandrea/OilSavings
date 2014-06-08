//
//  APStep.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APStep.h"

@implementation APStep

- (id) initWithDistance:(APDistance*) d andDuration:(APDuration*) t andSrcPos:(CLLocationCoordinate2D)src andDstPos:(CLLocationCoordinate2D) dst andPoly:(NSString*) poly{
    self = [super init];
    
    if (self) {
        self.stepDuration = t;
        self.stepDistance = d;
        self.srcPos = src;
        self.dstPos = dst;
        self.polyline = poly;
    }
    return self;
}
@end
