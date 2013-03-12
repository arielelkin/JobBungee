//
//  JobsSearcher.h
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import <Foundation/Foundation.h>

//JobSearcher searches for live job listings
//Requires RaptureXML to parse XML

@interface JobsSearcher : NSObject

+(void)fetchJobDataFor:(NSString *)jobTitle completion:(void (^)(NSDictionary *data, NSError *error))completionBlock;

@end
