//
//  APGasStation.h
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APConstants.h"
#import "APPosition.h"

@interface APGasStation : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL hasGasoline;
@property (nonatomic) BOOL hasDiesel;

@property (nonatomic) float gasolinePrice;
@property (nonatomic) float dieselPrice;
@property (nonatomic, strong) APPosition *position;

- (BOOL) hasEnergy:(ENERGY_TYPE)e;
- (void) setPrice:(float) p forEnergyType:(ENERGY_TYPE)e;
- (float) getPrice:(ENERGY_TYPE)e;
- (id) initWithDict:(NSDictionary*) dict;

@end
