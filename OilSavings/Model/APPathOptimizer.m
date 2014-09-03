//
//  APPathOptimizer.m
//  OilSavings
//
//  Created by Andi Palo on 6/7/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPathOptimizer.h"
#import "APGasStation.h"
#import "APDirectionsClient.h"
#import "APGeocodeClient.h"
#import "APDirectionsIOS.h"

static const int SLEEP_INTERVAL = 250000; // 250ms

@implementation APPathOptimizer

- (id) initWithCar:(APCar*) mycar cash:(NSInteger)import andDelegate:(id<APNetworkAPI>)dele{
    self = [super init];
    
    if (self) {
        self.car = mycar;
        self.delegate = dele;
        self.cashAmount = import;
        self.paths = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void) changeCar:(APCar *)c{
    self.car = c;
}

- (void) optimizeRouteFrom:(CLLocationCoordinate2D)src
                        to:(CLLocationCoordinate2D)dst
           withGasStations:(NSArray*)gasStations{
    
    //init paths
//    ALog("Optimize is called");
    self.src = src;
    self.dst = dst;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self initPathsWithGasStations:gasStations];
    });

}


- (void) initPathsWithGasStations:(NSArray*)gs {
//    ALog("Dispatched Job for Gas Stations in optimizer");
    //clear existing paths
    [self.paths removeAllObjects];
    APPath *path;
    
    for (APGasStation* g in gs) {
        if (CLLocationCoordinate2DIsValid(self.dst)) {
            path = [[APPath alloc]initWith:self.src and:self.dst andGasStation:g];
            path.hasDestination = YES;
        }else{
            path = [[APPath alloc]initWith:self.src andGasStation:g];
        }
        [self.paths addObject:path];
    }
    //sort
    [self.paths sortUsingSelector:@selector(compareAir:)];

    //now we are on global queue and have all paths sorted by air distance
    
    int counter = 1,index = 0;
    
    while (counter <= [self.paths count] / REQUEST_BUNDLE + 1) {
//        ALog("External while: counter is %d and index is %d",counter, index);
        
        //save in what batch are;
        self.currentBatch = MIN(counter * REQUEST_BUNDLE, [self.paths count]);
        
        while (index < counter * REQUEST_BUNDLE && index < [self.paths count]) {
//            ALog("Internal while: counter is %d and index is %d",counter, index);
#ifdef USE_IOS_MAPS
            [APDirectionsIOS findDirectionsOfPath:[self.paths objectAtIndex:index] indexOfRequest:index delegateTo:self];
#else
            [APDirectionsClient findDirectionsOfPath:[self.paths objectAtIndex:index] indexOfRequest:index delegateTo:self];
#endif
            usleep(SLEEP_INTERVAL);
            index++;
        }
        usleep(SLEEP_INTERVAL * 5);
        counter ++;
    }
    
}
- (void) foundPath:(APPath*)path withIndex:(NSInteger)index error:(NSError *)er{

    // The address is retrieved from APGasStationClient
    
//    [APGeocodeClient convertCoordinate:path.gasStation.position found:^(NSString *street, NSString* capCity){
//        path.gasStation.street = street;
//        path.gasStation.postalCode = capCity;
//        
//    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate foundPath:path withIndex:0 error:er];
    });
}

@end
