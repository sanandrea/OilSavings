//
//  APMapViewController.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "APCar.h"
#import <MapKit/MapKit.h>
#import "APGasStationClient.h"
#import "APOptionsViewController.h"
#import "APNetworkAPI.h"

@interface APMapViewController : UIViewController <CLLocationManagerDelegate, APNetworkAPI,
MKMapViewDelegate, OptimizationOptions>
{
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
- (IBAction) gotoCurrentLocation:(id)sender;
- (IBAction) showGasStationList:(id)sender;
- (IBAction) optimizeAgain:(id)sender;

@property (nonatomic, strong) APCar* myCar;

@end
