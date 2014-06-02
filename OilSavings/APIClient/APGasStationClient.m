//
//  APGasStationClient.m
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APGasStationClient.h"
#import "AFNetworking.h"
#import "APGasStation.h"

static NSString * const BaseURLString = @"http://www2.prezzibenzina.it/develop/tech/handlers/search_handler.php";

@interface APGasStationClient ()


@end

@implementation APGasStationClient


- (id) initWithRegion:(MKCoordinateRegion) region andFuel:(NSString*) fuel{
    self = [super init];
    
    //a region double in size that that of the map
    self.minLat = region.center.latitude - region.span.latitudeDelta;
    self.maxLat = region.center.latitude + region.span.latitudeDelta;
    
    self.minLong = region.center.longitude - region.span.longitudeDelta;
    self.maxLong = region.center.longitude + region.span.longitudeDelta;
    
    self.fuel = fuel;
    
    self.gasStations = [[NSMutableArray alloc]init];

    return self;
}

- (void)getStations{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    NSArray* objs = [[NSArray alloc] initWithObjects:
                     [NSNumber numberWithDouble:self.minLat],
                     [NSNumber numberWithDouble:self.minLong],
                     [NSNumber numberWithDouble:self.maxLat],
                     [NSNumber numberWithDouble:self.maxLong],
                     self.fuel,
                     [NSNumber numberWithInt:1],
                     @"",
                     @"getStations",
                     nil];
    NSArray* keys = [[NSArray alloc] initWithObjects:
                     @"min_lat",
                     @"min_long",
                     @"max_lat",
                     @"max_long",
                     @"fuels",
                     @"compact",
                     @"brand",
                     @"sel",
                     nil];
    
    NSDictionary *urlParams = [NSDictionary dictionaryWithObjects:objs forKeys:keys];
    
    [manager GET:BaseURLString parameters:urlParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Process Response Object
        NSArray *response = (NSArray *)responseObject;
        ALog("Uraah %@",response);
        APGasStation *gs;
        for (NSDictionary *dict in response) {
            gs = [[APGasStation alloc]initWithDict:dict];
            [self.gasStations addObject:gs];
        }
        [self .delegate gasStation:self didFinishWithStations:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Handle Error
        [self .delegate gasStation:self didFinishWithStations:NO];
    }];
}


@end
