//
//  APGasStationClient.h
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol APNetworkAPI;

@interface APGasStationClient : NSObject

@property (nonatomic) double minLat;
@property (nonatomic) double maxLat;
@property (nonatomic) double minLong;
@property (nonatomic) double maxLong;

@property (nonatomic) ENERGY_TYPE fuel;
@property (nonatomic, strong) NSMutableArray* gasStations;

@property (nonatomic, weak) id <APNetworkAPI> delegate;


- (id) initWithCenter:(CLLocationCoordinate2D) center andFuel:(ENERGY_TYPE) fuel;
- (void)getStations;

@end
