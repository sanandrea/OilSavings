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
NSString *const GOOGLE_API_KEY = @"AIzaSyDk2W4Au5SlQC5WPpcFFEpy8I7PTnZtvno";

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

@end
