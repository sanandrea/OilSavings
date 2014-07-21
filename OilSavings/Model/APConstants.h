//
//  APConstants.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kDBDowloaded;
extern NSString *const kDBVersion;
extern NSString *const kResVersion;
extern NSString *const kCarsRegistered;
extern NSString *const kPreferredCar;
extern NSString *const kCashAmount;
extern NSString *const GOOGLE_API_KEY;

extern const int REQUEST_BUNDLE;


extern const CLLocationDegrees emptyLocation;
extern const CLLocationCoordinate2D emptyLocationCoordinate;

typedef enum{
    kEnergyGasoline = 0,
    kEnergyDiesel
}ENERGY_TYPE;

typedef enum{
    kAddressSrc,
    kAddressDst
}ADDRESS_TYPE;

typedef enum{
    kSortTime,
    kSortFuel,
    kSortDistance,
    kSortPrice, 
    kSortRandom
}SORT_TYPE;

typedef enum{
    kBrandEdit,
    kModelEdit,
    kFriendlyNameEdit
}EDIT_TYPE;

@interface APConstants : NSObject

+ (float) haversineDistance:(float)latA :(float)latB :(float)longA :(float)longB;
+ (float) deltaLongitude:(float) distanceKm atLat:(float)latitude;
+ (NSString *) getEnergyStringForType:(ENERGY_TYPE)t;

@end
