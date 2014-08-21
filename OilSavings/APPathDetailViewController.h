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

@property (nonatomic, strong) APPath *path;


@end
