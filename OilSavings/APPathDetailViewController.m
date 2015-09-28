// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
#import "APPinAnnotation.h"

#import "SIAlertView.h"
#import "Chameleon.h"
#import "MKMapView+ZoomLevel.h"

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
    
    MKCoordinateRegion givenRect = MKCoordinateRegionForMapRect([self.path.overallPolyline boundingMapRect]);
    [cell.miniMap setRegion:[cell.miniMap zoomMapRegion:givenRect inScale:1.4f] animated:YES];
    
    
    APGSAnnotation *annotation;
    
    annotation = [[APGSAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake(self.path.gasStation.position.latitude, self.path.gasStation.position.longitude)];
    annotation.gasStation = self.path.gasStation;
    [cell.miniMap addAnnotation:annotation];
    
    
    APPinAnnotation *pin = [[APPinAnnotation alloc] initWithLocation:self.path.src];
    pin.type = kAddressSrc;
    [cell.miniMap addAnnotation:pin];
    
    if (self.path.hasDestination) {
        APPinAnnotation *dst = [[APPinAnnotation alloc] initWithLocation:self.path.dst];
        dst.type = kAddressDst;
        [cell.miniMap addAnnotation:dst];
    }
    
    
    [cell.miniMap addOverlay:self.path.overallPolyline];
    if (self.path.hasDestination) {
        [cell.miniMap addOverlay:self.path.secondaryPolyline];
    }
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
    cell.fuelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"barrel_%@",
                                                [APConstants getEnergyStringForType:(ENERGY_TYPE) fuelIndex]]];

}

#pragma mark - Action sheet

-(IBAction)goToMapApp:(id)sender{
    [self congratulateUser];
}

- (void)openActionsSheet{
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
- (void) congratulateUser{
    ALog("Risparmi %f %f",self.path.savingRespectCheapest, self.path.savingRespectNearest);
    
    if (self.path.savingRespectNearest > 0 || self.path.savingRespectCheapest > 0) {
        
        NSString *userMessage;
        NSString *stringB = [NSString stringWithFormat:@"Con questo percorso risparmi %3.2f€ rispetto al distributore con il prezzo più basso",self.path.savingRespectCheapest];
        NSString *stringA = [NSString stringWithFormat:@"Con questo percorso risparmi %3.2f€ rispetto al distributore più vicino in linea d'aria ",self.path.savingRespectNearest];
        
        if (self.path.savingRespectNearest > self.path.savingRespectCheapest) {
            userMessage = NSLocalizedString(stringA, nil);
        }else{
           userMessage = NSLocalizedString(stringB, nil);
        }
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Complimenti", @"Complimenti")
                                                         andMessage:userMessage];
        
        [alertView addButtonWithTitle:NSLocalizedString(@"Buon viaggio", "Buon viaggio")
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [self openActionsSheet];
                              }];
        [alertView setTitleColor:[UIColor flatSkyBlueColorDark]];
        [alertView setMessageColor:[UIColor flatSkyBlueColorDark]];
        [alertView setButtonColor:[UIColor flatPowderBlueColor]];
        [alertView setViewBackgroundColor:[UIColor flatWhiteColor]];
        [alertView show];
    }else{
        [self openActionsSheet];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    CLLocationCoordinate2D destination;
    
    
    if (self.path.hasDestination) {
        destination = self.path.dst;
    }else{
        destination = self.path.gasStation.position;
    }
    
    if (buttonIndex==0) {
        //Apple Maps, using the MKMapItem class
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = self.path.gasStation.name;
        
        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
        [item openInMapsWithLaunchOptions:options];
    } else if (buttonIndex==1) {
        //Google Maps
        //construct a URL using the comgooglemaps schema
        NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",self.path.src.latitude, self.path.src.longitude, destination.latitude, destination.longitude];
        
        if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:googleMapsURLString]]) {
            NSLog(@"Google Maps app is not installed");
            //left as an exercise for the reader: open the Google Maps mobile website instead!
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
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
    }else if ([annotation isKindOfClass:[APPinAnnotation class]]){
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
