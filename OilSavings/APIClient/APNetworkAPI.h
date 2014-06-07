//
//  APNetworkAPI.h
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APGasStationClient.h"

@protocol APNetworkAPI <NSObject>

@optional
- (void) convertedAddressType:(ADDRESS_TYPE)type to:(CLLocationCoordinate2D)coord;
- (void) convertedCoordinateType:(ADDRESS_TYPE)type to:(NSString*) address;

- (void) gasStation:(APGasStationClient*)gsClient didFinishWithStations:(BOOL) newStations;



@end
