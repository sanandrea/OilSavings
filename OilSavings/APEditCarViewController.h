//
//  APEditCarViewController.h
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APEditCarViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSManagedObject *editedObject;
@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;
@property (nonatomic) EDIT_TYPE type;

@end
