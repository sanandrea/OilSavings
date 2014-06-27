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
#import "APCar.h"

@interface APPath : NSObject

@property (nonatomic) CLLocationCoordinate2D dst;
@property (nonatomic) CLLocationCoordinate2D src;

@property (nonatomic) CLLocationCoordinate2D northEastBound;
@property (nonatomic) CLLocationCoordinate2D southWestBound;

@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) APGasStation *gasStation;
@property (nonatomic) BOOL hasDestination;
@property (nonatomic, strong) MKPolyline *overallPolyline;
@property (nonatomic, strong) APCar *car;
@property (nonatomic) NSUInteger import;
//Distance of GasStation from Source plus Distance of GasStation to Destination
@property (nonatomic) float haversineDistance;

- (void) addLine:(APLine*) line;

- (int) getDistance;
- (int) getTime;
- (float) getFuelExpense;

- (void) setTheCar:(APCar*)car;
- (void) setTheImport:(NSUInteger)im;

- (id) initWith:(CLLocationCoordinate2D)source andGasStation:(APGasStation*)gs;
- (id) initWith:(CLLocationCoordinate2D)source and:(CLLocationCoordinate2D)destination andGasStation:(APGasStation*)gs;

- (void) constructMKPolyLines;

//no need to expose this
//- (void) calculatePathValueWithCar:(APCar*)car;

- (NSComparisonResult)compareAir:(APPath*)inObject;

- (NSComparisonResult)compareFuelPath:(APPath*)inObject;
- (NSComparisonResult)compareTimePath:(APPath*)inObject;
- (NSComparisonResult)compareDistancePath:(APPath*)inObject;
- (NSComparisonResult)comparePricePath:(APPath*)inObject;
@end
