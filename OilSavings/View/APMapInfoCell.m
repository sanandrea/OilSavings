//
//  APMapInfoCell.m
//  OilSavings
//
//  Created by Andi Palo on 8/21/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APMapInfoCell.h"

@implementation APMapInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
