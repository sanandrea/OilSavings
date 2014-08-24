//
//  APPathDetailViewController.m
//  OilSavings
//
//  Created by Andi Palo on 7/20/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPathDetailViewController.h"
#import "APPathInfoCell.h"
#import "APGasStationInfoCell.h"
#import "APMapInfoCell.h"
#import "APFuelPriceCell.h"

#import "APGSAnnotation.h"

@interface APPathDetailViewController ()

@property (nonatomic, strong) NSArray *fuels;

@end

@implementation APPathDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fuels = [self.path.gasStation getAvailableFuelTypes];
}

#pragma mark - Tableview deledate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *gsCellIdentifier = @"GasStationInfo";
    static NSString *fpCellIdentifier = @"FuelPriceInfo";
    static NSString *piCellIdentifier = @"PathInfoCell";
    static NSString *miCellIdentifier = @"MapInfoCell";
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = (APGasStationInfoCell*) [tableView dequeueReusableCellWithIdentifier:gsCellIdentifier];
        [self customizeGSInfoCell:(APGasStationInfoCell*)cell];
    }else if (indexPath.section == 2){
        cell = (APPathInfoCell*) [tableView dequeueReusableCellWithIdentifier:piCellIdentifier];
        [self customizePathInfoCell:(APPathInfoCell*)cell];
    }else if (indexPath.section == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:miCellIdentifier];
        [self customizeMapCell:(APMapInfoCell*)cell];
    }else{
        cell = (APFuelPriceCell*) [tableView dequeueReusableCellWithIdentifier:fpCellIdentifier];
        [self customizeFuelPriceCell:(APFuelPriceCell*)cell atIndex:indexPath.row];
    }

    // Configure the cell.
