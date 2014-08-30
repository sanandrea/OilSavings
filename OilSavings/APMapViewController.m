//
//  APMapViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APAddCarViewController.h"
#import "APAppDelegate.h"
#import "APDirectionsClient.h"
#import "APGasStation.h"
#import "APGasStationsTableVC.h"
#import "APGeocodeClient.h"
#import "APGSAnnotation.h"
#import "APMapViewController.h"
#import "APPathOptimizer.h"
#import "APPathDetailViewController.h"

#import "Chameleon.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "MKMapView+ZoomLevel.h"
#import "SIAlertView.h"
#import "SWRevealViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"
#import "APPinAnnotation.h"

#define ZOOM_LEVEL 14
static float kAnnotationPadding = 10.0f;
static float kCallOutHeight = 40.0f;
static float kLogoHeightPadding = 14.0f;
static float kTextPadding = 10.0f;

//When user taps on an annotation on Map we
//have to find path only for a single Gas Station
//PorkAround: put index of request to a high static value in order to distinguish it

static int RESOLVE_SINGLE_PATH = 99999;

@interface APMapViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSString *srcAddress;
@property (nonatomic, strong) NSString *dstAddress;

@property (nonatomic) CLLocationCoordinate2D srcCoord;
@property (nonatomic) CLLocationCoordinate2D dstCoord;
@property (nonatomic) CLLocationCoordinate2D myLocation;

@property (nonatomic) NSInteger cashAmount;
@property (nonatomic, strong) NSMutableArray *gasStations;
@property (nonatomic, strong) NSMutableArray *paths;

@property (nonatomic, strong) APPath *bestPath;
@property (nonatomic, strong) APPath *nearestPath;
@property (nonatomic) BOOL bestFound;

@property (nonatomic) BOOL usingGPS;

//how many directions requests are we making
@property (nonatomic) NSUInteger totalRequests;

//how many directions requests are processed
@property (nonatomic) int processedRequests;

@property (nonatomic, strong) APPathOptimizer *optimizer;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *centerMap;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *showGSButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *recalculate;


@end

@implementation APMapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Mappa";
    [self.mapView setDelegate:self];
    
    //Set all coordinates to invalid locations
    self.myLocation = emptyLocationCoordinate;
    self.srcCoord = emptyLocationCoordinate;
    self.dstCoord = emptyLocationCoordinate;
    
    
    //Disable Gas Stations List
    if ([self.gasStations count] == 0) {
        self.showGSButton.enabled = NO;
    }
    
    self.totalRequests = 0;
    self.processedRequests = 0;

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
    
    
    //Alloc paths array
    self.paths = [[NSMutableArray alloc] init];
    
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
    
    //now alloc optimizer
    self.optimizer = [[APPathOptimizer alloc] initWithCar:self.myCar cash:self.cashAmount andDelegate:self];
    
    //Use gps info
    self.usingGPS = YES;
    
    //begin listening location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    if ([locationManager location] !=nil) {
        [self centerMapInLocation:[locationManager location].coordinate animated:YES];
    }
    self.mapView.showsUserLocation = YES;
    
    //Progress
    [self.navigationController showProgress];
}


- (void) centerMapInLocation:(CLLocationCoordinate2D)loc animated:(BOOL)anime{
    [self.mapView setCenterCoordinate:loc zoomLevel:ZOOM_LEVEL animated:anime];
    
    [self findGasStations:loc];
    
    if (self.usingGPS) {
        //convert the address so the user has the address in the options VC
        [APGeocodeClient convertCoordinate:loc ofType:kAddressULocation inDelegate:self];        
    }
}
- (void) viewDidAppear:(BOOL)animated{
//    ALog("Map appeared");
//    if (self.myCar != nil) {
//        ALog("Car name is: %@", self.myCar.friendlyName);
//    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    CLLocation *newLocation = [locations lastObject];
    self.myLocation = newLocation.coordinate;
    
    
    //This is needed for the options view controller to display current src address
    if (!CLLocationCoordinate2DIsValid(self.srcCoord)) {
        self.srcCoord = self.myLocation;
    }
    if (self.usingGPS) {
        [self centerMapInLocation:self.myLocation animated:YES];
    }

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

#pragma mark - Reports

-(void)gaiReportKey:(NSString*)k withValue:(NSUInteger)v andLabel:(NSString*)l{
    // May return nil if a tracker has not yet been initialized with
    // a property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UserBehaviour"       // Event category (required)
                                                          action:k                      // Event action (required)
                                                           label:l                      // Event label
                                                           value:[NSNumber numberWithUnsignedLong:v]] build]];    // Event value
}

