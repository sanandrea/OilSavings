//
//  APAddCarViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APAddCarViewController.h"

@implementation APAddCarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the undo manager and set editing state to YES.
    [self setUpUndoManager];
    self.editing = YES;
}


- (IBAction)cancel:(id)sender
{
    [self.delegate addViewController:self didFinishWithSave:NO];
}


- (IBAction)save:(id)sender
{
    [self.delegate addViewController:self didFinishWithSave:YES];
}


- (void)dealloc
{
    [self cleanUpUndoManager];
}


@end
