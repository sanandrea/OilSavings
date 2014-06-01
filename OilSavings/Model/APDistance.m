//
//  APDistance.m
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APDistance.h"

@implementation APDistance

- (id) initWithdistance:(int) d andText:(NSString*) someText{
    self = [super init];
    self.distance = d;
    self.text = someText;    
    return self;
}

@end
