//
//  APPinAnnotation.m
//  OilSavings
//
//  Created by Andi Palo on 8/28/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPinAnnotation.h"

@implementation APPinAnnotation

@synthesize coordinate;

- (id) initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

- (NSString *)subtitle{
    return self.address;
}
- (NSString *)title{
    if (self.type == kAddressSrc) {
        return NSLocalizedString(@"Partenza", @"Pin partenza");
    }else if (self.type == kAddressDst){
        return NSLocalizedString(@"Destinazione", @"Pin destinazione");
    }
    return @"";
}

@end
