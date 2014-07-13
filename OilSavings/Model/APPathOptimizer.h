//
//  APPathOptimizer.h
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APCar.h"
#import "APNetworkAPI.h"

@interface APPathOptimizer : NSObject <APNetworkAPI>


@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) APCar *car;
@property (nonatomic, weak) id<APNetworkAPI> delegate;
@property (nonatomic) NSInteger cashAmount;

@property (nonatomic) CLLocationCoordinate2D src;
@property (nonatomic) CLLocationCoordinate2D dst;
@property (nonatomic) BOOL hasDest;
@property (nonatomic) NSInteger currentBatch;

- (id) initWithCar:(APCar*) mycar cash:(NSInteger)import andDelegate:(id<APNetworkAPI>)dele;
- (void) changeCar:(APCar*)car;

- (void) optimizeRouteFrom:(CLLocationCoordinate2D)src
                        to:(CLLocationCoordinate2D)dst
           withGasStations:(NSArray*)gasStations;

@end