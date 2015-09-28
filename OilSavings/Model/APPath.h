// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
@property (nonatomic, strong) MKPolyline *secondaryPolyline;
@property (nonatomic, strong) APCar *car;
@property (nonatomic) NSUInteger import;

@property (nonatomic) float savingRespectCheapest;
@property (nonatomic) float savingRespectNearest;

//Distance of GasStation from Source plus Distance of GasStation to Destination
@property (nonatomic) float haversineDistance;

- (void) addLineToPath:(APLine*) line;
#ifndef USE_IOS_MAPS
- (void) constructMKPolyLines;
#endif

- (int) getDistance;
- (int) getTime;

- (void) setNewDistance:(int)newDistance;
- (void) setNewTime:(int)newTime;

- (float) getFuelExpense;

- (void) setTheCar:(APCar*)car;
- (void) setTheImport:(NSUInteger)im;

- (id) initWith:(CLLocationCoordinate2D)source andGasStation:(APGasStation*)gs;
- (id) initWith:(CLLocationCoordinate2D)source and:(CLLocationCoordinate2D)destination andGasStation:(APGasStation*)gs;

- (float) calculatePathValueForEnergyType:(ENERGY_TYPE)eType;

//no need to expose this
//- (void) calculatePathValueWithCar:(APCar*)car;

- (NSComparisonResult)compareAir:(APPath*)inObject;

- (NSComparisonResult)compareFuelPath:(APPath*)inObject;
- (NSComparisonResult)compareTimePath:(APPath*)inObject;
- (NSComparisonResult)compareDistancePath:(APPath*)inObject;
- (NSComparisonResult)comparePricePath:(APPath*)inObject;

- (float) compareSavingTo:(APPath*)other;
@end
