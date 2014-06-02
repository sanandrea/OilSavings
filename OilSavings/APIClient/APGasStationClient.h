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


@protocol GasStationsHandler;

@interface APGasStationClient : NSObject

@property (nonatomic) double minLat;
@property (nonatomic) double maxLat;
@property (nonatomic) double minLong;
@property (nonatomic) double maxLong;

@property (nonatomic, strong) NSString *fuel;
@property (nonatomic, strong) NSMutableArray* gasStations;

@property (nonatomic, weak) id <GasStationsHandler> delegate;


- (id) initWithRegion:(MKCoordinateRegion) region andFuel:(NSString*) fuel;
- (void)getStations;

@end

@protocol GasStationsHandler

- (void) gasStation:(APGasStationClient*)gsClient didFinishWithStations:(BOOL) newStations;

@end