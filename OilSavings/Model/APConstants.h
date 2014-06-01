//
//  APConstants.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDBDowloaded;
extern NSString *const kDBVersion;
extern NSString *const kResVersion;
extern NSString *const kCarsRegistered;
extern NSString *const kPreferredCar;

typedef enum{
    kEnergyGasoline,
    kEnergyDiesel
}ENERGY_TYPE;

@interface APConstants : NSObject

@end
