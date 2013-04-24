//
//  ViewController.m
//  JobBungee
//
//  Created by Ariel Elkin on 12/03/2013.
//  Copyright (c) 2013 ariel. All rights reserved.
//

#import "ViewController.h"
#import "APIDataFetcher.h"

@interface ViewController ()

@property UIPickerView *regionPicker;
@property NSDictionary *regionsDict;
@property NSMutableArray *inDemandJobsArray;
@property UIButton *searchButton;
@property int selectedRegion;

//@property UITextField *jobSearchTextField;



@property float screenWidth;
@property float screenHeight;

@property UITableView *tableView;
@property UIImageView *bungeeJumper;
@property UILabel *titleLabel;
@property UILabel *instructionsLabel;
@property NSMutableDictionary *resultsDict;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    [self setupUI];
    
    self.resultsDict = [NSMutableDictionary dictionary];    
    
}

-(void)setupUI{
    
    //add background image:
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Portrait"]];
    [self.view addSubview:backgroundImage];
    
    //add bungee jumper image:
    self.bungeeJumper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bungeeguy"]];
    [self.bungeeJumper setCenter:CGPointMake(self.screenWidth - self.bungeeJumper.bounds.size.width/2, self.screenHeight/20)];
    [self.view addSubview:self.bungeeJumper];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.titleLabel.font = [UIFont fontWithName:@"Armata-Regular" size:50];
    [self.titleLabel setText:@"JobBungee"];
    [self.titleLabel setCenter:CGPointMake(self.screenWidth/2, 200)];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.titleLabel];
    
    self.instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 100)];
    self.instructionsLabel.font = [UIFont fontWithName:@"Armata-Regular" size:25];
    [self.instructionsLabel setText:@"Select a region to find which jobs are most in demand:"];
    [self.instructionsLabel setNumberOfLines:2];
    [self.instructionsLabel setTextAlignment:NSTextAlignmentCenter];
    self.instructionsLabel.center = CGPointMake(self.screenWidth/2, self.titleLabel.center.y+80);
    [self.instructionsLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.instructionsLabel];
    
    self.regionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth/2, self.screenHeight/4)];
    [self.regionPicker setCenter:CGPointMake(self.screenWidth/2, self.instructionsLabel.center.y + self.regionPicker.bounds.size.height-50)];
    [self.regionPicker setShowsSelectionIndicator:YES];
    [self.regionPicker setDelegate:self];
    [self.regionPicker setDataSource:self];
    [self.view addSubview:self.regionPicker];
    
    [APIDataFetcher fetchRegionWithCompletionBlock:^(NSDictionary *regionsDict, NSError *error) {
        if (!error) {
            self.regionsDict = regionsDict;
            NSLog(@"Got regionsDict: %@", regionsDict);
            [self startBungeeAnimation];
            [self.regionPicker reloadAllComponents];
        }
        else {
            NSLog(@"error fetching regions: %@", error.localizedDescription);
        }
    }];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.searchButton setFrame:CGRectMake(0, 0, self.regionPicker.bounds.size.width, 30)];
    [self.searchButton setCenter:CGPointMake(self.regionPicker.center.x, self.regionPicker.frame.origin.y + self.regionPicker.frame.size.height + self.searchButton.bounds.size.height/2)];
    [self.searchButton setTitle:@"Select" forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(regionSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchButton];


    
//    //Add search text field:
//    self.jobSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth/2, self.screenHeight/14)];
//    [self.jobSearchTextField setCenter:CGPointMake(self.screenWidth/2, self.screenHeight/3)];
//    [self.jobSearchTextField setFont:[UIFont fontWithName:@"Armata-Regular" size:40]];
//    [self.jobSearchTextField setPlaceholder:@"Search"];
//    [self.jobSearchTextField setTextColor:[UIColor whiteColor]];
//    [self.jobSearchTextField setTextAlignment:NSTextAlignmentCenter];
//    [self.jobSearchTextField setBorderStyle:UITextBorderStyleBezel];
//    
//    [self.jobSearchTextField setDelegate:self];
//    [self.jobSearchTextField setReturnKeyType:UIReturnKeySearch];
//    [self.jobSearchTextField setKeyboardType:UIKeyboardTypeAlphabet];
//    [self.jobSearchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
//    [self.jobSearchTextField setClearsOnBeginEditing:YES];
//    [self.jobSearchTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//    [self.view addSubview:self.jobSearchTextField];
    
    
    //Add tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth/1.5, self.screenHeight/1.5) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setCenter:CGPointMake(self.screenWidth/2, self.screenHeight*2)];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.jobSearchTextField becomeFirstResponder];
}


-(void)fetchJobDataForSocCode:(NSString *)socCode jobTitle:(NSString *)jobTitle{
    
    [APIDataFetcher jobDataSearch:socCode jobTitle:jobTitle completion:^(NSDictionary *results, NSError *error) {
        if(error == nil){
            
            [self.resultsDict addEntriesFromDictionary:results];
            
            [self animateScrollUp];
            
            [self.tableView reloadData];
        }
    }];
}


#pragma mark -
#pragma mark Animations

