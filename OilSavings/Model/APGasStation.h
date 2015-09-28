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
//  APGasStation.h
//  OilSavings
//
//  Created by Andi Palo on 6/2/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface APGasStation : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic) BOOL hasGasoline;
@property (nonatomic) BOOL hasDiesel;
@property (nonatomic) ENERGY_TYPE type;

@property (nonatomic) float gasolinePrice;
@property (nonatomic) float dieselPrice;
@property (nonatomic) float gplPrice;
@property (nonatomic) float methanPrice;

@property (nonatomic) CLLocationCoordinate2D position;

@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic) NSUInteger gasStationID;

- (BOOL) hasEnergy:(ENERGY_TYPE)e;
- (void) setPrice:(float) p forEnergyType:(ENERGY_TYPE)e;
- (float) getPrice:(ENERGY_TYPE)e;
- (float) getPrice;
- (id) initWithDict:(NSDictionary*) dict andFuelType:(ENERGY_TYPE) e;
- (NSInteger) getNumberOfFuelsAvailable;
- (NSArray*) getAvailableFuelTypes;
- (BOOL)isEqual:(APGasStation*)anObject;

@end
