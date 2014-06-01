//
//  APPath.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPosition.h"
#import "APLine.h"
@interface APPath : NSObject

@property (nonatomic, strong) APPosition *northEast;
@property (nonatomic, strong) APPosition *southWest;

@property (nonatomic, strong) NSMutableArray *lines;

- (void) addLine:(APLine*) line;
- (APPosition*) getNorthEastBorder;
- (APPosition*) getsouthWestBorder;
- (int) getDistance;

@end
