// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
@property (nonatomic, weak) IBOutlet UILabel *gsBrand;

@property (nonatomic, weak) IBOutlet UILabel *gsAddress;
@property (nonatomic, weak) IBOutlet UILabel *gsCAP;


@property (nonatomic, weak) IBOutlet UILabel *gsPrice;
@property (nonatomic, weak) IBOutlet UILabel *gsMillesimal;

@property (nonatomic, weak) IBOutlet UILabel *gsDistance;
@property (nonatomic, weak) IBOutlet UILabel *gsFuelRecharge;

@property (nonatomic, weak) IBOutlet UILabel *gsTimeString;
@property (nonatomic, weak) IBOutlet UILabel *gsTime;

@end
