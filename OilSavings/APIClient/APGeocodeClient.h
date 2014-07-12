//
//  APGeocodeClient.h
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//


#import <MapKit/MapKit.h>
#import "APNetworkAPI.h"

@interface APGeocodeClient : NSObject

+ (void) convertAddress:(NSString*)addr ofType:(ADDRESS_TYPE)type inDelegate:(id<APNetworkAPI>)delegate;
+ (void) convertCoordinate:(CLLocationCoordinate2D)coord ofType:(ADDRESS_TYPE)type inDelegate:(id<APNetworkAPI>)delegate;

//Block argument to play with
+ (void) convertCoordinate:(CLLocationCoordinate2D)coord found:(void (^)(NSString*, NSString*))found;
@end
