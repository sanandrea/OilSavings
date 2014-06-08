//
//  APDirectionsClient.m
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APDirectionsClient.h"

static NSString * const DIRECTIONS_URL = @"http://maps.googleapis.com/maps/api/directions/json";

@implementation APDirectionsClient

- (void) findDirectionsFrom:(CLLocationCoordinate2D)src
                         to:(CLLocationCoordinate2D)dst
             passingThrough:(CLLocationCoordinate2D)waypoint
                 delegateTo:(id<APNetworkAPI>)delegate{
    //Begin here
}

@end
