//
//  APCar.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface APCar : NSManagedObject
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *model;
@property (nonatomic) NSInteger modelID;
@property (nonatomic, strong) NSString *friendlyName;

@property (nonatomic) float pA;
@property (nonatomic) float pB;
@property (nonatomic) float pC;
@property (nonatomic) float pD;


@end
