//
//  LMIDataFetcher.m
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "APIDataFetcher.h"
#import "RXMLElement.h"

#define BASE_URL @"http://api.lmiforall.org.uk/api/"

@implementation APIDataFetcher


+(void)fetchMostInDemandJobsForRegion:(int)regionID completionBlock:(void (^)(NSMutableArray *inDemandJobsArray, NSError *error)) completionBlock{
    
    NSLog(@"fetching most in demand jobs");
    
    NSString *searchQuery = [NSString stringWithFormat:@"http://api.lmiforall.org.uk/api/ess/regions/ranksocs/%d", regionID];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchQuery]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(error == nil){
                                   
                                   NSError *jsonError = nil;
                                   NSDictionary *inDemandJobsDict = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                   
                                   __block int jobCount = 0;
                                   
                                   NSMutableArray *inDemandJobsArray = [NSMutableArray array];
                                   
                                   for (NSDictionary *aJob in inDemandJobsDict) {
                                       [APIDataFetcher fetchInfoForSOC:[aJob valueForKey:@"soc"]
                                                            completion:^(NSDictionary *socInfo, NSError *error) {
                                                                if(!error){
                                                                    
                                                                    NSMutableDictionary *job = [NSMutableDictionary dictionaryWithDictionary:aJob];
                                                                    
                                                                    [job setValue:[socInfo valueForKey:@"title"] forKey:@"title"];
                                                                    [inDemandJobsArray addObject:job];
                                                                    
                                                                    jobCount++;
                                                                    
                                                                    
                                                                    if(jobCount == inDemandJobsDict.count){
                                                                        completionBlock(inDemandJobsArray, error);
                                                                    }
                                                                }
                                                                else {
                                                                    NSLog(@"error: %@", error.localizedDescription);
                                                                }
                                                            }
                                        ];
                                   }
                               }
                               else {
                                   completionBlock(nil, error);
                               }
                           }
     ];
}

+(void)fetchRegionWithCompletionBlock:(void (^)(NSDictionary *regionsDict, NSError *error)) completionBlock{
    
    NSLog(@"fetching region list");
    
    NSString *searchQuery = [NSString stringWithFormat:@"http://api.lmiforall.org.uk/api/ess/regions"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchQuery]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(error == nil){
                                   
                                   NSError *jsonError = nil;
                                   NSDictionary *regionsDict = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                   
                                   completionBlock(regionsDict, jsonError);
                                   
                                   
                                   //                                   NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //
                                   //                                   RXMLElement *rootXML = [RXMLElement elementFromXMLString:html encoding:NSUTF8StringEncoding];
                                   //
                                   //                                   RXMLElement *jobs = [rootXML child:@"channel"];
                                   //
                                   //                                   __block NSDictionary *result;
                                   //                                   [jobs iterate:@"item" usingBlock:^(RXMLElement *element) {
                                   //                                       NSLog(@"got: %@", [element child:@"title"]);
                                   //                                       result = @{@"title" : [element child:@"title"], @"description" : [element child:@"description"]};
                                   //                                   }];
                                   //                                   
                                   //                                   NSLog(@"listing result: %@", result);
                                   //                                   
                                   //                                   completionBlock(result, nil);
                               }
                               else {
                                   completionBlock(nil, error);
                               }
                           }
     ];    
}


+(void)socCodeSearch:(NSString *)query completion:(void (^)(NSJSONSerialization *json, NSError *error)) completionBlock{

    NSString *socCodeSearch = [NSString stringWithFormat:@"soc/search?q=%@", query];
    
    NSURL *requestURL = [NSURL URLWithString:[BASE_URL stringByAppendingString:socCodeSearch]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    [APIDataFetcher sendRequest:request completion:^(NSJSONSerialization *json, NSError *error) {
        completionBlock(json, error);
    }];
    
}

+(void)fetchInfoForSOC:(NSString *)socCode completion:(void (^)(NSDictionary *socInfo, NSError *error)) completionBlock{

    NSString *socCodeSearch = [NSString stringWithFormat:@"soc/code/%@", socCode];
    
    NSURL *requestURL = [NSURL URLWithString:[BASE_URL stringByAppendingString:socCodeSearch]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    [APIDataFetcher sendRequest:request completion:^(NSJSONSerialization *json, NSError *error) {
        NSDictionary *socInfo = (NSDictionary *)json;
        NSLog(@"socinfo: %@", socInfo);
        completionBlock(socInfo, error);
    }];
    

}

+(void)sendRequest:(NSURLRequest *)request completion:(void (^)(NSJSONSerialization *json, NSError *error)) completionBlock{
    
//    NSLog(@"sending request: %@", request.URL);
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if(error == nil){
                                   NSError *jsonReadingError = nil;
                                   NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonReadingError];
                                   if (jsonReadingError == nil) {
                                       completionBlock(json, nil);
                                   }
                                   else {
                                       NSLog(@"json reading error: %@", error.localizedDescription);
                                       completionBlock(nil, jsonReadingError);
                                   }
                               }
                               else {
                                   NSLog(@"connection error: %@", error.localizedDescription);
                                   completionBlock(nil, error);
                               }
                           }
     ];
}

