//
//  APGeocodeClient.m
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APGeocodeClient.h"
#import "AFNetworking.h"
// https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=API_KEY
// https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=API_KEY

static NSString * const GEOCODE_URL = @"https://maps.googleapis.com/maps/api/geocode/json";

@interface APGeocodeClient ()

@end

@implementation APGeocodeClient

+ (void) convertAddress:(NSString*)addr ofType:(ADDRESS_TYPE)type inDelegate:(id<APNetworkAPI>)delegate{
    addr = [addr stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:addr forKey:@"address"];
    [params setObject:GOOGLE_API_KEY forKey:@"key"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager GET:GEOCODE_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Process Response Object
        NSDictionary *response = (NSDictionary *)responseObject;
//        NSLog(@"Geocode response: %@",response);
        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSArray* results = (NSArray*) response[@"results"];
            NSDictionary *contents = [results objectAtIndex:0];
            
            CGFloat lat = [contents[@"geometry"][@"location"][@"lat"] floatValue];
            CGFloat lng = [contents[@"geometry"][@"location"][@"lng"] floatValue];
            
            CLLocationCoordinate2D coord;
            coord.latitude = lat;
            coord.longitude = lng;
            
            
            NSArray* addressComponents = contents[@"address_components"];
            NSString *country;
            
            for (NSDictionary *component in addressComponents) {
                //find type of component
                NSArray *types = component[@"types"];
                if ([types containsObject:@"country"]) {
                    country = component[@"short_name"];
                    if (![country isEqualToString:@"IT"]) {
                        NSMutableDictionary* details = [NSMutableDictionary dictionary];
                        [details setValue:@"Impossibile cercare distributori fuori dal territorio Italiano"
                                   forKey:NSLocalizedDescriptionKey];
                        NSError *error = [NSError errorWithDomain:@"saveoil" code:1001 userInfo:details];
                        [delegate convertedAddressType:type to:coord error:error];
                        return;
                    }
                }
            }
            
            [delegate convertedAddressType:type to:coord error:nil];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLLocationCoordinate2D coord;
        [delegate convertedAddressType:type to:coord error:error];
        
    }];
    
    
}
+ (void) convertCoordinate:(CLLocationCoordinate2D)coord ofType:(ADDRESS_TYPE)type inDelegate:(id<APNetworkAPI>)delegate{
    NSString *latlng = [NSString stringWithFormat:@"%f,%f",coord.latitude,coord.longitude];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:latlng forKey:@"latlng"];
    [params setObject:GOOGLE_API_KEY forKey:@"key"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager GET:GEOCODE_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Process Response Object
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response[@"status"] isEqualToString:@"OK"]) {
            
            NSArray* results = (NSArray*) response[@"results"];
            NSDictionary *contents = [results objectAtIndex:0];
            [delegate convertedCoordinateType:type to:contents[@"formatted_address"] error:nil];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate convertedCoordinateType:type to:nil error:error];
        
    }];
}

+ (void) convertCoordinate:(CLLocationCoordinate2D)coord found:(void (^)(NSString*, NSString *))found{
    NSString *latlng = [NSString stringWithFormat:@"%f,%f",coord.latitude,coord.longitude];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:latlng forKey:@"latlng"];
    [params setObject:GOOGLE_API_KEY forKey:@"key"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager GET:GEOCODE_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Process Response Object
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSString *street = @"";
            NSString *streetNumber = @"";
            NSString *cap = @"";
            NSString *city = @"";
            
            NSString *streetAndNumber;
            NSString *CAPAndCity;
            BOOL hasroute = NO;
            
            NSArray* results = (NSArray*) response[@"results"];
            NSDictionary *contents = [results objectAtIndex:0];
//            ALog("Geocode result %@",contents);
            
            NSArray* addressComponents = contents[@"address_components"];
            
            for (NSDictionary *component in addressComponents) {
                //find type of component
                NSArray *types = component[@"types"];
                if ([types containsObject:@"street_number"]) {
                    streetNumber = component[@"long_name"];
                } else if ([types containsObject:@"route"]){
                    street = component[@"long_name"];
                    hasroute = YES;
                } else if (!hasroute && [types containsObject:@"locality"]){
                    street = component[@"long_name"];
                } else if ([types containsObject:@"postal_code"]){
                    cap = component[@"long_name"];
                } else if([types containsObject:@"administrative_area_level_2"]){
                    city = component[@"long_name"];
                }
            }
            
            streetAndNumber = [NSString stringWithFormat:@"%@ %@", street, streetNumber];
            if ([cap length] > 0) {
                CAPAndCity = [NSString stringWithFormat:@"%@ %@",cap ,city];
            } else{
                CAPAndCity = city;
            }
            //call the block
            found(streetAndNumber, CAPAndCity);
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Handle Error
        
    }];
}

@end