#pragma mark - UI Actions
- (IBAction)options:(id)sender{
    [self performSegueWithIdentifier: @"OptionsSegue" sender: self];
}

- (IBAction) gotoCurrentLocation:(id)sender{
    self.usingGPS = YES;
    [self removePin:kAddressSrc];
    [locationManager startUpdatingLocation];
}

- (IBAction) showGasStationList:(id)sender{
    
}

- (IBAction) optimizeAgain:(id)sender{
    if (self.gasStations == nil) {
        [self showWaitingForGPSSignal];
        return;
    }
    if ([self.gasStations count] == 0) {
        [self showNoGasStationsNearYou];
        return;
    }
    
    self.bestPath = nil;
    self.totalRequests = [self.gasStations count];
    self.processedRequests = 0;
    self.bestFound = NO;
    
    [self.paths removeAllObjects];
    
    CLLocationCoordinate2D origin = self.usingGPS ? self.myLocation : self.srcCoord;
    [self.optimizer optimizeRouteFrom:origin to:self.dstCoord withGasStations:self.gasStations];
    
    [self removePathOverlayOnMap];
}

- (void) carChanged{
    [self.optimizer changeCar:self.myCar];
    
    
    if (self.usingGPS) {
        [self findGasStations:self.myLocation];
    }else{
        [self findGasStations:self.srcCoord];
    }
    
    APGasStation *toBeReverted = self.bestPath.gasStation;
    
    [self.paths removeAllObjects];
    self.bestPath = nil;
    
    [self revertChosenGS:toBeReverted];
    
    //Disable Path List
    self.showGSButton.enabled = NO;
    
    [self removePathOverlayOnMap];
    
}

- (void) showNoGasStationsNearYou{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Ricerca", @"Ricerca")
                                                     andMessage:NSLocalizedString(@"Siamo spiacenti, ma non sono stati trovati distributori di carburante nelle vicinanze.", @"")];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button1 Clicked");
                          }];
    [alertView setTitleColor:[UIColor flatSkyBlueColorDark]];
    [alertView setMessageColor:[UIColor flatSkyBlueColorDark]];
    [alertView setButtonColor:[UIColor flatPowderBlueColor]];
    [alertView setViewBackgroundColor:[UIColor flatWhiteColor]];
    [alertView show];
}

- (void) showWaitingForGPSSignal{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"Attention")
                                                     andMessage:NSLocalizedString(@"In attesa della posizione corrente...", @"")];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"Cerca", @"Cerca posizione")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [self performSegueWithIdentifier:@"OptionsSegue" sender:self];
                          }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Attendi", @"Attendi")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              //Do nothing
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    
    [alertView setTitleColor:[UIColor flatSkyBlueColorDark]];
    [alertView setMessageColor:[UIColor flatSkyBlueColorDark]];
    
    [alertView setButtonColor:[UIColor flatPowderBlueColor]];
    [alertView setCancelButtonColor:[UIColor flatWhiteColor]];
    [alertView setViewBackgroundColor:[UIColor flatWhiteColor]];
    
    [alertView show];
}

- (void) showErrorHappened:(NSString*)message{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"Attention")
                                                     andMessage:message];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button1 Clicked");
                          }];
    [alertView setTitleColor:[UIColor flatBlackColor]];
    [alertView setMessageColor:[UIColor flatBlackColor]];
    [alertView setButtonColor:[UIColor flatBrownColorDark]];
    [alertView setViewBackgroundColor:[UIColor flatWhiteColor]];
    [alertView show];
    return;
}

#pragma mark - Network APIs

#pragma mark - Gas Stations

