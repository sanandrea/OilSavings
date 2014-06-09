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
        ALog("initing");
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
            ALog("lat is %f and lng is %f",step.srcPos.latitude,step.srcPos.longitude);
        }
        coords[index++] = line.dstPos;
        line.polyline = [MKPolyline polylineWithCoordinates:coords count:index];
        
        //don't forget to free
        free(coords);
    }
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

- (NSComparisonResult)comparePath:(APPath*)inObject{
    //TODO
    return NSOrderedSame;
}


@end
