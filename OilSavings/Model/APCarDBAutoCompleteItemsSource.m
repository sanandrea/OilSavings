//
//  APCarDBAutoCompleteItemsSource.m
//  OilSavings
//
//  Created by Andi Palo on 7/21/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APCarDBAutoCompleteItemsSource.h"
#import <sqlite3.h>

@implementation APCarDBAutoCompleteItemsSource{
    NSUInteger _minimumCharactersToTrigger;
    NSString *_databasePath;
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
- (void)itemsFor:(NSString *)query whenReady:(void (^)(NSArray *))suggestionsReady
{
    ALog("Items for car model");
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
            querySQL = [NSString stringWithFormat:@"SELECT brand FROM brands like %@",query];
        }else if (_type == kModelEdit){
            querySQL = [NSString stringWithFormat:@"SELECT model FROM models like %@",query];
        }
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_carDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray *result = [[NSMutableArray alloc]init];
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *info = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [result addObject:info];
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
        }

        sqlite3_close(_carDB);
    }
    
}
- (NSUInteger)minimumCharactersToTrigger
{
    return _minimumCharactersToTrigger;
}


@end
