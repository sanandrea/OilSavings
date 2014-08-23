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
@property (nonatomic) float pathFuelRemaining;
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

- (int) getTime{
    int time = 0;
    for (APLine *ll in self.lines) {
        time += ll.duration.duration;
    }
    return time;
}


- (float) getFuelExpense{
    return self.pathFuelRemaining;
}

- (void) setTheCar:(APCar*)aCar{
    self.car = aCar;
    //calculate expenses with current car
    [self calculatePathValueWithCar:self.car];
}

- (void) setTheImport:(NSUInteger)im{
    self.import = im;
    self.pathFuelRemaining = self.import/self.gasStation.getPrice - self.pathFuelExpense;
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
    //ALog("Distanze is %d and expense is %f", [self getDistance], self.pathFuelExpense);
}


- (float) calculatePathValueForEnergyType:(ENERGY_TYPE)eType{
    float expense = 0;
    for (APLine *line in self.lines) {
        for (APStep *step in line.steps) {
            
            expense += [self calculateExpense:[step getVelocity] forDistance:step.stepDistance withCar:self.car];
        }
    }
    ALog("Expense is %f",expense);
    return ((float)self.import)/[self.gasStation getPrice:eType] - expense;
}
- (float) calculateExpense:(float)velocity forDistance:(APDistance *)distance withCar:(APCar*)car{
    //FC = a/v + b + cv + dv^2
    if (velocity < 0.1) {
        velocity = 1;
    }
    
    float velocityKmPH = velocity * 3.6f;
    float distanceIn100Km = (float)distance.distance / 100000;
    float expenseIn100Km = (float)[car.pA integerValue]/ velocityKmPH + [car.pB integerValue] + [car.pC integerValue] * velocityKmPH + [car.pD integerValue] * velocityKmPH * velocityKmPH;
//    ALog("Expense in 100Km is: %f",expenseIn100Km);
//    ALog("Distance in 100Km is: %f",distanceIn100Km);
    
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

- (NSComparisonResult)comparePath:(APPath*)inObject byType:(SORT_TYPE)sortType{
    float myValue;
    float otherValue;
    BOOL minIsBetter = YES;
    
    switch (sortType) {
        case kSortDistance:
            myValue = [self getDistance];
            otherValue = [inObject getDistance];
            break;
        case kSortTime:
            myValue = [self getTime];
            otherValue = [inObject getTime];
            break;
        case kSortPrice:
            myValue = [self.gasStation getPrice];
            otherValue = [inObject.gasStation getPrice];
            break;
        case kSortFuel:
            myValue = self.pathFuelRemaining;
            otherValue = inObject.pathFuelRemaining;
            minIsBetter = NO;
            break;
        case kSortRandom:
            
        default:
            myValue = 0;
            otherValue = 0;
            break;
    }
    
    if (inObject == nil) {
        return NSOrderedAscending;
    }
    
    
    if (myValue < otherValue) {
        if (minIsBetter) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }else if (myValue > otherValue){
        if (minIsBetter) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}


- (NSComparisonResult)compareFuelPath:(APPath*)inObject{
    return [self comparePath:inObject byType:kSortFuel];
}
- (NSComparisonResult)compareTimePath:(APPath*)inObject{
        return [self comparePath:inObject byType:kSortTime];
}
- (NSComparisonResult)compareDistancePath:(APPath*)inObject{
        return [self comparePath:inObject byType:kSortDistance];
}
- (NSComparisonResult)comparePricePath:(APPath*)inObject{
        return [self comparePath:inObject byType:kSortPrice];
}


@end
