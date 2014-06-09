//
//  APGasStation.h
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface APGasStation : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic) BOOL hasGasoline;
@property (nonatomic) BOOL hasDiesel;
@property (nonatomic) ENERGY_TYPE type;

@property (nonatomic) float gasolinePrice;
@property (nonatomic) float dieselPrice;
@property (nonatomic) CLLocationCoordinate2D position;

- (BOOL) hasEnergy:(ENERGY_TYPE)e;
- (void) setPrice:(float) p forEnergyType:(ENERGY_TYPE)e;
- (float) getPrice:(ENERGY_TYPE)e;
- (float) getPrice;
- (id) initWithDict:(NSDictionary*) dict;

@end