- (void) findGasStations:(CLLocationCoordinate2D) center{
    APGasStationClient *gs = [[APGasStationClient alloc] initWithCenter:center andFuel:[self.myCar.energy intValue]];
    gs.delegate = self;
    [gs getStations];
}

- (void) gasStation:(APGasStationClient*)gsClient didFinishWithStations:(BOOL) newStations{
    if (newStations) {
        
        if ([self.gasStations count] > 0) {
            NSMutableArray *toBeDeleted = [[NSMutableArray alloc]init];
            
            for (APGasStation *oldGS in self.gasStations) {
                if (![gsClient.gasStations containsObject:oldGS]) {
                    [toBeDeleted addObject:oldGS];
                }
            }
            
            self.gasStations = gsClient.gasStations;
            
            
            //remove any existing pin.
            [self removeAllPinsExcept:toBeDeleted];
        }
        
        APGSAnnotation *annotation;
        for (APGasStation *gs in gsClient.gasStations) {
            annotation = [[APGSAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake(gs.position.latitude, gs.position.longitude)];
            annotation.gasStation = gs;
            [self.mapView addAnnotation:annotation];
        }
        self.gasStations = gsClient.gasStations;
        
        if ([self.gasStations count] > 0) {
            //check if at least one Gas Station is visible
            [self checkIfAreVisibleGasStations];
        }else{
            [self showNoGasStationsNearYou];
        }
    }else{
        [self showErrorHappened:NSLocalizedString(@"Errore generico nei sistemi", @"")];
    }
    
}

#pragma mark - Geocoding Convertions Protocol

- (void) convertedAddressType:(ADDRESS_TYPE)type to:(CLLocationCoordinate2D)coord error:(NSError *)er{
    if (er != nil) {
        [self showErrorHappened:[er localizedDescription]];
        return;
    }
    NSString *address;
    ALog("Address converted");
    if (type == kAddressSrc) {
        self.srcCoord = coord;
        address = self.srcAddress;
        [self centerMapInLocation:coord animated:YES];
    }else{
        ALog("It is destination");
        address = self.dstAddress;
        self.dstCoord = coord;
    }

    [self addOrUpdatePin:type atLocation:coord withAddress:address];

}

- (void) convertedCoordinateType:(ADDRESS_TYPE)type to:(NSString*) address error:(NSError *)er{
    if (er != nil) {
        [self showErrorHappened:[er localizedDescription]];
        return;
    }
    if (type == kAddressSrc) {
        self.srcAddress = address;
    }else if (type == kAddressULocation){
        self.srcAddress = address;
    }else{
        self.dstAddress = address;
    }
}

#pragma mark - Path Available
- (void) foundPath:(APPath*)path withIndex:(NSInteger)index error:(NSError *)er{
    if (er != nil) {
#warning todo
        return;
    }
    
    //User clicked on annotation
    if (index == RESOLVE_SINGLE_PATH) {
        self.bestPath = path;
        path.car = self.myCar;
        path.import = self.cashAmount;
        [self performSegueWithIdentifier:@"SinglePathDetail" sender:self];
        return;
    }
    
    //Add to path array
    [self.paths addObject:path];
    
    [path setTheCar:self.myCar];
    [path setTheImport:self.cashAmount];

    if ([path compareFuelPath:self.bestPath] == NSOrderedAscending){
        self.bestPath = path;
        self.bestFound = YES;
//        ALog("Found best path");
    }
    self.processedRequests ++;
    
    [self.navigationController setProgress:((float)self.processedRequests/self.totalRequests) animated:YES];
    
    if (self.processedRequests == self.totalRequests){
        [self.navigationController finishProgress];
        
        //Highlight bestGasStation
        [self setChosenGSRed:self.bestPath.gasStation];
        
        //Center map in to include all path
        [self resizeMapToDiagonalPoints:self.bestPath.southWestBound :self.bestPath.northEastBound];
    }


    if (((self.processedRequests % REQUEST_BUNDLE == 0)||(self.processedRequests == self.totalRequests)) && self.bestFound) {
//        ALog("Desing path on map");

        //Enable Gas Stations List
        self.showGSButton.enabled = YES;

        //remove existing overlay if any
        NSArray *pointsArray = [self.mapView overlays];
        if ([pointsArray count] > 0) {
            [self.mapView removeOverlays:pointsArray];
        }
        
        //Add new polyline
        [self.mapView addOverlay:self.bestPath.overallPolyline];
    }
}

-(void)resolveSinglePath:(APGasStation*)gasStation{
    APPath *path;
    if (CLLocationCoordinate2DIsValid(self.dstCoord)) {
        path = [[APPath alloc]initWith:self.srcCoord and:self.dstCoord andGasStation:gasStation];
        path.hasDestination = YES;
    }else{
        path = [[APPath alloc]initWith:self.srcCoord andGasStation:gasStation];
    }
    
    [APDirectionsClient findDirectionsOfPath:path indexOfRequest:RESOLVE_SINGLE_PATH delegateTo:self];
    
}


#pragma mark - Options Protocol
- (void)optionsController:(APOptionsViewController*) controller didfinishWithSave:(BOOL)save{
    if (save) {
        
        if (([controller.srcAddr length] > 0) && ![controller.srcAddr isEqualToString:self.srcAddress]) {
            self.srcAddress = controller.srcAddr;
            [APGeocodeClient convertAddress:self.srcAddress ofType:kAddressSrc inDelegate:self];
            self.usingGPS = NO;
            [self removePathOverlayOnMap];
        }
        
        
        if (([controller.dstAddr length] > 0) && ![self.dstAddress isEqualToString:controller.dstAddr]) {
            self.dstAddress = controller.dstAddr;
            [APGeocodeClient convertAddress:self.dstAddress ofType:kAddressDst inDelegate:self];
            [self removePathOverlayOnMap];
        }
        
        if ([controller.dstAddr length] == 0) {
            self.dstAddress = nil;
            self.dstCoord = emptyLocationCoordinate;
            
            //Remove pin if any
            [self removePin:kAddressDst];
            
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
        ALog("clicked Annotation");
        
        [self resolveSinglePath:((APGSAnnotation*)annotation).gasStation];
        /*
        APGSAnnotation *gsn = (APGSAnnotation*) annotation;
        [APGasStationClient getDetailsOfGasStation:gsn.gasStation intoDict:nil];
        */
    }
    
//    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    if ([annotation isKindOfClass:[APGSAnnotation class]]){
        APGSAnnotation *gsn = (APGSAnnotation*) annotation;
        NSString *GSAnnotationIdentifier = [NSString stringWithFormat:@"gid_%lu", (unsigned long)gsn.gasStation.gasStationID];
        
        MKAnnotationView *markerView = [theMapView dequeueReusableAnnotationViewWithIdentifier:GSAnnotationIdentifier];
        if (markerView == nil) {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:GSAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            
            annotationView.image = [self customizeAnnotationImage:gsn.gasStation];
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
        }else{
            markerView.annotation = annotation;
            //TODO change logo
        }
        return markerView;
    } else if ([annotation isKindOfClass:[APPinAnnotation class]]){
        APPinAnnotation *pin = (APPinAnnotation*) annotation;
        NSString *pinID = [NSString stringWithFormat:@"pin_%d",(pin.type == kAddressSrc) ? 1 : 2];
        MKAnnotationView *markerPin = [theMapView dequeueReusableAnnotationViewWithIdentifier:pinID];
        if (markerPin == nil) {
            MKPinAnnotationView *result = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                          reuseIdentifier:pinID];
            if (pin.type == kAddressSrc) {
                result.pinColor = MKPinAnnotationColorGreen;
            }
            result.canShowCallout = YES;
            return result;
        }else{
            markerPin.annotation = annotation;
        }
        return markerPin;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolyline *route = overlay;
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
    UIColor *color = [UIColor colorWithRed:((float) 137 / 255.0f)
                                     green:((float) 104 / 255.0f)
                                      blue:((float) 205 / 255.0f)
                                     alpha:.65f];
    renderer.strokeColor = color;
    renderer.lineWidth = 5.0;
    renderer.lineCap = kCGLineCapRound;
    return renderer;
}

//removes all annotations except user location
- (void)removeAllPinsExcept:(NSArray*)toBeDeletedPins{
    NSMutableArray *pins = [[NSMutableArray alloc] init];

    for (id gsAnnotation in [self.mapView annotations]) {
        //skip user location
        if ([gsAnnotation isKindOfClass:[APGSAnnotation class]]) {
            if ([toBeDeletedPins containsObject:((APGSAnnotation*)gsAnnotation).gasStation]) {
                [pins addObject:gsAnnotation];
            }
        }else{
            continue;
        }
    }
    
//    id userLocation = [self.mapView userLocation];
//    if ( userLocation != nil ) {
//        [pins removeObject:userLocation]; // avoid removing user location off the map
//    }
    [self.mapView removeAnnotations:pins];
}

- (void)setChosenGSRed:(APGasStation *)gs{
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        if ([annotation isKindOfClass:[APGSAnnotation class]]){
            
            APGSAnnotation *agn = (APGSAnnotation*) annotation;
            if (agn.gasStation.gasStationID == gs.gasStationID) {
                MKAnnotationView* anView = [self.mapView viewForAnnotation: annotation];
                anView.image = [self customizeAnnotationImage:agn.gasStation];
            }

        }
    }
}

