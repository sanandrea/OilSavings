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
            
            [delegate convertedAddressType:type to:coord];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Handle Error
        
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
            [delegate convertedCoordinateType:type to:contents[@"formatted_address"]];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Handle Error
        
    }];
}

+ (void) convertCoordinate:(CLLocationCoordinate2D)coord found:(void (^)(NSString*))found{
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
            ALog("Geocode result %@",contents);
            
            //call the block
            found(contents[@"formatted_address"]);
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Handle Error
        
    }];
}

@end
