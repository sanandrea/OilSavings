//
//  APPath.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPath.h"

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

- (NSComparisonResult)compareAir:(APPath*)inObject{
    if (self.haversineDistance < inObject.haversineDistance) {
        return NSOrderedAscending;
    }else if (self.haversineDistance > inObject.haversineDistance){
        return NSOrderedDescending;
    }else{
        return NSOrderedSame;
    }
}

- (NSComparisonResult)comparePath:(APPath*)inObject{
    //TODO
    return NSOrderedDescending;
}
@end