- (void)revertChosenGS:(APGasStation *)gs{
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        if ([annotation isKindOfClass:[APGSAnnotation class]]){
            
            APGSAnnotation *agn = (APGSAnnotation*) annotation;
            if (agn.gasStation.gasStationID == gs.gasStationID) {
                MKAnnotationView* anView = [self.mapView viewForAnnotation: annotation];
                anView.image = [self customizeAnnotationImage:agn.gasStation];
            }
            
        }
    }
}

- (void) addOrUpdatePin:(ADDRESS_TYPE)type atLocation:(CLLocationCoordinate2D)coord withAddress:(NSString*)address{
    APPinAnnotation *desiredPin = nil;
    for (id<MKAnnotation> pin  in [self.mapView annotations]) {
        
        if ([pin isKindOfClass:[APPinAnnotation class]]) {
            if (((APPinAnnotation*)pin).type == type) {
                desiredPin = pin;
                break;
            }
        }
    }
    
    if (desiredPin == nil) {
        APPinAnnotation *pin = [[APPinAnnotation alloc] initWithLocation:coord];
        pin.address = address;
        pin.type = type;
        [self.mapView addAnnotation:pin];
    }else{
        desiredPin.coordinate = coord;
        desiredPin.address = address;
    }
}

- (void) removePin:(ADDRESS_TYPE)type{
    for (id<MKAnnotation> pin  in [self.mapView annotations]) {
        
        if ([pin isKindOfClass:[APPinAnnotation class]]) {
            if (((APPinAnnotation*)pin).type == type) {
                [self.mapView removeAnnotation:pin];
                return;
            }
        }
    }
}