+(void)jobDataSearch:(NSString *)socCode jobTitle:(NSString *)jobTitle completion:(void (^) (NSDictionary *results, NSError *error)) completionBlock{
    
    //weekly pay search
    NSString *weeklyPaySearch = [NSString stringWithFormat:@"lfs/weeklypay?soc=%@", socCode];
    NSURL *requestURL = [NSURL URLWithString:[BASE_URL stringByAppendingString:weeklyPaySearch]];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    [APIDataFetcher sendRequest:request completion:^(NSJSONSerialization *json, NSError *error) {
        
        NSDictionary *payResults = (NSDictionary *)json;
        
        NSArray *pays = [payResults valueForKey:@"years"];
        
        NSString *currentPay;
        
        for (NSDictionary *pay in pays){
            int year = [[pay valueForKey:@"year"] intValue];   
            if (year == 2012 || year == 2010) {
                currentPay = [pay valueForKey:@"weekpay"];
            }
        }
        completionBlock(@{@"pay" : currentPay } , error);
        
    }];
    
    //hard to fill search
    NSString *htfSearch = [NSString stringWithFormat:@"ess/region/01/%@", socCode];
    requestURL = [NSURL URLWithString:[BASE_URL stringByAppendingString:htfSearch]];
    request = [NSURLRequest requestWithURL:requestURL];
    
    
    [APIDataFetcher sendRequest:request completion:^(NSJSONSerialization *json, NSError *error) {
        
        NSDictionary *htfResults = (NSDictionary *)json;
        
        NSString *htf = [htfResults valueForKey:@"percentHTF"];
        
        completionBlock(@{@"htf" : htf } , error);
        
    }];
    
    
    //job listings search:
    
    NSString *searchQuery = [NSString stringWithFormat:@"http://www.jobsite.co.uk/cgi-bin/advsearch?rss_feed=1&job_title_atleast=%@,ttttt&location_include=Reed&search_currency_code=GBP&search_single_currency_flag=N&search_salary_type=A&daysback=7&scc=UK", jobTitle];

    
    NSURLRequest *jobRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:searchQuery]];
    
    [NSURLConnection sendAsynchronousRequest:jobRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if(response != nil && error != nil){
                               
                                   NSURLRequest *newRequest = [NSURLRequest requestWithURL:response.URL];
                                   
                                   
                                   [NSURLConnection sendAsynchronousRequest:newRequest
                                                                      queue:[NSOperationQueue mainQueue]
                                                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                              
                                                              
                                                              if(error == nil){
                                                              
                                                              
                                                              NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                                   
                                                                   RXMLElement *rootXML = [RXMLElement elementFromXMLString:html encoding:NSUTF8StringEncoding];
                                                                   
                                                                   RXMLElement *jobs = [rootXML child:@"channel"];
                                                                   
                                                                   __block NSDictionary *result;
                                                                   [jobs iterate:@"item" usingBlock:^(RXMLElement *element) {
                                                                       NSLog(@"got: %@", [element child:@"title"]);
                                                                       result = @{@"listingJobTitle" : [element child:@"title"], @"listingJobdescription" : [element child:@"description"]};
                                                                   }];
                                                                   
                                                                   NSLog(@"listing result: %@", result);
                                                                   
                                                                   completionBlock(result, nil);
                                                              }
                                                              else {
    //                                                              NSLog(@"error fetching job listing: %@", error.localizedDescription);
                                                                  NSLog(@"newrequestURL: %@", newRequest.URL);
                                                              }
                                                              
                                                              }
                                        ];
                               }
                           }
     ];
    
    
}


@end
