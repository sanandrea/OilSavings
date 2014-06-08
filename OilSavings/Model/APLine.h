//
//  APLine.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "APDistance.h"
#import "APDuration.h"
#import "APStep.h"

@interface APLine : NSObject

@property (nonatomic, strong) APDuration *duration;
@property (nonatomic, strong) APDistance *distance;

@property (nonatomic) CLLocationCoordinate2D srcPos;
@property (nonatomic) CLLocationCoordinate2D dstPos;

@property (nonatomic, strong) MKPolyline *polyline;

@property (nonatomic, strong) NSString *srcAddress;
@property (nonatomic, strong) NSString *dstAddress;

@property (nonatomic, strong) NSMutableArray *steps;

- (void) addStep:(APStep*) step;
- (float) getVelocity;
- (id) initWithDistance:(APDistance*) d andDuration:(APDuration*) t andSrc:(CLLocationCoordinate2D) src andDst:(CLLocationCoordinate2D)dst;
@end