- (void)removePathOverlayOnMap{
    //remove existing overlay if any
    NSArray *pointsArray = [self.mapView overlays];
    if ([pointsArray count] > 0) {
        [self.mapView removeOverlays:pointsArray];
    }
}

- (UIImage*)customizeAnnotationImage:(APGasStation*)gasStation{
    UIImage *markerImage;
    
    if (gasStation.gasStationID == self.bestPath.gasStation.gasStationID) {
        markerImage = [UIImage imageNamed:@"marker_red.png"];
    }else if (gasStation.type == kEnergyGasoline){
        markerImage = [UIImage imageNamed:@"marker_blue.png"];
    }else if (gasStation.type == kEnergyDiesel){
        markerImage = [UIImage imageNamed:@"marker_green.png"];
    }else if (gasStation.type == kEnergyGPL){
        markerImage = [UIImage imageNamed:@"marker_purple.png"];
    }else if (gasStation.type == kEnergyMethan){
        markerImage = [UIImage imageNamed:@"marker_brown.png"];
    }
    UIImage *logoImage = [UIImage imageNamed:gasStation.logo];
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
    resizeRect.size.width = resizeRect.size.width/2;
    resizeRect.size.height = resizeRect.size.height/2;
    
    resizeRect.origin.x = resizeRect.origin.x + (initialWidth - resizeRect.size.width)/2;
    resizeRect.origin.y = resizeRect.origin.y + kLogoHeightPadding;
    
    [logoImage drawInRect:resizeRect];
    
    
    // Create string drawing context
    UIFont *font = [UIFont fontWithName:@"DBLCDTempBlack" size:11.2];
    NSString * num = [NSString stringWithFormat:@"%4.3f",[gasStation getPrice]];
    NSDictionary *textAttributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    CGSize textSize = [num sizeWithAttributes:textAttributes];
    
    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    
    //adjust center
    if (resizeRect.size.width - textSize.width > 0) {
        resizeRect.origin.x += (resizeRect.size.width - textSize.width)/2;
    }else{
        resizeRect.origin.x -= (resizeRect.size.width - textSize.width)/2;
    }
    
    resizeRect.origin.y -= kTextPadding;
    [num drawWithRect:resizeRect
              options:NSStringDrawingUsesLineFragmentOrigin
           attributes:textAttributes
              context:drawingContext];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (void) checkIfAreVisibleGasStations{
    CLLocationCoordinate2D center = self.usingGPS ? self.myLocation : self.srcCoord;
    
    if (! CLLocationCoordinate2DIsValid(center)) {
        //no info about position yet
        return;
    }
    
    //There is at least one Gas Station
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleMapRect];
    
    APGasStation *nearest;
    CGFloat bestDistance = 999999.f;
    if ([visibleAnnotations count] == 0) {
        for (APGasStation *gs in self.gasStations) {
            CGFloat curDst = [APConstants haversineDistance:center.latitude
                                                           :center.longitude
                                                           :gs.position.latitude
                                                           :gs.position.longitude];
            if (curDst < bestDistance) {
                bestDistance = curDst;
                nearest = gs;
            }
        }
        
        [self resizeMapToIncludePoint:nearest.position];
    }
}

