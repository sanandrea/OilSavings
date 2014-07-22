//
//  APCarDBAutoCompleteItemsSource.h
//  OilSavings
//
//  Created by Andi Palo on 7/21/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRAutocompleteItemsSource.h"

@interface APCarDBAutoCompleteItemsSource : NSObject <TRAutocompleteItemsSource>

- (id)initWithMinimumCharactersToTrigger:(NSUInteger)minimumCharactersToTrigger andFieldType:(EDIT_TYPE) tt;
- (id)initWithMinimumCharactersToTrigger:(NSUInteger)minimumCharactersToTrigger andFieldType:(EDIT_TYPE) tt andBrand:(NSString*)bb;

+ (NSDictionary*) getIDForCarModel:(NSString*)model;
@end
