//
//  APGeocodeClient.h
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//


#import <MapKit/MapKit.h>

@protocol ConvertAddressToCoord;

@interface APGeocodeClient : NSObject

+ (void) convertAddress:(NSString*)addr ofType:(ADDRESS_TYPE)type inDelegate:(id<ConvertAddressToCoord>)delegate;
+ (void) convertCoordinate:(CLLocationCoordinate2D)coord ofType:(ADDRESS_TYPE)type inDelegate:(id<ConvertAddressToCoord>)delegate;

@end


@protocol ConvertAddressToCoord
@optional
- (void) convertedAddressType:(ADDRESS_TYPE)type to:(CLLocationCoordinate2D)coord;
- (void) convertedCoordinateType:(ADDRESS_TYPE)type to:(NSString*) address;

@end