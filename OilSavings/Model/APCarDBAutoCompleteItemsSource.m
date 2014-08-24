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
- (void)setBrandString:(NSString*)bb{
    _brand = bb;
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
        
//        ALog("Items for car model %@",querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_carDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
//            ALog("Query returns something");
            
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

+ (NSDictionary*) getIDForCarModel:(NSString*)model{
    //Root filepath
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    
    NSString *dataPath = [[NSString alloc] initWithString: [appDir stringByAppendingPathComponent:@"car.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    sqlite3 *db;
    
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];

    if ([filemgr fileExistsAtPath: dataPath ] == NO){
        ALog("Error here buddy , could not find car db file");
    }else{
        const char *dbpath = [dataPath UTF8String];
        
        if (sqlite3_open(dbpath, &db) != SQLITE_OK){
            ALog("Failed to open/create database");
        }
        //Load data
        
        
        NSString *querySQL;
        sqlite3_stmt    *statement;
        

        querySQL = [NSString stringWithFormat:@"SELECT id,energy FROM models where model = '%@'",model];
        
        const char *query_stmt = [querySQL UTF8String];
        int rowID;
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                rowID = sqlite3_column_int(statement, 0);
                [result setValue:[NSNumber numberWithInt:rowID] forKey:@"modelID"];
                
                NSString *energy = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                if ([energy isEqualToString:@"gasoline"]) {
                    [result setValue:[NSNumber numberWithInt:kEnergyGasoline] forKey:@"energy"];
                }else if ([energy isEqualToString:@"diesel"]){
                    [result setValue:[NSNumber numberWithInt:kEnergyDiesel] forKey:@"energy"];
                }
//                ALog("Energy %@ and id %d",energy, rowID);
            }
            sqlite3_finalize(statement);
        }
        
        /* Find all params */
        querySQL = [NSString stringWithFormat:@"SELECT * FROM parameters where modelID = %d",rowID];
        query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                [result setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 1)] forKey:@"pA"];
                [result setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 2)] forKey:@"pB"];
                [result setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 3)] forKey:@"pB"];
                [result setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement, 4)] forKey:@"pD"];
                
            }
            sqlite3_finalize(statement);
        }
        /* Find brand name also */
        querySQL = [NSString stringWithFormat:@"SELECT brand FROM brands where id = (SELECT brandID from models where model = '%@')",model];
        query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                [result setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)] forKey:@"brand"];
            }
            sqlite3_finalize(statement);
        }
    }
    return result;
}
- (NSUInteger)minimumCharactersToTrigger
{
    return _minimumCharactersToTrigger;
}


@end
