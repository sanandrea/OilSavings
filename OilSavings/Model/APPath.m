//
//  APPath.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPath.h"

@implementation APPath

- (id) initWithNEBorder:(CLLocationCoordinate2D)ne andSWBorder:(CLLocationCoordinate2D)sw{
    self = [super init];
    
    self.southWest = sw;
    self.northEast = ne;
    self.lines = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) addLine:(APLine*) line;{
    [self.lines addObject:line];
}

- (CLLocationCoordinate2D) getNorthEastBorder{
    return self.northEast;
}
- (CLLocationCoordinate2D) getsouthWestBorder{
    return self.southWest;
}
- (int) getDistance{
    int distance = 0;
    for (APLine* ll in self.lines) {
        distance += ll.distance.distance;
    }
    return distance;
}

@end
