//
//  JobsSearcher.m
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "JobsSearcher.h"
#import "RXMLElement.h"

@implementation JobsSearcher

+(void)fetchJobDataFor:(NSString *)jobTitle completion:(void (^)(NSDictionary *data, NSError *error))completionBlock{
    
    NSString *searchQuery = [NSString stringWithFormat:@"http://www.jobsite.co.uk/cgi-bin/advsearch?rss_feed=1&job_title_atleast=%@,ttttt&location_include=Reed&search_currency_code=GBP&search_single_currency_flag=N&search_salary_type=A&daysback=7&scc=UK", jobTitle];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchQuery]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(error == nil){
                                   
                                   NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   RXMLElement *rootXML = [RXMLElement elementFromXMLString:html encoding:NSUTF8StringEncoding];
                                   
                                   RXMLElement *jobs = [rootXML child:@"channel"];
                                   
                                   __block NSDictionary *result;
                                   [jobs iterate:@"item" usingBlock:^(RXMLElement *element) {
                                       NSLog(@"got: %@", [element child:@"title"]);
                                       result = @{@"title" : [element child:@"title"], @"description" : [element child:@"description"]};
                                   }];
                                   
                                   NSLog(@"listing result: %@", result);
                                   
                                   completionBlock(result, nil);
                               }
                           }
     ];
     

}

@end
