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

@interface APMapViewController : UIViewController <CLLocationManagerDelegate, GasStationsHandler>
{
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) APCar* myCar;
@property (nonatomic, weak) IBOutlet MKMapView *map;

@end
