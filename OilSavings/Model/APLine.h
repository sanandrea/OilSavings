//
//  APLine.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APDistance.h"
#import "APDuration.h"
#import "APPosition.h"
#import "APStep.h"

@interface APLine : NSObject

@property (nonatomic, strong) APDuration *duration;
@property (nonatomic, strong) APDistance *distance;

@property (nonatomic, strong) APPosition *srcPos;
@property (nonatomic, strong) APPosition *dstPos;

@property (nonatomic, strong) NSString *srcAddress;
@property (nonatomic, strong) NSString *dstAddress;

@property (nonatomic, strong) NSMutableArray *steps;

- (void) addStep:(APStep*) step;
- (float) getVelocity;
@end
