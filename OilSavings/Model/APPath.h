//
//  APPath.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APLine.h"
@interface APPath : NSObject

@property (nonatomic) CLLocationCoordinate2D northEast;
@property (nonatomic) CLLocationCoordinate2D southWest;

@property (nonatomic, strong) NSMutableArray *lines;

- (void) addLine:(APLine*) line;
- (CLLocationCoordinate2D) getNorthEastBorder;
- (CLLocationCoordinate2D) getsouthWestBorder;
- (int) getDistance;

@end
