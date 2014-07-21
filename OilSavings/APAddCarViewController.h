//
//  APAddCarViewController.h
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APInfoCarViewController.h"
#import "TRAutocompleteView.h"

@protocol AddViewControllerDelegate;

@interface APAddCarViewController : UITableViewController<UISearchBarDelegate>{
    TRAutocompleteView *_autocompleteBrand;
    TRAutocompleteView *_autocompleteModel;
}


@property (nonatomic, weak) id <AddViewControllerDelegate> delegate;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) APCar *car;
@end

@protocol AddViewControllerDelegate
- (void)addViewController:(APAddCarViewController *)controller didFinishWithSave:(BOOL)save;
@end