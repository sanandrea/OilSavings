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
//  APLine.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "APDistance.h"
#import "APDuration.h"
#import "APStep.h"

@interface APLine : NSObject

@property (nonatomic, strong) APDuration *duration;
@property (nonatomic, strong) APDistance *distance;

@property (nonatomic) CLLocationCoordinate2D srcPos;
@property (nonatomic) CLLocationCoordinate2D dstPos;

@property (nonatomic, strong) MKPolyline *polyline;

@property (nonatomic, strong) NSString *srcAddress;
@property (nonatomic, strong) NSString *dstAddress;

@property (nonatomic, strong) NSMutableArray *steps;

- (void) addStep:(APStep*) step;
- (float) getVelocity;
- (id) initWithDistance:(APDistance*) d andDuration:(APDuration*) t andSrc:(CLLocationCoordinate2D) src andDst:(CLLocationCoordinate2D)dst;
@end
