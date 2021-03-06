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

int SLIDER_MAX = 100;
int SLIDER_MIN = 20;
int SLIDER_STEP = 5;


@interface APAddCarViewController ()

@property (nonatomic, weak) IBOutlet UISearchBar *brandSearch;
@property (nonatomic, weak) IBOutlet UISearchBar *modelSearch;
@property (nonatomic, weak) IBOutlet UITextField *freindlyNameText;

@property (nonatomic, weak) IBOutlet UISegmentedControl *energyTypeSelect;
@property (nonatomic, weak) IBOutlet UISlider *gasTankCapacity;
@property (nonatomic, weak) IBOutlet UILabel *selectEnergyLabel;
@property (nonatomic, weak) IBOutlet UILabel *gasCapacityLabel;

@property (nonatomic, weak) IBOutlet UILabel *gasTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *tankCapacityTilte;
@property (nonatomic, weak) IBOutlet UILabel *tankCapacityValue;

@property (nonatomic, weak) IBOutlet UITextField *urbanConsumption;
@property (nonatomic, weak) IBOutlet UITextField *extraUrbanConsumption;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic) BOOL brandSet;
@property (nonatomic) BOOL modelSet;
@property (nonatomic) BOOL nameSet;
@property (nonatomic) BOOL gasCapSet;
@property (nonatomic, strong) NSDictionary *source;

@property (nonatomic, strong) APCarDBAutoCompleteItemsSource *itemSource;

@end

@implementation APAddCarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.brandSearch.placeholder = NSLocalizedString(@"Marca", @"Brand Car Placeholder");
    self.modelSearch.placeholder = NSLocalizedString(@"Modello", @"Model for car model");
    self.selectEnergyLabel.text = NSLocalizedString(@"Carburante", @"Segmented Control Title");
    self.tankCapacityTilte.text = NSLocalizedString(@"Serbatoio", @"Title of slider for tank capacity");
    
    [self.brandSearch setDelegate:self];
    [self.modelSearch setDelegate:self];

    [self.energyTypeSelect setTitle:NSLocalizedString(@"Benzina", nil) forSegmentAtIndex:0];
    [self.energyTypeSelect setTitle:NSLocalizedString(@"Gasolio", nil) forSegmentAtIndex:1];
    [self.energyTypeSelect setTitle:NSLocalizedString(@"Metano", nil) forSegmentAtIndex:2];
    [self.energyTypeSelect setTitle:NSLocalizedString(@"GPL", nil) forSegmentAtIndex:3];
    
    [self.gasTankCapacity setMaximumValue:(float)(SLIDER_MAX - SLIDER_MIN) / SLIDER_STEP];
    //get user prefs for the preferred car model id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int defaultTankCapacity = [[prefs objectForKey:kDefaultTankCapacity] intValue];
    [self.gasTankCapacity setValue:(defaultTankCapacity - SLIDER_MIN) / SLIDER_STEP];
    [self.tankCapacityValue setText:[NSString stringWithFormat:@"%d L",defaultTankCapacity]];
    
    self.saveButton.enabled = NO;
    
    //When done is pressed dismiss keyboard
    [self.gasTankCapacity addTarget:self
                       action:@selector(dismissKeyboard)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.freindlyNameText addTarget:self
                             action:@selector(userEnteredName)
                   forControlEvents:UIControlEventEditingDidEndOnExit];

    [self.urbanConsumption addTarget:self
                              action:nil
                    forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.extraUrbanConsumption addTarget:self
                                   action:nil
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
    self.itemSource = [[APCarDBAutoCompleteItemsSource alloc] initWithMinimumCharactersToTrigger:1 andFieldType:kModelEdit];
    _autocompleteModel = [TRAutocompleteView autocompleteViewBindedTo:txt
                                                        havingSpace:kLeftSearchBarPadding
                                                        usingSource:self.itemSource
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
        if (self.brandSet) {
            self.brandSet = NO;
                self.modelSearch.text = @"";
                self.modelSet = NO;
        }
    }
    if ([self.modelSearch.text length] == 0) {
        [self.modelSearch resignFirstResponder];
        self.modelSet = NO;
        
    }
    [self.freindlyNameText resignFirstResponder];
    [self.urbanConsumption resignFirstResponder];
    [self.extraUrbanConsumption resignFirstResponder];
    
    if ([self.freindlyNameText.text length] > 0) {
        self.nameSet = YES;
    }else{
        self.nameSet = NO;
    }
    [self checkifCanSave];
}
- (void) userEnteredName{
    if ([self.freindlyNameText.text length] > 0) {
//        ALog("Name was set");
        self.nameSet = YES;
    }else{
        self.nameSet = NO;
    }
    [self checkifCanSave];
}

-(IBAction)cashSlider:(id)sender{
    int index = (int)(self.gasTankCapacity.value + 0.5); // Round the number.
    [self.gasTankCapacity setValue:index animated:NO];
    
    int value = SLIDER_MIN + index * SLIDER_STEP;
    [self.tankCapacityValue setText:[NSString stringWithFormat:@"%d L",value]];
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
        [self.energyTypeSelect setSelectedSegmentIndex:[[self.source objectForKey:@"energy"] intValue]];
        self.modelSet = YES;
        
        if ([self.brandSearch.text length] == 0) {
            self.brandSearch.text = [self.source objectForKey:@"brand"];
        }
        [self checkifCanSave];
    }else if (searchBar == self.brandSearch && [self.brandSearch.text length] > 0){
        self.brandSet = YES;
        [self.itemSource setBrandString:self.brandSearch.text];
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
    }else{
        self.saveButton.enabled = NO;
    }
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addViewController:self didFinishWithSave:NO];
}


- (IBAction)save:(id)sender
{
    self.car.brand = self.brandSearch.text;
    self.car.model = self.modelSearch.text;
    self.car.friendlyName = self.freindlyNameText.text;
    self.car.modelID = [self.source objectForKey:@"modelID"];
    self.car.energy = [NSNumber numberWithInteger:[self.energyTypeSelect selectedSegmentIndex]];

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
