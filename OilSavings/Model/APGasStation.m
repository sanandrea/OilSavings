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

@interface APGasStation ()
@property (nonatomic, strong) NSMutableArray* energyPrices;

@end

@implementation APGasStation

- (id) initWithPosition:(CLLocationCoordinate2D) position andName:(NSString*)nn{
    self = [super init];
    if (self) {
        self.position = position;
        self.name = nameExpansion[nn];
        self.logo = [APGasStation logoPath:nn];
        self.energyPrices = [[NSMutableArray alloc] init];
        for (int i = 0; i < ENERGIES_COUNT; i++) {
            [self.energyPrices addObject:[NSNumber numberWithFloat:-1]];
        }
    }
    return self;
}

- (id) initWithDict:(NSDictionary*) dict andFuelType:(ENERGY_TYPE) fuelType{
    CLLocationCoordinate2D p;
    p.latitude = [dict[@"lat"] doubleValue];
    p.longitude = [dict[@"lng"] doubleValue];

    self = [self initWithPosition:p andName:dict[@"brand"]];
    self.type = fuelType;
    

    [self setPrice:[dict[@"price"] floatValue] forEnergyType:self.type];
    self.gasStationID = [dict[@"id"] intValue];
//    ALog("My Id is: %d",self.gasStationID);
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
    [self.energyPrices replaceObjectAtIndex:e withObject:[NSNumber numberWithFloat:p]];
}
- (float) getPrice:(ENERGY_TYPE)e{
    return [[self.energyPrices objectAtIndex:e] floatValue];
}

- (float) getPrice{
    return [self getPrice:self.type];
}

- (NSInteger) getNumberOfFuelsAvailable{
    NSInteger count = 0;
    for (int i = 0; i < ENERGIES_COUNT; i++) {
        if ([self getPrice:(ENERGY_TYPE)i] > 0) {
            count++;
        }
    }
    return count;
}

- (NSArray*) getAvailableFuelTypes{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < ENERGIES_COUNT; i++) {
        if ([self getPrice:(ENERGY_TYPE)i] > 0) {
            [result addObject:[NSNumber numberWithInt:i]];
        }
    }
    return result;
}

- (BOOL)isEqual:(APGasStation*)anObject{
    if (self.gasStationID == anObject.gasStationID) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSString*) logoPath:(NSString*) key{
    NSMutableString * ret = [[NSMutableString alloc] initWithString:imagePrefix];
    [ret appendString:[key lowercaseString]];
    return  ret;
}
@end
