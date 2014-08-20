//
//  APFuelPriceCell.h
//  OilSavings
//
//  Created by Andi Palo on 8/20/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APFuelPriceCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *fuelImage;
@property (nonatomic, weak) IBOutlet UILabel *fuelLabel;
@property (nonatomic, weak) IBOutlet UILabel *fuelPrice;

@end
