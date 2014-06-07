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

@interface APOptionsViewController ()

@property IBOutlet UISearchBar *src;
@property IBOutlet UISearchBar *dst;
@property (nonatomic, strong) UISearchBar *selected;


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
    
    self.src.placeholder = NSLocalizedString(@"Indirizzo di partenza", @"indirizzo di partenza");
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


#pragma mark - Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    CGPoint p = [_dst convertPoint:_dst.bounds.origin fromView:nil];
    ALog("p.x : %f and p.y: %f", p.x, p.y);
    if ([searchText length] == 0) {
        if (searchBar == self.src){
            [_autocompleteSrc hidesuggestions];
        }else{
            [_autocompleteDst hidesuggestions];
        }
    }
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    ALog("Begin search");
    if (self.selected != nil && searchBar != self.selected) {
        
//        [_autocompleteView hidesuggestions];
    }
    self.selected = searchBar;
}
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
