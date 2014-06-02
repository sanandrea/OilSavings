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

- (id) initWithPosition:(APPosition*) position andName:(NSString*)nn{
    self = [super init];
    self.position = position;
    self.name = [APGasStation longNameDictionary:nn];
    self.logo = [APGasStation logoPath:nn];
    return self;
}

- (id) initWithDict:(NSDictionary*) dict{
    APPosition *p = [[APPosition alloc] initWithLat:[dict[@"lat"] doubleValue] andLong:[dict[@"lng"] doubleValue]];
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

+ (NSString*) longNameDictionary:(NSString*) key{
    static NSDictionary* output = nil;
    
    if (output == nil)
    {
        // create dict
        NSArray* objs = [[NSArray alloc] initWithObjects:
                         @"AR",
                         @"AP",
                         @"AQ",
                         @"AU",
                         @"BZ",
                         @"BE",
                         @"CF",
                         @"CL",
                         @"EG",
                         @"SP",
                         @"EY",
                         @"AG",
                         @"ER",
                         @"ES",
                         @"F2",
                         @"H6",
                         @"IE",
                         @"IN",
                         @"IP",
                         @"IS",
                         @"KT",
                         @"LT",
                         @"MI",
                         @"OM",
                         @"PE",
                         @"Q8",
                         @"QE",
                         @"RE",
                         @"SM",
                         @"T7",
                         @"SH",
                         @"SF",
                         @"TA",
                         @"T2",
                         @"TO",
                         @"TE",
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
    
    return output[key];
}
+ (NSString*) logoPath:(NSString*) key{
    NSMutableString * ret = [[NSMutableString alloc] initWithString:imagePrefix];
    [ret appendString:key];
    [ret appendString:imageSuffix];
    return  ret;
}
@end
