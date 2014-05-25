//
//  APGaeApiClient.h
//  OilSavings
//
//  Created by Andi Palo on 5/25/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


extern NSString * const kGaeBaseURLString;

@interface APGaeApiClient : AFHTTPSessionManager


+ (APGaeApiClient *)sharedClient;

- (void)getVersionsOnsuccess:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)getLatestDBOnsuccess:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)getResourcesOnsuccess:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;



@end