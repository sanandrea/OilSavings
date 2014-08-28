//
//  APPinAnnotation.h
//  OilSavings
//
//  Created by Andi Palo on 8/28/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface APPinAnnotation : NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic) ADDRESS_TYPE type;
@property (nonatomic, strong) NSString *address;

- (id) initWithLocation:(CLLocationCoordinate2D)coord;

@end
