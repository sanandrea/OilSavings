//
//  APMapViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APMapViewController.h"
#import "SWRevealViewController.h"
#import "APAddCarViewController.h"
#import "APConstants.h"
#import "APAppDelegate.h"
#import "MKMapView+ZoomLevel.h"
#import "APGasStation.h"

#define ZOOM_LEVEL 14

@interface APMapViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation APMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Mappa";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.1f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //get managed object context from app delegate
    APAppDelegate *appDelegate = (APAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    //get user prefs for the preferred car model id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int modelID = [[prefs objectForKey:kPreferredCar] intValue];
    
    if ( modelID >= 0) {
        //get from core data the car by model ID
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        // Set example predicate and sort orderings...
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(modelID = %d)", modelID];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (array == nil)
        {
            ALog("Error on retrieving preferred car by model ID %d",modelID);
            return;
        }
        if (!([array count] == 1)){
            ALog("Error more than one Car exists with the same model ID %d",modelID);
            return;
        }
        self.myCar = [array objectAtIndex:0];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 100 m
    [locationManager startUpdatingLocation];
    self.map.showsUserLocation = YES;
}

- (void) viewDidAppear:(BOOL)animated{
    ALog("Map apperaed");
    //Check if there is any Car Saved.
    /*
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs objectForKey:kCarsRegistered] integerValue] == 0) {
        //Present Add Car View controller by presenting the container View Controller
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        UINavigationController *controller = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"addCarNavContainer"];
        [self presentViewController:controller animated:YES completion:nil];
    }
    */
    if (self.myCar != nil) {
        ALog("Car name is: %@", self.myCar.friendlyName);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    
    /* 
     * New implementation
    static dispatch_once_t centerMapFirstTime;
    
	if ((newLocation.coordinate.latitude != 0.0) && (newLocation.coordinate.longitude != 0.0)) {
		dispatch_once(&centerMapFirstTime, ^{
			[self.map setCenterCoordinate:newLocation.coordinate zoomLevel:ZOOM_LEVEL animated:YES];
		});
	}
     */
    
    
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    /*
     * old implementation
     *
     */
    [self.map setCenterCoordinate:newLocation.coordinate zoomLevel:ZOOM_LEVEL animated:NO];
    APGasStationClient *gs = [[APGasStationClient alloc] initWithRegion:self.map.region andFuel:@"b"];
    gs.delegate = self;
    [gs getStations];
    
    [locationManager stopUpdatingLocation];
}


#pragma mark - Gas Stations protocol

- (void) gasStation:(APGasStationClient*)gsClient didFinishWithStations:(BOOL) newStations{
    if (newStations) {
        MKPointAnnotation *annotation;
        for (APGasStation *gs in gsClient.gasStations) {
            annotation = [[MKPointAnnotation alloc]init];
            annotation.coordinate = CLLocationCoordinate2DMake(gs.position.latitude, gs.position.longitude);
            annotation.title = gs.name;
            [self.map addAnnotation:annotation];
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
