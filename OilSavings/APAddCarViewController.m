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
static float kMoveUpOffset = 50;

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
    
    /* Works ok only for the problem that cannot select nothing in autocomplete
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    
    [self.view addGestureRecognizer:tap];
     */
}

- (void) dismissKeyboard
{
    [self.gasTankCapacity resignFirstResponder];
    [self.freindlyNameText resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*
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
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
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

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.tableView.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kMoveUpOffset;
        rect.size.height += kMoveUpOffset;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kMoveUpOffset;
        rect.size.height -= kMoveUpOffset;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
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
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

@end
