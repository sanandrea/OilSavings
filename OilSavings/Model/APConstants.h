// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  APConstants.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#define USE_IOS_MAPS 1

extern NSString *const kDBDowloaded;
extern NSString *const kDBVersion;
extern NSString *const kResVersion;
extern NSString *const kCarsRegistered;
extern NSString *const kPreferredCar;
extern NSString *const kCashAmount;
extern NSString *const GOOGLE_API_KEY;
extern NSString *const kDefaultTankCapacity;
extern NSString *const kAdUnitID;
extern NSString *const kTrackingID;

//how much directions requests to wait before updating polyline of best path.
extern const int REQUEST_BUNDLE;
//Number of energy types
extern const int ENERGIES_COUNT;

extern const int kDEBUG;



extern const CLLocationDegrees emptyLocation;
extern const CLLocationCoordinate2D emptyLocationCoordinate;

typedef enum{
    kEnergyGasoline = 0,
    kEnergyDiesel,
    kEnergyMethan,
    kEnergyGPL,
    kEnergyGasolineSP,
    kEnergyDieselSP,
    kEnergyUnknown
}ENERGY_TYPE;

typedef enum{
    kAddressSrc,
    kAddressDst,
    kAddressULocation
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
+ (NSString *) getEnergyLongNameForType:(ENERGY_TYPE)t;
+ (ENERGY_TYPE) getEnergyTypeForString:(NSString*) type;

@end
