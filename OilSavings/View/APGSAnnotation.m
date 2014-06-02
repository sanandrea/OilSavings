//
//  APGSAnnotation.m
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APGSAnnotation.h"

@implementation APGSAnnotation

@synthesize coordinate;

- (id) initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

- (NSString *)subtitle{
    return @"1,730";
}
- (NSString *)title{
    return self.gasStation.name;
}
@end
