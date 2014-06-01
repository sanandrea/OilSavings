//
//  APStep.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APDistance.h"
#import "APDuration.h"
#import "APPosition.h"

@interface APStep : NSObject

@property (nonatomic, strong) APDuration *stepDuration;
@property (nonatomic, strong) APDistance *stepDistance;

@property (nonatomic, strong) APPosition *srcPos;
@property (nonatomic, strong) APPosition *dstPos;

@property (nonatomic, strong) NSString *polyline;

@end
