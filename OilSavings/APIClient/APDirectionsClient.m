//
//  APDirectionsClient.m
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APDirectionsClient.h"
#import "AFNetworking.h"

static NSString * const DIRECTIONS_URL = @"https://maps.googleapis.com/maps/api/directions/json";

@implementation APDirectionsClient

+ (void) findDirectionsOfPath:(APPath*) path
               indexOfRequest:(NSInteger)index
                   delegateTo:(id<APNetworkAPI>)delegate{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:GOOGLE_API_KEY forKey:@"key"];
    [params setObject:@"it" forKey:@"region"];
    
    NSString *latlngSrc = [NSString stringWithFormat:@"%f,%f",path.src.latitude,path.src.longitude];
    [params setObject:latlngSrc forKey:@"origin"];
    
    NSString *latlngDst;
    NSString *latlngWay;
    if (path.hasDestination) {
        latlngDst = [NSString stringWithFormat:@"%f,%f",path.dst.latitude,path.dst.longitude];
        latlngWay = [NSString stringWithFormat:@"%f,%f",path.gasStation.position.latitude,path.gasStation.position.longitude];

        [params setObject:latlngWay forKey:@"waypoints"];
    }else{
        latlngDst = [NSString stringWithFormat:@"%f,%f",path.gasStation.position.latitude,path.gasStation.position.longitude];
        
    }
    [params setObject:latlngDst forKey:@"destination"];
//    ALog("Origin %@ and destination %@",latlngSrc , latlngDst);
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager GET:DIRECTIONS_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Process Response Object
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response[@"status"] isEqualToString:@"OK"]) {
            
            NSArray* routes = (NSArray*) response[@"routes"];
            for (NSDictionary *routeDict in routes) {
//                NSLog(@"Route dictionary: %@",routeDict);
                NSArray *legs = routeDict[@"legs"];
                APLine *line;
                for (NSDictionary *legDict in legs) {
                    APDistance *distance = [[APDistance alloc] initWithdistance:[legDict[@"distance"][@"value"] intValue]];
                    APDuration *duration = [[APDuration alloc] initWithDuration:[legDict[@"duration"][@"value"] integerValue]];
                    CLLocationCoordinate2D legSrc = CLLocationCoordinate2DMake([legDict[@"start_location"][@"lat"] doubleValue], [legDict[@"start_location"][@"lng"] doubleValue]);
                    CLLocationCoordinate2D legDst = CLLocationCoordinate2DMake([legDict[@"end_location"][@"lat"] doubleValue], [legDict[@"end_location"][@"lng"] doubleValue]);
                    
                    line = [[APLine alloc] initWithDistance:distance andDuration:duration andSrc:legSrc andDst:legDst];
//                    ALog("lat is %f and lng is %f",legSrc.longitude,legSrc.longitude);
                    NSArray *steps = legDict[@"steps"];
                    APStep *step;
                    
                    for (NSDictionary *stepDict in steps) {
                        APDistance *stepDist = [[APDistance alloc] initWithdistance:[stepDict[@"distance"][@"value"] intValue]];
                        APDuration *stepDura = [[APDuration alloc] initWithDuration:[stepDict[@"duration"][@"value"] integerValue]];
                        CLLocationCoordinate2D stepSrc = CLLocationCoordinate2DMake([stepDict[@"start_location"][@"lat"] doubleValue], [stepDict[@"start_location"][@"lng"] doubleValue]);
                        CLLocationCoordinate2D stepDst = CLLocationCoordinate2DMake([stepDict[@"end_location"][@"lat"] doubleValue], [stepDict[@"end_location"][@"lng"] doubleValue]);
                        
                        step = [[APStep alloc] initWithDistance:stepDist andDuration:stepDura andSrcPos:stepSrc andDstPos:stepDst andPoly:stepDict[@"polyline"]];
                        [line addStep:step];
                    }
                    [path addLine:line];
                }
                //ALog("polyline is %@", routeDict[@"overview_polyline"][@"points"]);
                path.overallPolyline = [APDirectionsClient polylineWithEncodedString:routeDict[@"overview_polyline"][@"points"]];
                
                //set bounds for minimap view.
                path.northEastBound = CLLocationCoordinate2DMake([routeDict[@"bounds"][@"northeast"][@"lat"] floatValue],[routeDict[@"bounds"][@"northeast"][@"lng"] floatValue]);
                path.southWestBound = CLLocationCoordinate2DMake([routeDict[@"bounds"][@"southwest"][@"lat"] floatValue],[routeDict[@"bounds"][@"southwest"][@"lng"] floatValue]);
            }
            //[path constructMKPolyLines];
            [delegate foundPath:path withIndex:index];
        }else if ([response[@"status"] isEqualToString:@"OVER_QUERY_LIMIT"]){
            ALog("OVER QUERY LIMIT reached in index %ld",(long)index);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Handle Error
        ALog("Error here");
    }];
    
}

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}
@end
