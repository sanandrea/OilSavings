//
//  APDirectionsIOS.h
//  OilSavings
//
//  Created by Andi Palo on 9/1/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNetworkAPI.h"

@interface APDirectionsIOS : NSObject

+ (void) findDirectionsOfPath:(APPath*) path
               indexOfRequest:(NSInteger)index
                   delegateTo:(id<APNetworkAPI>)delegate;

@end
