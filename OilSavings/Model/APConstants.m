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
//  APConstants.m
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APConstants.h"

static const float EARTH_RADIUS = 6371;

NSString *const kDBDowloaded = @"dbDownloaded";
NSString *const kDBVersion = @"dbVersion";
NSString *const kResVersion = @"resVersion";
NSString *const kCarsRegistered = @"carsRegistered";
NSString *const kPreferredCar = @"preferredCar";
NSString *const kCashAmount = @"deafultCashAmount";
NSString *const GOOGLE_API_KEY = @"AIzaSyDk2W4Au5SlQC5WPpcFFEpy8I7PTnZtvno";
NSString *const kDefaultTankCapacity = @"defaultTankCapa";

NSString *const kAdUnitID = @"ca-app-pub-4611193659291268/2158049908";
NSString *const kTrackingID = @"UA-54135915-1";

const int REQUEST_BUNDLE = 5;

//
const int ENERGIES_COUNT = 6;

const int kDEBUG = 1;

const CLLocationDegrees emptyLocation = -1000.0;
const CLLocationCoordinate2D emptyLocationCoordinate = {emptyLocation, emptyLocation};

@implementation APConstants

// http://en.wikipedia.org/wiki/Haversine_formula
+ (float) haversineDistance:(float)latA :(float)latB :(float)longA :(float)longB{
    
    float h = powf(sinf((latB - latA)/2), 2) +  cosf(latA)* cosf(latB) * powf(sinf((longB - longA)/2), 2);
    
    if (h > 1)
        h = 1;
    
    if (h < 0)
        h = 0;
    
    return 2 * EARTH_RADIUS * asin( sqrtf(h));
}

+ (NSString *) getEnergyStringForType:(ENERGY_TYPE)t{
    switch (t) {
        case kEnergyGasoline:
            return @"b";
            break;
        case kEnergyDiesel:
            return @"d";
            break;
        case kEnergyGPL:
            return @"g";
            break;
        case kEnergyMethan:
            return @"m";
            break;
        case kEnergyGasolineSP:
            return @"c";
            break;
        case kEnergyDieselSP:
            return @"e";
            break;
        default:
            return @"b";
            break;
    }
}

+ (NSString *) getEnergyLongNameForType:(ENERGY_TYPE)t{
    switch (t) {
        case kEnergyGasoline:
            return NSLocalizedString(@"Benzina", nil);
            break;
        case kEnergyDiesel:
            return NSLocalizedString(@"Diesel", nil);
            break;
        case kEnergyGPL:
            return NSLocalizedString(@"GPL", nil);
            break;
        case kEnergyMethan:
            return NSLocalizedString(@"Metano", nil);
            break;
        case kEnergyGasolineSP:
            return NSLocalizedString(@"Benzina Speciale", nil);
            break;
        case kEnergyDieselSP:
            return NSLocalizedString(@"Diesel Speciale", nil);
            break;
        default:
            return @"b";
            break;
    }
}

+ (ENERGY_TYPE) getEnergyTypeForString:(NSString*) type{
    if ([type isEqualToString:@"b"]) {
        return kEnergyGasoline;
    }else if ([type isEqualToString:@"d"]){
        return kEnergyDiesel;
    }else if ([type isEqualToString:@"g"]){
        return kEnergyGPL;
    }else if ([type isEqualToString:@"m"]){
        return kEnergyMethan;
    }else if ([type isEqualToString:@"c"]){
        return kEnergyGasolineSP;
    }else if ([type isEqualToString:@"e"]){
        return kEnergyDieselSP;
    }else{
        return kEnergyUnknown;
    }
}

+ (float) deltaLongitude:(float) distanceKm atLat:(float)latitude{
    return 2 * asinf(sinf(distanceKm / (2 * EARTH_RADIUS)) / cosf(latitude));
}

@end
