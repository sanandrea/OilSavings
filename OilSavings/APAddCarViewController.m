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
@property (nonatomic, weak) IBOutlet UILabel *selectEnergyLabel;
@property (nonatomic, weak) IBOutlet UILabel *gasCapacityLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic) BOOL modelSet;
@property (nonatomic) BOOL nameSet;
@property (nonatomic) BOOL gasCapSet;
@property (nonatomic, strong) NSDictionary *source;

@end

@implementation APAddCarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.brandSearch.placeholder = NSLocalizedString(@"Marca", @"Brand Car Placeholder");
    self.modelSearch.placeholder = NSLocalizedString(@"Modello", @"Model for car model");
    [self.brandSearch setDelegate:self];
    [self.modelSearch setDelegate:self];

    [self.energyTypeSelect setTitle:NSLocalizedString(@"Benzina", nil) forSegmentAtIndex:0];
    [self.energyTypeSelect setTitle:NSLocalizedString(@"Gasolio", nil) forSegmentAtIndex:1];
    [self.energyTypeSelect setTitle:NSLocalizedString(@"Metano", nil) forSegmentAtIndex:2];
    [self.energyTypeSelect setTitle:NSLocalizedString(@"GPL", nil) forSegmentAtIndex:3];

    self.saveButton.enabled = NO;
    
    //When done is pressed dismiss keyboard
    [self.gasTankCapacity addTarget:self
                       action:@selector(dismissKeyboard)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.freindlyNameText addTarget:self
                             action:@selector(userEnteredName)
                   forControlEvents:UIControlEventEditingDidEndOnExit];

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
    
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return NSLocalizedString(@"AUTO", @"Titolo prima sezione tabella aggiungi auto");
    }
    if (section == 1){
        return NSLocalizedString(@"DETTAGLI", @"Titolo seconda sezione tabella aggiungi auto");
    }
    return @"";
}

- (void) dismissKeyboard
{
    if ([self.brandSearch.text length] == 0) {
        [self.brandSearch resignFirstResponder];
    }
    if ([self.modelSearch.text length] == 0) {
        [self.modelSearch resignFirstResponder];
    }
    [self.gasTankCapacity resignFirstResponder];
    [self.freindlyNameText resignFirstResponder];
}
- (void) userEnteredName{
    if ([self.freindlyNameText.text length] > 0) {
        ALog("Name was set");
        self.nameSet = YES;
        [self checkifCanSave];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        if (searchBar == self.brandSearch){
            [_autocompleteBrand hidesuggestions];
            [_brandSearch endEditing:YES];
        }else{
            [_autocompleteModel hidesuggestions];
            [_modelSearch endEditing:YES];
        }
    }
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if (searchBar == self.modelSearch && [self.modelSearch.text length] > 0) {
        self.source = [APCarDBAutoCompleteItemsSource getIDForCarModel:self.modelSearch.text];
        ALog("Dict is %@",self.source);
        [self.energyTypeSelect setSelectedSegmentIndex:[[self.source objectForKey:@"energy"] intValue]];
        self.modelSet = YES;
        [self checkifCanSave];
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

- (void) checkifCanSave{
    if (self.nameSet && self.modelSet) {
        self.saveButton.enabled = YES;
    }
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addViewController:self didFinishWithSave:NO];
}


- (IBAction)save:(id)sender
{
    self.car.friendlyName = self.freindlyNameText.text;
    self.car.modelID = [self.source objectForKeyedSubscript:@"id"];
    self.car.energy = [NSNumber numberWithInt:[self.energyTypeSelect selectedSegmentIndex]];

    self.car.pA = [self.source objectForKey:@"pA"];
    self.car.pB = [self.source objectForKey:@"pB"];
    self.car.pC = [self.source objectForKey:@"pC"];
    self.car.pD = [self.source objectForKey:@"pD"];

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
