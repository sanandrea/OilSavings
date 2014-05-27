//
//  APEditCarViewController.m
//  OilSavings
//
//  Created by Andi Palo on 5/26/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APEditCarViewController.h"
#import <sqlite3.h>

@interface APEditCarViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) NSMutableArray *pickerData;

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *carDB;
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
    
    //Root filepath
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    _databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:@"car.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO){
        ALog("Error here buddy , could not find car db file");
    }else{
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_carDB) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL;
        sqlite3_stmt    *statement;

        if (self.type == kBrandEdit) {
            querySQL = @"SELECT brand FROM brands ORDER BY brand";
        }else{
            querySQL = [NSString stringWithFormat:
                      @"SELECT model FROM models WHERE brandID = (SELECT id from brands WHERE brand = '%@')",
                      [self.editedObject valueForKeyPath:@"brand"]];
        }
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_carDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            self.pickerData = [[NSMutableArray alloc]init];
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *info = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [self.pickerData addObject:info];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_carDB);
        
        //set field equal to the first of the list.
        self.textField.text = self.pickerData[0];
        
    }
}

- (void) saveCarParamsOfModel:(NSString*)model{
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    _databasePath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:@"car.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO){
        ALog("Error here buddy , could not find car db file");
    }else{
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_carDB) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL = querySQL = [NSString stringWithFormat:
                    @"SELECT * FROM parameters WHERE modelID = (SELECT id from models WHERE model = '%@')",
                    [self.editedObject valueForKeyPath:@"model"]];
        sqlite3_stmt    *statement;

        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_carDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            self.pickerData = [[NSMutableArray alloc]init];
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                [self.editedObject setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 1)] forKeyPath:@"pA"];
                [self.editedObject setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 2)] forKeyPath:@"pB"];
                [self.editedObject setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 3)] forKeyPath:@"pB"];
                [self.editedObject setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 4)] forKeyPath:@"pD"];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_carDB);
        
    }
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
        
        self.pickerData = self.pickerData;
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
    
    //if we chose model then save all car parameters
    if (self.type == kModelEdit) {
        [self saveCarParamsOfModel:self.textField.text];
    }
    
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
    return _pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _pickerData[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    self.textField.text = _pickerData[row];
}

- (void)dealloc{
    sqlite3_close(_carDB);
}

@end
