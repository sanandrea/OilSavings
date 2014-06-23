//
//  APGSTableViewCell.h
//  OilSavings
//
//  Created by Andi Palo on 6/23/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPath.h"

@interface APGSTableViewCell : UITableViewCell

@property (nonatomic, strong) APPath *path;
@property (nonatomic, weak) IBOutlet UIImageView *gsImage;
@property (nonatomic, weak) IBOutlet UILabel *gsAddress;
@property (nonatomic, weak) IBOutlet UILabel *gsBrand;
@property (nonatomic, weak) IBOutlet UILabel *gsPrice;
@property (nonatomic, weak) IBOutlet UILabel *gsDistance;
@property (nonatomic, weak) IBOutlet UILabel *gsTime;
@property (nonatomic, weak) IBOutlet UILabel *gsFuelRecharge;

@end
