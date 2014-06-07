//
//  APOptionsViewController.h
//  OilSavings
//
//  Created by Andi Palo on 6/4/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRAutocompleteView.h"

@interface APOptionsViewController : UIViewController<UISearchBarDelegate>{
    IBOutlet UITextField *_textField;
    TRAutocompleteView *_autocompleteSrc;
    TRAutocompleteView *_autocompleteDst;
}

@end
