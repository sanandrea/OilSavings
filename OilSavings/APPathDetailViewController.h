//
//  APPathDetailViewController.h
//  OilSavings
//
//  Created by Andi Palo on 7/20/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "APPath.h"

@interface APPathDetailViewController : UITableViewController<MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *gsLogo;
@property (nonatomic, weak) IBOutlet UILabel *gsName;
@property (nonatomic, weak) IBOutlet UILabel *gsAddress;
@property (nonatomic, weak) IBOutlet MKMapView *miniMap;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceValue;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceValue;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeValue;

@property (nonatomic, strong) APPath *path;


@end
