//
//  APPath.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPath.h"

@interface APPath()

@property (nonatomic) float pathFuelExpense;
@end

@implementation APPath

- (id) initWith:(CLLocationCoordinate2D)source and:(CLLocationCoordinate2D)destination andGasStation:(APGasStation*)gs{
    self = [self initWith:source andGasStation:gs];
    
    if (self) {
        self.dst = destination;
        self .hasDestination = YES;
        self.haversineDistance += [APConstants haversineDistance:self.dst.latitude :gs.position.latitude :self.dst.longitude :gs.position.longitude];
    }
    return self;
}
- (id) initWith:(CLLocationCoordinate2D)source andGasStation:(APGasStation*)gs{
    self = [super init];
    
    if (self) {
        self.lines = [[NSMutableArray alloc] init];
        self.src = source;
        self.hasDestination = NO;
        self.gasStation = gs;
        self.dst = gs.position;
        self.haversineDistance = [APConstants haversineDistance:self.src.latitude :gs.position.latitude :self.src.longitude :gs.position.longitude];
    }
    return self;
}

- (void) addLine:(APLine*) line;{
    [self.lines addObject:line];
}

- (int) getDistance{
    int distance = 0;
    for (APLine* ll in self.lines) {
        distance += ll.distance.distance;
    }
    return distance;
}

- (void) constructMKPolyLines{
    for (APLine *line in self.lines) {
        
        //add all src positions of steps then add the destination position
        CLLocationCoordinate2D *coords = calloc([line.steps count] + 1, sizeof(CLLocationCoordinate2D));
        int index = 0;
        
        for (APStep *step in line.steps) {
            coords[index++] = step.srcPos;
//            ALog("lat is %f and lng is %f",step.srcPos.latitude,step.srcPos.longitude);
        }
        coords[index++] = line.dstPos;
        line.polyline = [MKPolyline polylineWithCoordinates:coords count:index];
        
        //don't forget to free
        free(coords);
    }
}

- (void) calculatePathValueWithCar:(APCar*)car{
    float expense = 0;
    for (APLine *line in self.lines) {
        for (APStep *step in line.steps) {
            expense += [self calculateExpense:[step getVelocity] forDistance:step.stepDistance withCar:car];
        }
    }
    self.pathFuelExpense = expense;
}

- (float) calculateExpense:(float)velocity forDistance:(APDistance *)distance withCar:(APCar*)car{
    //FC = a/v + b + cv + dv^2
    if (velocity < 0.1) {
        velocity = 1;
    }
    
    float velocityKmPH = velocity * 3.6f;
    float distanceIn100Km = distance.distance / 100000;
    float expenseIn100Km = [car.pA integerValue]/ velocityKmPH + [car.pB integerValue] + [car.pC integerValue] * velocityKmPH + [car.pD integerValue] * velocityKmPH * velocityKmPH;
    return expenseIn100Km * distanceIn100Km;
}

- (NSComparisonResult)compareAir:(APPath*)inObject{
    if (self.haversineDistance * [self.gasStation getPrice] < inObject.haversineDistance * [inObject.gasStation getPrice]) {
        return NSOrderedAscending;
    }else if (self.haversineDistance * [self.gasStation getPrice]> inObject.haversineDistance * [inObject.gasStation getPrice]){
        return NSOrderedDescending;
    }else{
        return NSOrderedSame;
    }
}

- (NSComparisonResult)comparePath:(APPath*)inObject andImport:(NSInteger)import{
    float myRemaining = import/self.gasStation.getPrice - self.pathFuelExpense;
    float otherRemaining = import/inObject.gasStation.getPrice - inObject.pathFuelExpense;
    
    if (myRemaining < otherRemaining) {
        return NSOrderedDescending;
    }else if (myRemaining > otherRemaining){
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}


@end
