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
#import "APAppDelegate.h"
#import "MKMapView+ZoomLevel.h"
#import "APGasStation.h"
#import "APGSAnnotation.h"
#import "APGeocodeClient.h"
#import "APPathOptimizer.h"

#define ZOOM_LEVEL 14
static float kAnnotationPadding = 10.0f;
static float kCallOutHeight = 40.0f;
static float kLogoHeightPadding = 6.0f;

@interface APMapViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSString *srcAddress;
@property (nonatomic, strong) NSString *dstAddress;

@property (nonatomic) CLLocationCoordinate2D srcCoord;
@property (nonatomic) CLLocationCoordinate2D dstCoord;

@property (nonatomic) NSInteger cashAmount;
@property (nonatomic, strong) NSArray *gasStations;

@property (nonatomic, strong) APPathOptimizer *optimizer;

@end

@implementation APMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Mappa";
    [self.mapView setDelegate:self];
    
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
    self.cashAmount = [[prefs objectForKey:kCashAmount] integerValue];
    
    
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
    
    if ([locationManager location] !=nil) {
        [self centerMapInLocation:[locationManager location].coordinate];
    }
    self.mapView.showsUserLocation = YES;
}


- (void) centerMapInLocation:(CLLocationCoordinate2D)loc{
    /*
     * old implementation
     *
     */
    [self.mapView setCenterCoordinate:loc zoomLevel:ZOOM_LEVEL animated:NO];
    APGasStationClient *gs = [[APGasStationClient alloc] initWithRegion:self.mapView.region andFuel:[self.myCar.energy intValue]];
    gs.delegate = self;
    [gs getStations];
    
    //convert the address
    [APGeocodeClient convertCoordinate:loc ofType:kAddressSrc inDelegate:self];
    self.srcCoord = loc;
}
- (void) viewDidAppear:(BOOL)animated{
    ALog("Map appeared");
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
    [self centerMapInLocation:newLocation.coordinate];
    
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error     {
    if(error.code == kCLErrorDenied) {
        
        // alert user
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access to location services is disabled"
                                                            message:@"You can turn Location Services on in Settings -> Privacy -> Location Services"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else if(error.code == kCLErrorLocationUnknown) {
        NSLog(@"Error: location unknown");
    } else {
        NSLog(@"Error retrieving location");
    }
}

- (IBAction)options:(id)sender{
    [self performSegueWithIdentifier: @"OptionsSegue" sender: self];
}

#pragma mark - Network APIs

#pragma mark - Gas Stations

- (void) gasStation:(APGasStationClient*)gsClient didFinishWithStations:(BOOL) newStations{
    if (newStations) {
        APGSAnnotation *annotation;
        for (APGasStation *gs in gsClient.gasStations) {
            annotation = [[APGSAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake(gs.position.latitude, gs.position.longitude)];
            annotation.gasStation = gs;
            [self.mapView addAnnotation:annotation];
        }
        self.gasStations = gsClient.gasStations;
        
        self.optimizer = [[APPathOptimizer alloc] initWithCar:self.myCar cash:5 andDelegate:self];
        [self.optimizer optimizeRouteFrom:self.srcCoord to:self.dstCoord hasDestination:NO withGasStations:self.gasStations];
        
    }
    
}

#pragma mark - Geocoding Convertions Protocol

- (void) convertedAddressType:(ADDRESS_TYPE)type to:(CLLocationCoordinate2D)coord{
    
    if (type == kAddressSrc) {
        self.srcCoord = coord;
        [self centerMapInLocation:coord];
    }else{
        self.dstCoord = coord;
    }
    
}

- (void) convertedCoordinateType:(ADDRESS_TYPE)type to:(NSString*) address{
    if (type == kAddressSrc) {
        self.srcAddress = address;
    }
}

#pragma mark - Path Available
- (void) foundPath:(APPath*)path withIndex:(NSInteger)index{
    ALog("Found path in map is called");
//    [path constructMKPolyLines];
//    APLine *line = [path.lines objectAtIndex:0];

    [self.mapView addOverlay:path.overallPolyline];
}


#pragma mark - Options Protocol
- (void)optionsController:(APOptionsViewController*) controller didfinishWithSave:(BOOL)save{
    if (save) {
        
        if (([controller.srcAddr length] > 0) && ![controller.srcAddr isEqualToString:self.srcAddress]) {
            self.srcAddress = controller.srcAddr;
            [APGeocodeClient convertAddress:self.srcAddress ofType:kAddressSrc inDelegate:self];
        }
        
        if (([controller.dstAddr length] > 0) && ![self.dstAddress isEqualToString:controller.dstAddr]) {
            self.dstAddress = controller.dstAddr;
            [APGeocodeClient convertAddress:self.srcAddress ofType:kAddressSrc inDelegate:self];
        }
       
        
        self.cashAmount = controller.cashAmount;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Custom Annotations
// user tapped the disclosure button in the callout
//
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we illustrate how to detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[APGSAnnotation class]])
    {
        NSLog(@"clicked Annotation");
    }
    
//    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[APGSAnnotation class]]){
        APGSAnnotation *gsn = (APGSAnnotation*) annotation;
        NSString *GSAnnotationIdentifier = [NSString stringWithFormat:@"gasStationIdentifier_%@", gsn.gasStation.name];
        
        MKAnnotationView *markerView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:GSAnnotationIdentifier];
        if (markerView == nil)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:GSAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            UIImage *markerImage = [UIImage imageNamed:@"marker_mid.png"];
            UIImage *logoImage = [UIImage imageNamed:gsn.gasStation.logo];
            // size the flag down to the appropriate size
            CGRect resizeRect;
            resizeRect.size = markerImage.size;
            CGSize maxSize = CGRectInset(self.view.bounds, kAnnotationPadding, kAnnotationPadding).size;
            
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + kCallOutHeight;
            
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = CGPointMake(0.0, 0.0);
            float initialWidth = resizeRect.size.width;
            
            UIGraphicsBeginImageContextWithOptions(resizeRect.size, NO, 0.0f);
            [markerImage drawInRect:resizeRect];

            
            resizeRect.size.width = resizeRect.size.width/1.75;
            resizeRect.size.height = resizeRect.size.height/1.75;
            
            resizeRect.origin.x = resizeRect.origin.x + (initialWidth - resizeRect.size.width)/2;
            resizeRect.origin.y = resizeRect.origin.y + kLogoHeightPadding;
            
            [logoImage drawInRect:resizeRect];
            
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
            annotationView.opaque = NO;
            
            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:gsn.gasStation.logo]];
            annotationView.leftCalloutAccessoryView = sfIconView;
            
            // offset the flag annotation so that the flag pole rests on the map coordinate
            //annotationView.centerOffset = CGPointMake( annotationView.centerOffset.x + annotationView.image.size.width/2, annotationView.centerOffset.y - annotationView.image.size.height/2 );
            
            // http://stackoverflow.com/questions/8165262/mkannotation-image-offset-with-custom-pin-image
            annotationView.centerOffset = CGPointMake(0,-annotationView.image.size.height/2);
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: when the detail disclosure button is tapped, we respond to it via:
            //       calloutAccessoryControlTapped delegate method
            //
            // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
            //
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
            
            return annotationView;
        }else
        {
            markerView.annotation = annotation;
            //TODO change logo
        }
        return markerView;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    polylineView.lineCap = kCGLineCapRound;
    
    return polylineView;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"OptionsSegue"]) {
        
        APOptionsViewController *optController = (APOptionsViewController *)[segue destinationViewController];
        optController.delegate = self;
        optController.cashAmount = self.cashAmount;
        
        //check if we have a valid current location
        if (self.srcAddress != nil){
            optController.srcAddr = self.srcAddress;
        }
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