-(void)startBungeeAnimation{
    [UIView animateWithDuration:1
                     animations:^{
                         [self.bungeeJumper setCenter:CGPointMake(self.bungeeJumper.center.x, self.bungeeJumper.center.y-300)];
                     }
     ];
}

-(void)animateScrollUp{
    [UIView animateWithDuration:0.3
                     animations:^{
                         
//                         [self.jobSearchTextField setCenter:CGPointMake(self.jobSearchTextField.center.x, self.jobSearchTextField.bounds.size.height + self.jobSearchTextField.bounds.size.height*0.1)];
                         [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, 100)];
                         [self.instructionsLabel setCenter:CGPointMake(self.instructionsLabel.center.x, 160)];
                         [self.regionPicker setCenter:CGPointMake(self.regionPicker.center.x, 300)];
                         [self.searchButton setCenter:CGPointMake(self.regionPicker.center.x, self.regionPicker.frame.origin.y + self.regionPicker.frame.size.height + self.searchButton.bounds.size.height/2)];
                         [self.tableView setCenter:CGPointMake(self.screenWidth/2, 800)];
                         
                         [self.bungeeJumper setCenter:CGPointMake(self.screenWidth - self.bungeeJumper.bounds.size.width/2, self.screenHeight/2)];

                     }
     ];
    
}



#pragma mark -
#pragma mark TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self startBungeeAnimation];
}


-(void)textFieldDidEndEditing:(UITextField *)textField{

    [APIDataFetcher socCodeSearch:textField.text completion:^(NSJSONSerialization *json, NSError *error) {
        if (error == nil) {
            
            NSArray *results = (NSArray * ) json;
            
            NSDictionary *firstResults = results[0];
            
            NSString *jobTitle = [[firstResults valueForKey:@"title"] copy];
            [self.resultsDict setValue:jobTitle forKey:@"title"];
            
            NSString *socCode = [firstResults valueForKey:@"soc"];
        
            [self fetchJobDataForSocCode:socCode jobTitle:jobTitle];
        }
    }];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
}



#pragma mark -
#pragma mark Regions PickerView

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (self.inDemandJobsArray) {
        NSLog(@"got jobs array");
        return 2;
    } else return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0) {
        NSArray *regionNames = [self.regionsDict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        return regionNames[row];
    }
    else {
        NSString *jobTitle = [self.inDemandJobsArray[row] valueForKey:@"title"];
        NSLog(@"should return %@", jobTitle);
        return jobTitle;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.regionsDict.allKeys.count;
    } else return self.inDemandJobsArray.count;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"selected row %d", row);
    self.selectedRegion = row;
    if (component == 1) {
        [self animateScrollUp];
    }
}

-(void)regionSelected{
    [APIDataFetcher fetchMostInDemandJobsForRegion:self.selectedRegion completionBlock:^(NSMutableArray *inDemandJobsArray, NSError *error) {
        NSLog(@"most demand jobs: %@", inDemandJobsArray);
        self.inDemandJobsArray = inDemandJobsArray;
        [self.regionPicker reloadAllComponents];
        [self.regionPicker setFrame:CGRectMake(self.regionPicker.frame.origin.x, self.regionPicker.frame.origin.y, self.regionPicker.frame.size.width*1.5, self.regionPicker.frame.size.height)];
        [self.regionPicker setCenter:CGPointMake(self.screenWidth/2, self.regionPicker.center.y)];
    }];
}


#pragma mark -
#pragma mark TableViewDelegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ResultsCellIdentifier = @"ResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResultsCellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:ResultsCellIdentifier];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.font = [UIFont fontWithName:@"Armata-Regular" size:30];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Armata-Regular" size:27];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    //Stats
    if(indexPath.section == 0){
        cell.imageView.image = nil;
    
        //Title
        if(indexPath.row == 0){
            cell.textLabel.text = @"Title:";
            cell.detailTextLabel.text = [self.resultsDict valueForKey:@"title"];
            cell.detailTextLabel.numberOfLines = 0;
        }
        
        //Pay
        else if(indexPath.row == 1){
            cell.textLabel.text = @"Weekly Pay:";
            float pay = [[self.resultsDict valueForKey:@"pay"] floatValue];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", pay];
        }
        
        //Hard to fill
        else if(indexPath.row == 2){
            cell.textLabel.text = @"Hard to fill?";
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%% of vacancies are hard to fill in London", [[self.resultsDict valueForKey:@"htf"] floatValue]];
        }
    }

    //job listing:
    else {
        cell.textLabel.text = @" ";
        cell.detailTextLabel.text = @" ";
        
        if (indexPath.section == 1) {
            cell.textLabel.text = @"Job Listing";
            [cell.detailTextLabel setNumberOfLines:0];
            cell.detailTextLabel.text = @"Description of the job listing, along with salary";
        }
        
        if (indexPath.section == 2){
            cell.imageView.image = [UIImage imageNamed:@"cv.jpg"];
        }
    }
    
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Facts";
    }
    else if (section == 1){
        return @"Listings";
    }
    
    else if (section == 2){
        return @"Typical CV";
    }
    
    else return nil;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) return 150;
    else if(indexPath.section == 1) return 150;
    else return 400;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 3;
    }
    else return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}




@end
