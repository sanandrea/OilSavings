//
//  APAddCarViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APAddCarViewController.h"
#import "APCar.h"

@interface APAddCarViewController ()

@property (nonatomic) BOOL brandSet;

@end

@implementation APAddCarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the undo manager and set editing state to YES.
    [self setUpUndoManager];
    self.editing = YES;
    
    self.brandSet = false;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ALog("Car brand is %@",self.car.brand);
    if (!self.brandSet) {
        //Disable click on model
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *modelCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        modelCell.userInteractionEnabled = NO;
    }
    if (self.car.brand != NULL && !self.brandSet) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *modelCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        modelCell.userInteractionEnabled = YES;
        self.brandSet = YES;
    }
}
- (IBAction)cancel:(id)sender
{
    [self.delegate addViewController:self didFinishWithSave:NO];
}


- (IBAction)save:(id)sender
{
    [self.delegate addViewController:self didFinishWithSave:YES];
}

/*
 Manage row selection: If a row is selected, create a new editing view controller to edit the property associated with the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.editing) {
        [self performSegueWithIdentifier:@"EditSelectedItem" sender:self];
    }
}


- (void)dealloc
{
    [self cleanUpUndoManager];
}

@end
