//
//  APGasStationsTableVC.h
//  OilSavings
//
//  Created by Andi Palo on 6/23/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APGasStationsTableVC : UITableViewController <UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *gasPaths;
@property (nonatomic) SORT_TYPE sortType;

- (IBAction)sortByPrice:(id)sender;
- (IBAction)sortByDistance:(id)sender;
- (IBAction)sortByTime:(id)sender;
- (IBAction)sortByFuel:(id)sender;


@end
