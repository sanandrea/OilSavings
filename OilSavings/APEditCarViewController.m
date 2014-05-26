//
//  APEditCarViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APEditCarViewController.h"

@interface APEditCarViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end

@implementation APEditCarViewController

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
    self.title = self.editedFieldName;
    
    _brandNames = @[@"Audi", @"BMW",
                      @"VW", @"BENZ", @"Honda"];
    
    _modelNames = @[ @"Brabus",@"Seria 3",@"R8"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure the user interface according to state.
    if (self.type == kFriendlyNameEdit) {
        self.textField.hidden = NO;
        self.pickerView.hidden = YES;

        self.textField.text = [self.editedObject valueForKey:self.editedFieldKey];
        self.textField.placeholder = self.title;
        [self.textField becomeFirstResponder];
    }
    else {
        ALog("Editing picker view");
        self.textField.hidden = YES;
        self.pickerView.hidden = NO;
        
    }
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Save and cancel operations

- (IBAction)save:(id)sender
{
    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.editedObject managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"%@", self.editedFieldName]];
    
    [self.editedObject setValue:self.textField.text forKey:self.editedFieldKey];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Manage whether editing a date

- (void)setEditedFieldKey:(NSString *)editedFieldKey
{
    if (![_editedFieldKey isEqualToString:editedFieldKey]) {
        _editedFieldKey = editedFieldKey;
    }
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _brandNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _brandNames[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{

    self.textField.text = _brandNames[row];
}



@end
