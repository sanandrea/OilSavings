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

@property IBOutlet UISearchBar *src;
@property IBOutlet UISearchBar *dst;
@property (nonatomic, strong) UISearchBar *selected;
@property (weak, nonatomic) IBOutlet UISlider* cashSliderControl;
@property (weak, nonatomic) IBOutlet UILabel* cashLabel;

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
    
    [self.cashSliderControl setMinimumValue:0];
    [self.cashSliderControl setMaximumValue:(MAX_AMOUNT - MIN_AMOUNT)/INC_STEP + 2];
    
    [self.cashSliderControl setValue:[self convertAmount2Index:self.cashAmount]];
    [self.cashLabel setText:[NSString stringWithFormat:@"%ld",(long)self.cashAmount]];
    
    if (self.srcAddr != nil) {
        self.src.placeholder = self.srcAddr;
    }else{
        self.src.placeholder = NSLocalizedString(@"Indirizzo di partenza", @"indirizzo di partenza");
    }

    self.dst.placeholder = NSLocalizedString(@"Indirizzo di destinazione", @"indirizzo di destinazione");
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


#pragma mark - Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchText length] == 0) {
        ALog("Canceled");
        if (searchBar == self.src){
            [_autocompleteSrc hidesuggestions];
            [_src endEditing:YES];
        }else{
            [_autocompleteDst hidesuggestions];
            [_src endEditing:YES];
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
