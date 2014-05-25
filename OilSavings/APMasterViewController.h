//
//  APMasterViewController.h
//  OilSavings
//
//  Created by Andi Palo on 5/23/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APDetailViewController;

#import <CoreData/CoreData.h>

@interface APMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) APDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
