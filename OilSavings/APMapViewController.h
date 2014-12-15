//
//  APMapViewController.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

#import "APCar.h"
#import "APGasStationClient.h"
#import "APNetworkAPI.h"
#import "APOptionsViewController.h"

#import "GAITrackedViewController.h"
#import "AMPopTip.h"


@interface APMapViewController : GAITrackedViewController <CLLocationManagerDelegate, APNetworkAPI,
MKMapViewDelegate, OptimizationOptions>
{
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
- (IBAction) gotoCurrentLocation:(id)sender;
- (IBAction) showGasStationList:(id)sender;
- (IBAction) optimizeAgain:(id)sender;

-(void) carChanged;

@property (nonatomic, strong) APCar* myCar;

@end