- (void)resizeMapToIncludePoint:(CLLocationCoordinate2D) point{
    //Create a new span that contains this gs plus 15% bigger
    MKCoordinateSpan span;
    CLLocationCoordinate2D center = self.usingGPS ? self.myLocation : self.srcCoord;
    
    span.latitudeDelta = (center.latitude - point.latitude) * 2.3f;
    if (span.latitudeDelta < 0) {
        span.latitudeDelta = - span.latitudeDelta;
    }
    span.longitudeDelta = (center.longitude - point.longitude) * 2.3f;
    if (span.longitudeDelta < 0) {
        span.longitudeDelta = - span.longitudeDelta;
    }
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
}

- (void) resizeMapToDiagonalPoints:(CLLocationCoordinate2D)sw :(CLLocationCoordinate2D)ne{
    CLLocationCoordinate2D center;
    center.latitude = sw.latitude + (ne.latitude - sw.latitude)/2;
    center.longitude = sw.longitude + (ne.longitude - sw.longitude)/2;
    MKCoordinateSpan span;
    span.latitudeDelta = ne.latitude - sw.latitude;
    span.longitudeDelta = ne.longitude - sw.longitude;
    
    //Make span a little bigger for annotations
    span.latitudeDelta = span.latitudeDelta + span.latitudeDelta * .4;
    span.longitudeDelta = span.longitudeDelta + span.longitudeDelta * .25;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"OptionsSegue"]) {
        
        APOptionsViewController *optController = (APOptionsViewController *)[segue destinationViewController];
        optController.delegate = self;
        optController.cashAmount = self.cashAmount;
        
        //check if we have a valid current location
        if (self.srcAddress != nil){
            optController.srcAddr = self.srcAddress;
        }
        if (CLLocationCoordinate2DIsValid(self.dstCoord)) {
            optController.dstAddr = self.dstAddress;
        }
    }else if ([[segue identifier] isEqualToString:@"showGSTable"]){
        APGasStationsTableVC *tableGS = (APGasStationsTableVC *)[segue destinationViewController];
        tableGS.gasPaths = self.paths;
        tableGS.sortType = kSortRandom;
        
    }else if ([[segue identifier] isEqualToString:@"SinglePathDetail"]){
        APPathDetailViewController *pathDetailVC = (APPathDetailViewController*)[segue destinationViewController];
        pathDetailVC.path = self.bestPath;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
