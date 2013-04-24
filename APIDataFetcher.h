//
//  LMIDataFetcher.h
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIDataFetcher : NSObject

//LMI Data:

+(void)fetchMostInDemandJobsForRegion:(int)regionID completionBlock:(void (^)(NSMutableArray *inDemandJobsArray, NSError *error)) completionBlock;

+(void)fetchRegionWithCompletionBlock:(void (^)(NSDictionary *regionsDict, NSError *error)) completionBlock;

+(void)socCodeSearch:(NSString *)query completion:(void (^)(NSJSONSerialization *json, NSError *error)) completionBlock;

+(void)jobDataSearch:(NSString *)socCode jobTitle:(NSString *)jobTitle completion:(void (^) (NSDictionary *results, NSError *error)) completionBlock;

+(void)cvSearchForJobTitle:(NSString *)jobTitle completion:(void (^) (NSArray *imageArray, NSError *error)) completionBlock;

+(void)fetchImageFromURL:(NSString *)url completion:(void (^) (UIImage *image, NSError *error)) completionBlock;

@end
