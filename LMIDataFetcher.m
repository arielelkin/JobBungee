//
//  LMIDataFetcher.m
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "LMIDataFetcher.h"

#define BASE_URL @"http://api.lmiforall.org.uk/api/"

@implementation LMIDataFetcher



+(void)socCodeSearch:(NSString *)query completion:(void (^)(NSJSONSerialization *json, NSError *error)) completionBlock{

    NSString *socCodeSearch = [NSString stringWithFormat:@"soc/search?q=%@", query];
    
    NSURL *requestURL = [NSURL URLWithString:[BASE_URL stringByAppendingString:socCodeSearch]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    [LMIDataFetcher sendRequest:request completion:^(NSJSONSerialization *json, NSError *error) {
        completionBlock(json, error);
    }];
    
}

+(void)sendRequest:(NSURLRequest *)request completion:(void (^)(NSJSONSerialization *json, NSError *error)) completionBlock{
    
    NSLog(@"sending request: %@", request.URL);
    
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
    
    NSString *weeklyPaySearch = [NSString stringWithFormat:@"lfs/weeklypay?soc=%@", socCode];
    
    NSURL *requestURL = [NSURL URLWithString:[BASE_URL stringByAppendingString:weeklyPaySearch]];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    [LMIDataFetcher sendRequest:request completion:^(NSJSONSerialization *json, NSError *error) {
        
        NSDictionary *payResults = (NSDictionary *)json;
        

        
        NSArray *pays = [payResults valueForKey:@"years"];
        
        
        
        NSString *currentPay;
        
        for (NSDictionary *pay in pays){
            int year = [[pay valueForKey:@"year"] intValue];
            
            if (year == 2012) {
                currentPay = [pay valueForKey:@"weekpay"];
            }
        }
        
        completionBlock(@{@"pay" : currentPay } , error);
        
    }];
}


@end
