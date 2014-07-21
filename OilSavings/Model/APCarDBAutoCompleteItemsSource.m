//
//  APCarDBAutoCompleteItemsSource.m
//  OilSavings
//
//  Created by Andi Palo on 7/21/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APCarDBAutoCompleteItemsSource.h"
//Use this it is almost identical
#import "TRGoogleMapsSuggestion.h"
#import <sqlite3.h>

@implementation APCarDBAutoCompleteItemsSource{
    NSUInteger _minimumCharactersToTrigger;
    NSString *_databasePath;
    NSString *_brand;
    sqlite3 *_carDB;
    EDIT_TYPE _type;
    BOOL _requestToReload;
    BOOL _loading;
}

- (id)initWithMinimumCharactersToTrigger:(NSUInteger)minimumCharactersToTrigger andFieldType:(EDIT_TYPE) tt{
    self = [super init];
    if (self)
    {
        _type = tt;
        _minimumCharactersToTrigger = minimumCharactersToTrigger;
    }
    
    return self;
}

- (id)initWithMinimumCharactersToTrigger:(NSUInteger)minimumCharactersToTrigger andFieldType:(EDIT_TYPE) tt andBrand:(NSString*)bb{
    self = [self initWithMinimumCharactersToTrigger:minimumCharactersToTrigger andFieldType:tt];
    if (self)
    {
        _brand = bb;
    }
    
    return self;
}
- (void)itemsFor:(NSString *)query whenReady:(void (^)(NSArray *))suggestionsReady
{
    @synchronized (self)
    {
        if (_loading)
        {
            _requestToReload = YES;
            return;
        }
        
        _loading = YES;
        [self requestSuggestionsFor:query whenReady:suggestionsReady];
    }
}

- (void)requestSuggestionsFor:(NSString *)query whenReady:(void (^)(NSArray *))suggestionsReady
{
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
        
        if (_type == kBrandEdit) {
            querySQL = [NSString stringWithFormat:@"SELECT brand FROM brands where brand like '%%%@%%'",query];
        }else if (_type == kModelEdit){
            if (_brand != nil) {
                querySQL = [NSString stringWithFormat:@"SELECT model FROM models where brandID = (SELECT id from brands WHERE brand = '%@') and model like '%%%@%%'",_brand, query];
            }else{
                querySQL = [NSString stringWithFormat:@"SELECT model FROM models where model like '%%%@%%'",query];
            }
        }
        
        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_carDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            ALog("Query returns something");
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *info = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                TRGoogleMapsSuggestion *suggestion = [[TRGoogleMapsSuggestion alloc] initWith:info];
                [result addObject:suggestion];
            }
            sqlite3_finalize(statement);
            if (suggestionsReady)
                suggestionsReady(result);

            @synchronized (self)
            {
                _loading = NO;
                
                if (_requestToReload)
                {
                    _requestToReload = NO;
                    [self itemsFor:query whenReady:suggestionsReady];
                }
            }
        }else{
            
        }

        sqlite3_close(_carDB);
    }
    
}
- (NSUInteger)minimumCharactersToTrigger
{
    return _minimumCharactersToTrigger;
}


@end
