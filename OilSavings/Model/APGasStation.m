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
static NSDictionary *nameExpansion;

@implementation APGasStation

- (id) initWithPosition:(CLLocationCoordinate2D) position andName:(NSString*)nn{
    self = [super init];
    if (self) {
        self.position = position;
        self.name = nameExpansion[nn];
        self.logo = [APGasStation logoPath:nn];
    }
    return self;
}

- (id) initWithDict:(NSDictionary*) dict{
    CLLocationCoordinate2D p;
    p.latitude = [dict[@"lat"] doubleValue];
    p.longitude = [dict[@"lng"] doubleValue];

    if (self.type == kEnergyGasoline) {
        self.gasolinePrice = [dict[@"price"] floatValue];
    }else if (self.type == kEnergyDiesel){
        self.dieselPrice = [dict[@"price"] floatValue];
    }
    self.gasStationID = [dict[@"id"] intValue];
    ALog("My Id is: %d",self.gasStationID);
    self = [self initWithPosition:p andName:dict[@"brand"]];
    return self;
}


+ (void) initialize{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        NSArray* keys = [[NSArray alloc] initWithObjects:
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
        NSArray* objs = [[NSArray alloc] initWithObjects:
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
        
        nameExpansion = [NSDictionary dictionaryWithObjects:objs forKeys:keys];
    }
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
- (float) getPrice{
    if (self.type == kEnergyDiesel) {
        return self.dieselPrice;
    }else if (self.type == kEnergyGasoline){
        return self.gasolinePrice;
    }
    return 0.f;
}

+ (NSString*) logoPath:(NSString*) key{
    NSMutableString * ret = [[NSMutableString alloc] initWithString:imagePrefix];
    [ret appendString:[key lowercaseString]];
    return  ret;
}
@end
