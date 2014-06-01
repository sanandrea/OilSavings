//
//  APPath.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPath.h"

@implementation APPath

- (id) initWithNEBorder:(APPosition*)ne andSWBorder:(APPosition*)sw{
    self = [super init];
    
    self.southWest = sw;
    self.northEast = ne;
    self.lines = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) addLine:(APLine*) line;{
    [self.lines addObject:line];
}

- (APPosition*) getNorthEastBorder{
    return self.northEast;
}
- (APPosition*) getsouthWestBorder{
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
