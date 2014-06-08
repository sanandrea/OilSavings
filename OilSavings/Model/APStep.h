//
//  APStep.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APDistance.h"
#import "APDuration.h"

@interface APStep : NSObject

@property (nonatomic, strong) APDuration *stepDuration;
@property (nonatomic, strong) APDistance *stepDistance;

@property (nonatomic) CLLocationCoordinate2D srcPos;
@property (nonatomic) CLLocationCoordinate2D dstPos;

@property (nonatomic, strong) NSString *polyline;


- (id) initWithDistance:(APDistance*) d andDuration:(APDuration*) t andSrcPos:(CLLocationCoordinate2D)src andDstPos:(CLLocationCoordinate2D) dst andPoly:(NSString*) poly;
@end
