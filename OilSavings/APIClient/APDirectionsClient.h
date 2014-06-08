//
//  APDirectionsClient.h
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNetworkAPI.h"

@interface APDirectionsClient : NSObject


- (void) findDirectionsFrom:(CLLocationCoordinate2D)src
                         to:(CLLocationCoordinate2D)dst
             passingThrough:(CLLocationCoordinate2D)waypoint
                 delegateTo:(id<APNetworkAPI>)delegate;


@end
