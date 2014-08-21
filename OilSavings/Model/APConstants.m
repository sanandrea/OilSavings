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

const int REQUEST_BUNDLE = 5;

//
const int ENERGIES_COUNT = 6;

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
