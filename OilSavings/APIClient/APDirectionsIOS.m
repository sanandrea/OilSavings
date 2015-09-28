// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
