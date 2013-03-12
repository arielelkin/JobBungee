//
//  LMIDataFetcher.h
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMIDataFetcher : NSObject

+(void)socCodeSearch:(NSString *)query completion:(void (^)(NSJSONSerialization *json, NSError *error)) completionBlock;

+(void)jobDataSearch:(NSString *)socCode jobTitle:(NSString *)jobTitle completion:(void (^) (NSDictionary *results, NSError *error)) completionBlock;

@end
