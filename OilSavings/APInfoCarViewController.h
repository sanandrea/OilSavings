//
//  APInfoCarViewController.h
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>


@class APCar;

@interface APInfoCarViewController : UITableViewController

@property (nonatomic, strong) APCar *car;

@end


@interface APInfoCarViewController (Private)

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end
