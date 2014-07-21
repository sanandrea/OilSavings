//
//  APAddCarViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APAddCarViewController.h"
#import "APCar.h"
#import "APCarDBAutoCompleteItemsSource.h"

//Using GoogleAutocomplete cellfactory
#import "TRGoogleMapsAutocompletionCellFactory.h"

static float kLeftSearchBarPadding = 31;

@interface APAddCarViewController ()

@property (nonatomic) BOOL brandSet;
@property (nonatomic, weak) IBOutlet UISearchBar *brandSearch;
@property (nonatomic, weak) IBOutlet UISearchBar *modelSearch;
@property (nonatomic, weak) IBOutlet UITextField *freindlyNameText;

@property (nonatomic, weak) IBOutlet UISegmentedControl *energyTypeSelect;
@property (nonatomic, weak) IBOutlet UITextField *gasTankCapacity;


@end

@implementation APAddCarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.editing = YES;
    
//    self.brandSet = false;
    UITextField* txt;
    for (UIView *subView in self.brandSearch.subviews){
        for (UIView *secView in subView.subviews){
            if ([secView isKindOfClass:[UITextField class]])
            {
                txt = (UITextField *)secView;
                break;
            }
        }
    }
    _autocompleteBrand = [TRAutocompleteView autocompleteViewBindedTo:txt
                                                        havingSpace:kLeftSearchBarPadding
                                                          usingSource:[[APCarDBAutoCompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 andFieldType:kBrandEdit]
                                                        cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                       presentingIn:self];
    for (UIView *subView in self.modelSearch.subviews){
        for (UIView *secView in subView.subviews){
            if ([secView isKindOfClass:[UITextField class]])
            {
                txt = (UITextField *)secView;
                break;
            }
        }
    }
    _autocompleteModel = [TRAutocompleteView autocompleteViewBindedTo:txt
                                                        havingSpace:kLeftSearchBarPadding
                                                        usingSource:[[APCarDBAutoCompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 andFieldType:kModelEdit]
                                                        cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                       presentingIn:self];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    
    [self.view addGestureRecognizer:tap];
    
    CGRect rect = [self.modelSearch convertRect:self.modelSearch.frame fromView:self.tableView];
    [self.tableView scrollRectToVisible:rect animated:YES];
    ALog("Origin is %f %f", rect.origin.x, rect.origin.y);
}

- (void) dismissKeyboard
{
    // add self
    [self.brandSearch resignFirstResponder];
    [self.modelSearch resignFirstResponder];
    [self.gasTankCapacity resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
//    ALog("Car brand is %@",self.car.brand);
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

#pragma mark - Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchText length] == 0) {
        ALog("Canceled");
        if (searchBar == self.brandSearch){
            [_autocompleteBrand hidesuggestions];
            [_brandSearch endEditing:YES];
        }else{
            [_autocompleteModel hidesuggestions];
            [_modelSearch endEditing:YES];
        }
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

@end
