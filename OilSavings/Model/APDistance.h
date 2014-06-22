//
//  APDistance.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APDistance : NSObject
@property (nonatomic) int distance;
@property (nonatomic, strong) NSString *text;
- (id) initWithdistance:(int) d;
@end
