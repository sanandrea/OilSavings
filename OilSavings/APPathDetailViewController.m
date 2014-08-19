//
//  APPathDetailViewController.m
//  OilSavings
//
//  Created by Andi Palo on 7/20/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APPathDetailViewController.h"
#import "APGSAnnotation.h"

@interface APPathDetailViewController ()

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
    [self.miniMap setDelegate:self];
    
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
    
    [self.miniMap setRegion:region];
    
    
    APGSAnnotation *annotation;
    
    annotation = [[APGSAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake(self.path.gasStation.position.latitude, self.path.gasStation.position.longitude)];
    annotation.gasStation = self.path.gasStation;
    [self.miniMap addAnnotation:annotation];
    
    MKPointAnnotation *start = [[MKPointAnnotation alloc] init];
    [start setCoordinate:self.path.src];
    [start setTitle:@"Start"];
    [self.miniMap addAnnotation:start];
    
    
    [self.miniMap addOverlay:self.path.overallPolyline];
    
    self.gsAddress.text = self.path.gasStation.street;
    self.gsName.text = self.path.gasStation.name;
    self.gsLogo.image = [UIImage imageNamed:self.path.gasStation.logo];
    
    self.distanceLabel.text = NSLocalizedString(@"Distanza", nil);
    int dist = [self.path getDistance];
    
    if (dist < 750) {
        self.distanceValue.text = [NSString stringWithFormat:@"%d m", dist];
    } else {
        float distKM = dist / 1000;
        self.distanceValue.text = [NSString stringWithFormat:@"%2.1f Km", distKM];
    }
    
    self.timeLabel.text = NSLocalizedString(@"Tempo", nil);
    int time = [self.path getTime];
    self.timeValue.text = [NSString stringWithFormat:@"%d min", (int)(time / 60)];
    
    self.priceLabel.text = NSLocalizedString(@"Prezzo", nil);
    self.priceValue.text = [NSString stringWithFormat:@"%4.3f €/l",[self.path.gasStation getPrice]];
    
}

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
