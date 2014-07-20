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
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    
    ALog("Map bounds SPAN: %f %f  Center: %f %f",span.latitudeDelta, span.longitudeDelta, center.latitude, center.longitude);
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
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    polylineView.lineCap = kCGLineCapRound;
    
    return polylineView;
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