//    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 61;
    }else if (indexPath.section == 2){
        return 36;
    }else if (indexPath.section == 3){
        return 151;
    }else{
        return 25;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Info Distributore", @"Prima sezione dettagli path");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Prezzi", @"Seconda sezione dettagli path");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Info Percorso", @"Terza sezione dettagli path");
            break;
        case 3:
            sectionName = NSLocalizedString(@"Mappa", @"Quarta sezione dettagli path");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [self.path.gasStation getNumberOfFuelsAvailable];
    }else{
        return 1;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

#pragma mark - Custom Cells Building

- (void) customizeMapCell:(APMapInfoCell*)cell{
    [cell.miniMap setDelegate:self];
    
    CLLocationCoordinate2D center;
    center.latitude = self.path.southWestBound.latitude + (self.path.northEastBound.latitude - self.path.southWestBound.latitude)/2;
    center.longitude = self.path.southWestBound.longitude + (self.path.northEastBound.longitude - self.path.southWestBound.longitude)/2;
    MKCoordinateSpan span;
    span.latitudeDelta = self.path.northEastBound.latitude - self.path.southWestBound.latitude;
    span.longitudeDelta = self.path.northEastBound.longitude - self.path.southWestBound.longitude;
    //    ALog("Map bounds SIZE: %f %f",self.miniMap.bounds.size.height, self.miniMap.bounds.size.width);
    
    //Make span a little bigger for annotations
    span.latitudeDelta = span.latitudeDelta + span.latitudeDelta * .4;
    span.longitudeDelta = span.longitudeDelta + span.longitudeDelta * .25;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [cell.miniMap setRegion:region];
    
    
    APGSAnnotation *annotation;
    
    annotation = [[APGSAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake(self.path.gasStation.position.latitude, self.path.gasStation.position.longitude)];
    annotation.gasStation = self.path.gasStation;
    [cell.miniMap addAnnotation:annotation];
    
    MKPointAnnotation *start = [[MKPointAnnotation alloc] init];
    [start setCoordinate:self.path.src];
    [start setTitle:@"Start"];
    [cell.miniMap addAnnotation:start];
    
    
    [cell.miniMap addOverlay:self.path.overallPolyline];
}

- (void) customizeGSInfoCell:(APGasStationInfoCell*)cell{
    cell.gsAddress.text = self.path.gasStation.street;
    cell.gsName.text = self.path.gasStation.name;
    cell.gsImage.image = [UIImage imageNamed:self.path.gasStation.logo];
}

- (void) customizePathInfoCell:(APPathInfoCell*)cell{
    int dist = [self.path getDistance];
    
    if (dist < 750) {
        cell.distanceValue.text = [NSString stringWithFormat:@"%d m", dist];
    } else {
        float distKM = dist / 1000;
        cell.distanceValue.text = [NSString stringWithFormat:@"%2.1f Km", distKM];
    }
    
    int time = [self.path getTime];
    cell.timeValue.text = [NSString stringWithFormat:@"%d min", (int)(time / 60)];
    
    cell.fuelValue.text = [NSString stringWithFormat:@"%4.2f Litri", [self.path calculatePathValueForEnergyType:self.path.gasStation.type]];
}


- (void)customizeFuelPriceCell:(APFuelPriceCell*)cell atIndex:(NSInteger)index{
    NSInteger fuelIndex = [[self.fuels objectAtIndex:index] intValue];

    cell.fuelLabel.text = [APConstants getEnergyLongNameForType:(ENERGY_TYPE)fuelIndex];
    cell.fuelPrice.text = [NSString stringWithFormat:@"%4.3f €/l",[self.path.gasStation getPrice:(ENERGY_TYPE)fuelIndex]];

}

#pragma mark - Action sheet

-(IBAction)goToMapApp:(id)sender{
    NSString *iosMaps = NSLocalizedString(@"Maps", @"Open location in ios maps");
    NSString *googleMaps = NSLocalizedString(@"Google Maps", @"Open location in google maps");

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Apri in", @"open in")
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:iosMaps,googleMaps,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    CLLocationCoordinate2D rdOfficeLocation = CLLocationCoordinate2DMake(31.20691,121.477847);
    if (buttonIndex==0) {
        //Apple Maps, using the MKMapItem class
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:rdOfficeLocation addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = @"ReignDesign Office";
        [item openInMapsWithLaunchOptions:nil];
    } else if (buttonIndex==1) {
        //Google Maps
        //construct a URL using the comgooglemaps schema
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",rdOfficeLocation.latitude,rdOfficeLocation.longitude]];
        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            NSLog(@"Google Maps app is not installed");
            //left as an exercise for the reader: open the Google Maps mobile website instead!
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
    
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark - Map interactions
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolyline *route = overlay;
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
    UIColor *color = [UIColor colorWithRed:((float) 137 / 255.0f)
                                     green:((float) 104 / 255.0f)
                                      blue:((float) 205 / 255.0f)
                                     alpha:.65f];
    renderer.strokeColor = color;
    renderer.lineWidth = 4.0;
    renderer.lineCap = kCGLineCapRound;
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[APGSAnnotation class]]){
        APGSAnnotation *gsn = (APGSAnnotation*) annotation;
        NSString *GSAnnotationIdentifier = [NSString stringWithFormat:@"gasStationIdentifier_%@", gsn.gasStation.name];
        
        MKAnnotationView *markerView = [theMapView dequeueReusableAnnotationViewWithIdentifier:GSAnnotationIdentifier];
        if (markerView == nil)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:GSAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            UIImage *markerImage;
            
            if (gsn.gasStation.type == kEnergyGasoline){
                markerImage = [UIImage imageNamed:@"marker_blue.png"];
            }else if (gsn.gasStation.type == kEnergyDiesel){
                markerImage = [UIImage imageNamed:@"marker_green.png"];
            }else if (gsn.gasStation.type == kEnergyGPL){
                markerImage = [UIImage imageNamed:@"marker_purple.png"];
            }else if (gsn.gasStation.type == kEnergyMethan){
                markerImage = [UIImage imageNamed:@"marker_brown.png"];
            }

            UIImage *logoImage = [UIImage imageNamed:gsn.gasStation.logo];
            // size the flag down to the appropriate size
            CGRect resizeRect;
            resizeRect.size = markerImage.size;
            CGSize maxSize = CGRectInset(theMapView.bounds, 10.f, 10.f).size;
            
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + 40.f;
            
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
            resizeRect.origin.y = resizeRect.origin.y + 14.f;
            
            [logoImage drawInRect:resizeRect];
            
            
            // Create string drawing context
            
            UIFont *font = [UIFont fontWithName:@"DBLCDTempBlack" size:8.0];
            NSString * num = [NSString stringWithFormat:@"%4.3f",[gsn.gasStation getPrice]];
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
            
            resizeRect.origin.y -= 10.f;
            [num drawWithRect:resizeRect
                      options:NSStringDrawingUsesLineFragmentOrigin
                   attributes:textAttributes
                      context:drawingContext];
            
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
