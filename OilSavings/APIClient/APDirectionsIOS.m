//
//  APDirectionsIOS.m
//  OilSavings
//
//  Created by Andi Palo on 9/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APDirectionsIOS.h"
#import <MapKit/MapKit.h>

@implementation APDirectionsIOS


+ (void) findDirectionsOfPath:(APPath*) path
               indexOfRequest:(NSInteger)index
                   delegateTo:(id<APNetworkAPI>)delegate{
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *srcPlace = [[MKPlacemark alloc] initWithCoordinate:path.src addressDictionary:nil];
    MKMapItem *srcItem = [[MKMapItem alloc] initWithPlacemark:srcPlace];
    request.source = srcItem;
    
    MKPlacemark *dstPlace;
    MKMapItem *dstItem;
    
    MKPlacemark *interPlace;
    MKMapItem *interItem;
    if (path.hasDestination) {
        //TODO
        interPlace = [[MKPlacemark alloc] initWithCoordinate:path.gasStation.position addressDictionary:nil];
        interItem = [[MKMapItem alloc] initWithPlacemark:interPlace];
        
        dstPlace = [[MKPlacemark alloc] initWithCoordinate:path.dst addressDictionary:nil];
        dstItem = [[MKMapItem alloc] initWithPlacemark:dstPlace];
        request.destination = interItem;
    }else{
        dstPlace = [[MKPlacemark alloc] initWithCoordinate:path.gasStation.position addressDictionary:nil];
        dstItem = [[MKMapItem alloc] initWithPlacemark:dstPlace];
        request.destination = dstItem;
    }
    
    request.requestsAlternateRoutes = NO;
    MKDirections *directions =[[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             [delegate foundPath:path withIndex:index error:error];
         } else {
             MKRoute *rr = (MKRoute*)[response.routes objectAtIndex:0];
             path.overallPolyline = rr.polyline;
             [path setNewDistance:rr.distance];
             [path setNewTime:rr.expectedTravelTime];
             if (path.hasDestination) {
                 MKDirectionsRequest *secondRequet = [[MKDirectionsRequest alloc] init];
                 secondRequet.source = interItem;
                 secondRequet.destination = dstItem;
                 secondRequet.requestsAlternateRoutes = NO;
                 MKDirections *secondDirections = [[MKDirections alloc] initWithRequest:secondRequet];
                 [secondDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *secondResponse, NSError *error){
                     if (error) {
                         ALog("Error on 2nd %@",[error localizedDescription]);
                         [delegate foundPath:path withIndex:index error:error];
                     } else {
                         MKRoute *srr = (MKRoute*)[secondResponse.routes objectAtIndex:0];
                         [path setNewDistance:([path getDistance] + srr.distance)];
                         [path setNewTime:([path getTime] + srr.expectedTravelTime)];
                         path.secondaryPolyline = srr.polyline;
                         [delegate foundPath:path withIndex:index error:nil];
                     }
                 }];
             }else{
                 [delegate foundPath:path withIndex:index error:nil];
             }
         }
     }];
}

@end
