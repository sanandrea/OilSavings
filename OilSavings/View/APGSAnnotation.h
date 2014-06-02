//
//  APGSAnnotation.h
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APGasStation.h"

@interface APGSAnnotation : NSObject <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *price;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) APGasStation* gasStation;

- (id) initWithLocation:(CLLocationCoordinate2D)coord;
- (NSString *)subtitle;
- (NSString *)title;

@end
