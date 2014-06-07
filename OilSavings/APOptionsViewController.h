//
//  APOptionsViewController.h
//  OilSavings
//
//  Created by Andi Palo on 6/4/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRAutocompleteView.h"
#import "APGeocodeClient.h"

@protocol OptimizationOptions;


@interface APOptionsViewController : UIViewController<UISearchBarDelegate>{
    TRAutocompleteView *_autocompleteSrc;
    TRAutocompleteView *_autocompleteDst;
}

@property (nonatomic, weak) id<OptimizationOptions> delegate;
@property (nonatomic, strong) NSString *srcAddr;
@property (nonatomic, strong) NSString *dstAddr;
@property (nonatomic) NSInteger cashAmount;

@end

@protocol OptimizationOptions

- (void)optionsController:(APOptionsViewController*) controller didfinishWithSave:(BOOL)save;

@end