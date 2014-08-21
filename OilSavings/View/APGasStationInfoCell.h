//
//  APGasStationInfoCell.h
//  OilSavings
//
//  Created by Andi Palo on 8/21/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APGasStationInfoCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *gsImage;
@property (nonatomic, weak) IBOutlet UILabel *gsAddress;
@property (nonatomic, weak) IBOutlet UILabel *gsName;
@end
