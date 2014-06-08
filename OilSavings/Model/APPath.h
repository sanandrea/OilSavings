//
//  APPath.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APGasStation.h"
#import "APLine.h"

@interface APPath : NSObject

@property (nonatomic) CLLocationCoordinate2D dst;
@property (nonatomic) CLLocationCoordinate2D src;

@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) APGasStation *gasStation;
@property (nonatomic) BOOL hasDestination;

//Distance of GasStation from Source plus Distance of GasStation to Destination
@property (nonatomic) float haversineDistance;

- (void) addLine:(APLine*) line;

- (int) getDistance;

- (id) initWith:(CLLocationCoordinate2D)source andGasStation:(APGasStation*)gs;
- (id) initWith:(CLLocationCoordinate2D)source and:(CLLocationCoordinate2D)destination andGasStation:(APGasStation*)gs;

- (NSComparisonResult)compareAir:(APPath*)inObject;
- (NSComparisonResult)comparePath:(APPath*)inObject;
@end
