//
//  APCar.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface APCar : NSManagedObject
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *friendlyName;

@property (nonatomic, strong) NSNumber *modelID;
@property (nonatomic, strong) NSNumber *energy;
@property (nonatomic, strong) NSNumber *pA;
@property (nonatomic, strong) NSNumber *pB;
@property (nonatomic, strong) NSNumber *pC;
@property (nonatomic, strong) NSNumber *pD;
@property (nonatomic, strong) NSNumber *urbanConsumption;
@property (nonatomic, strong) NSNumber *extraUrbanConsumption;

- (ENERGY_TYPE) getEnergyType;
@end
