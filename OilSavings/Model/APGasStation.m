//
//  APGasStation.m
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APGasStation.h"

@implementation APGasStation

- (id) initWithPosition:(APPosition*) position andName:(NSString*)name{
    self = [super init];
    self.position = position;
    self.name = name;
    return self;
}

- (BOOL) hasEnergy:(ENERGY_TYPE)e{
    if (e == kEnergyDiesel) {
        return self.hasDiesel;
    }else if (e == kEnergyGasoline){
        return self.hasGasoline;
    }
    return NO;
}
- (void) setPrice:(float) p forEnergyType:(ENERGY_TYPE)e{
    if (e == kEnergyDiesel) {
        self.dieselPrice = p;
    }else if (e == kEnergyGasoline){
        self.gasolinePrice = p;
    }
}
- (float) getPrice:(ENERGY_TYPE)e{
    if (e == kEnergyDiesel) {
        return self.dieselPrice;
    }else if (e == kEnergyGasoline){
        return self.gasolinePrice;
    }
    return 0.f;
}

@end
