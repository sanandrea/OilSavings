//
//  APGasStation.m
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APGasStation.h"
static NSString *imagePrefix = @"logo_";
static NSString *imageSuffix = @"_small.png";

@implementation APGasStation

- (id) initWithPosition:(CLLocationCoordinate2D) position andName:(NSString*)nn{
    self = [super init];
    if (self) {
        self.position = position;
        self.name = nn;
        self.logo = [APGasStation logoPath:nn];
    }
    return self;
}

- (id) initWithDict:(NSDictionary*) dict{
    CLLocationCoordinate2D p;
    p.latitude = [dict[@"lat"] doubleValue];
    p.longitude = [dict[@"lng"] doubleValue];
    self = [self initWithPosition:p andName:dict[@"brand"]];
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

+ (NSDictionary*) longNameDictionary{
    static NSDictionary* output = nil;
    
    if (output == nil)
    {
        // create dict
        NSArray* objs = [[NSArray alloc] initWithObjects:
                         @"ar",
                         @"ap",
                         @"aq",
                         @"au",
                         @"bz",
                         @"be",
                         @"cf",
                         @"cl",
                         @"eg",
                         @"sp",
                         @"ey",
                         @"ag",
                         @"er",
                         @"es",
                         @"f2",
                         @"h6",
                         @"ie",
                         @"in",
                         @"ip",
                         @"is",
                         @"kt",
                         @"lt",
                         @"mi",
                         @"om",
                         @"pe",
                         @"q8",
                         @"qe",
                         @"re",
                         @"sm",
                         @"t7",
                         @"sh",
                         @"sf",
                         @"ta",
                         @"t2",
                         @"to",
                         @"te",
                         nil];
        NSArray* keys = [[NSArray alloc] initWithObjects:
                         @"Al Risparmio",
                         @"Api",
                         @"Aquila",
                         @"Auchan",
                         @"Benza",
                         @"Beyfin",
                         @"Carrefour",
                         @"CP Oil",
                         @"Ego",
                         @"Energia Siciliana",
                         @"Energyca",
                         @"Eni",
                         @"Erg",
                         @"Esso",
                         @"Fiamma 2000",
                         @"H6",
                         @"Ies",
                         @"Indipendente",
                         @"IP",
                         @"IperStation",
                         @"Kerotris",
                         @"LTP",
                         @"Mirina",
                         @"Omv",
                         @"Petrolchimica Sud",
                         @"Q8",
                         @"Q8easy",
                         @"Repsol",
                         @"San Marco Petroli",
                         @"Sette",
                         @"Shell",
                         @"Sia Fuel",
                         @"Tamoil",
                         @"TE 24/24",
                         @"Total",
                         @"TotalErg",
                         nil];
        
        output = [NSDictionary dictionaryWithObjects:objs forKeys:keys];
        
    }
    
    return output;
}
+ (NSString*) logoPath:(NSString*) key{
    NSMutableString * ret = [[NSMutableString alloc] initWithString:imagePrefix];
    [ret appendString:[key lowercaseString]];
    return  ret;
}
@end
