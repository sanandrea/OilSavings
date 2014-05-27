//
//  APTableViewCell.h
//  OilSavings
//
//  Created by Andi Palo on 5/28/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *friendlyName;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;

@end
