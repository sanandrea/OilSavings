//
//  APDuration.h
//  OilSavings
//
//  Created by Andi Palo on 6/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APDuration : NSObject
@property (nonatomic) NSInteger duration;
@property (nonatomic, strong) NSString *text;
- (id) initWithDuration:(NSInteger) d;
@end
