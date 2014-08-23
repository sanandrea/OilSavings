//
//  APOptionsViewController.m
//  OilSavings
//
//  Created by Andi Palo on 6/4/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APOptionsViewController.h"
#import "TRGoogleMapsAutocompleteItemsSource.h"
#import "TRGoogleMapsAutocompletionCellFactory.h"
static int kSRCSearchFieldTAG = 98;
static int kDSTSearchFieldTAG = 99;
static float kLeftSearchBarPadding = 31;

static int MIN_AMOUNT = 5;
static int MAX_AMOUNT = 50;
static int INC_STEP = 5;
static int MAX_LINEAR = 40;

@interface APOptionsViewController ()

@property (nonatomic, strong) UISearchBar *selected;
@property (nonatomic, strong) NSMutableArray *fuelStringsArray;

@property IBOutlet UISearchBar *src;
@property IBOutlet UISearchBar *dst;
@property (weak, nonatomic) IBOutlet UISlider* cashSliderControl;
@property (weak, nonatomic) IBOutlet UILabel* cashLabel;
@property (weak, nonatomic) IBOutlet UILabel* fuelLabel;
@property (weak, nonatomic) IBOutlet UILabel* srcLabel;
@property (weak, nonatomic) IBOutlet UILabel* dstLabel;
@property (nonatomic, weak) IBOutlet UIPickerView *energyTypeSelect;

@end

@implementation APOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fuelStringsArray = [[NSMutableArray alloc] initWithCapacity:ENERGIES_COUNT];
    
    for (int i = 0; i < ENERGIES_COUNT; i++) {
        [self.fuelStringsArray addObject:[APConstants getEnergyLongNameForType:(ENERGY_TYPE)i]];
    }
    

    [self.cashSliderControl setMinimumValue:0];
    [self.cashSliderControl setMaximumValue:(MAX_AMOUNT - MIN_AMOUNT)/INC_STEP + 2];
    
    [self.cashSliderControl setValue:[self convertAmount2Index:self.cashAmount]];
    [self.cashLabel setText:[NSString stringWithFormat:@"%ld",(long)self.cashAmount]];
    
    self.srcLabel.text = NSLocalizedString(@"Da", @"Options source address label");
    self.dstLabel.text = NSLocalizedString(@"A", @"Options destination address label");
    self.fuelLabel.text = NSLocalizedString(@"Carburante", @"Fuel select label");
    
    if (self.srcAddr != nil) {
        self.src.placeholder = self.srcAddr;
    }else{
        self.src.placeholder = NSLocalizedString(@"Indirizzo di partenza", @"indirizzo di partenza");
    }
    if (self.dstAddr != nil) {
        self.dst.placeholder = self.dstAddr;
    }else{
        self.dst.placeholder = NSLocalizedString(@"Indirizzo di destinazione", @"indirizzo di destinazione");
    }
    self.src.delegate = self;
    self.dst.delegate = self;
    UITextField* txt;
    for (UIView *subView in self.dst.subviews){
        for (UIView *secView in subView.subviews){
            if ([secView isKindOfClass:[UITextField class]])
            {
                txt = (UITextField *)secView;
                break;
            }
        }
    }
    _autocompleteSrc = [TRAutocompleteView autocompleteViewBindedTo:txt
                                                        havingSpace:kLeftSearchBarPadding
                                                        usingSource:[[TRGoogleMapsAutocompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 apiKey:GOOGLE_API_KEY]
                                                        cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                       presentingIn:self];
    _autocompleteSrc.topMargin = -55.f;
    for (UIView *subView in self.src.subviews){
        for (UIView *secView in subView.subviews){
            if ([secView isKindOfClass:[UITextField class]])
            {
                txt = (UITextField *)secView;
                break;
            }
        }
    }
    _autocompleteDst = [TRAutocompleteView autocompleteViewBindedTo:txt
                                                        havingSpace:kLeftSearchBarPadding
                                                        usingSource:[[TRGoogleMapsAutocompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 apiKey:GOOGLE_API_KEY]
                                                        cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                       presentingIn:self];
    _autocompleteDst.topMargin = -55.f;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

- (void) dismissKeyboard{
    if ([self.src.text length] == 0) {
        [self.src resignFirstResponder];
    }
    if ([self.dst.text length] ==0) {
        [self.dst resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if (txt.tag == kSRCSearchFieldTAG ||txt.tag == kDSTSearchFieldTAG) {
            [txt resignFirstResponder];
        }
    }
}

-(IBAction)cashSlider:(id)sender{
    int linearMax = MAX_LINEAR;
    int endLinearIndex = (linearMax - MIN_AMOUNT) / INC_STEP;
    int index = (int)(self.cashSliderControl.value + 0.5); // Round the number.
    [self.cashSliderControl setValue:index animated:NO];
    
    int value = (MIN_AMOUNT + index * INC_STEP);
    if (value <= linearMax) {
        [self.cashLabel setText:[NSString stringWithFormat:@"%d",(MIN_AMOUNT + index * INC_STEP)]];
    }else{
        int inc = linearMax + 2 * INC_STEP * (index - endLinearIndex);
        [self.cashLabel setText:[NSString stringWithFormat:@"%u",inc]];
    }
}
- (NSInteger) convertAmount2Index:(NSInteger)amount{
    NSInteger index = 0;
    if (amount < MAX_LINEAR){
        index = (int)(amount - MIN_AMOUNT)/INC_STEP;
    }else{
        index += (int)(MAX_LINEAR - MIN_AMOUNT)/INC_STEP;
        index += (int)(amount - MAX_LINEAR) / (2 * INC_STEP);
    }
    
    
    return index;
}
- (IBAction)save:(id)sender{
    self.srcAddr = self.src.text;
    self.dstAddr = self.dst.text;
    self.cashAmount = [self.cashLabel.text integerValue];
    
    [self.delegate optionsController:self didfinishWithSave:YES];
}


- (IBAction)cancel:(id)sender{
    [self.delegate optionsController:self didfinishWithSave:NO];
}

#pragma mark - Picker View Protocol

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return ENERGIES_COUNT;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView
//             titleForRow:(NSInteger)row
//            forComponent:(NSInteger)component
//{
//    return _countryNames[row];
//}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
//    label.backgroundColor = [UIColor lightGrayColor];
//    label.textColor = [UIColor colorWithRed:100.f green:122.f blue:162.f alpha:1.f];
    label.font = [UIFont boldSystemFontOfSize:14.0f];
    label.text = [self.fuelStringsArray objectAtIndex:row];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}


#pragma mark - Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchText length] == 0) {
        ALog("Canceled");
        if (searchBar == self.src){
            [_autocompleteSrc hidesuggestions];
            [_src endEditing:YES];
        }else{
            [_autocompleteDst hidesuggestions];
            [_dst endEditing:YES];
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if (searchBar == self.src) {
        ALog("Source is set");
    }else{
        ALog("Destination is set");
    }
}

/*
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    ALog("Begin search");
    if (self.selected != nil && searchBar != self.selected) {
        [self.selected endEditing:YES];
    }
    self.selected = searchBar;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
