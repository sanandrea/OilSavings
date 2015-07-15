//
//  APGasStationClient.h
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "APGasStation.h"
#import <MapKit/MapKit.h>

@protocol APNetworkAPI;

@interface APGasStationClient : NSObject

@property (nonatomic) double minLat;
@property (nonatomic) double maxLat;
@property (nonatomic) double minLong;
@property (nonatomic) double maxLong;

@property (nonatomic) ENERGY_TYPE fuel;
@property (nonatomic, strong) NSMutableArray* gasStations;

@property (nonatomic, weak) id <APNetworkAPI> delegate;


- (id) initWithCenter:(CLLocationCoordinate2D) center andFuel:(ENERGY_TYPE) fuel;
- (void)getStations;
+ (void) getDetailsOfGasStation:(APGasStation*)gst intoDict:(void (^)(NSDictionary*))result;

@end
