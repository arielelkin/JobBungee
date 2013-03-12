//
//  ViewController.m
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "ViewController.h"
#import "LMIDataFetcher.h"

@interface ViewController ()

@property UITextField *jobSearchTextField;
@property float screenWidth;
@property float screenHeight;

@property UITableView *tableView; 

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    NSLog(@"%f by %f", self.screenWidth, self.screenHeight);
    
    [self setupUI];
    
}

-(void)setupUI{
    
    //add background image:
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Portrait"]];
    [self.view addSubview:backgroundImage];
    
    //Add search text field:
    self.jobSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth/2, self.screenHeight/14)];
    [self.jobSearchTextField setCenter:CGPointMake(self.screenWidth/2, self.screenHeight/3)];
    [self.jobSearchTextField setFont:[UIFont fontWithName:@"Armata-Regular" size:40]];
    [self.jobSearchTextField setPlaceholder:@"Search"];
    [self.jobSearchTextField setTextColor:[UIColor whiteColor]];
    [self.jobSearchTextField setTextAlignment:NSTextAlignmentCenter];
    [self.jobSearchTextField setBorderStyle:UITextBorderStyleBezel];
    
    [self.jobSearchTextField setDelegate:self];
    [self.jobSearchTextField setReturnKeyType:UIReturnKeySearch];
    [self.jobSearchTextField setKeyboardType:UIKeyboardTypeAlphabet];
    [self.jobSearchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.jobSearchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:self.jobSearchTextField];    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.jobSearchTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    [LMIDataFetcher socCodeSearch:textField.text completion:^(NSJSONSerialization *json, NSError *error) {
        if (error == nil) {
            NSLog(@"json: %@", [json class]);
            
            NSArray *results = (NSArray * ) json;
            
            NSDictionary *firstResults = results[0];
            
            NSString *jobTitle = [firstResults valueForKey:@"title"];
            NSString *socCode = [firstResults valueForKey:@"soc"];
        
            [self fetchJobDataForSocCode:socCode jobTitle:jobTitle];
        }
    }];
}

-(void)fetchJobDataForSocCode:(NSString *)socCode jobTitle:(NSString *)jobTitle{
    [LMIDataFetcher jobDataSearch:socCode jobTitle:jobTitle completion:^(NSDictionary *results, NSError *error) {
        if(error == nil){
            NSLog(@"results: %@", results);
        }
    }];
}

-(void)showResults:(NSString *)jobName{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
