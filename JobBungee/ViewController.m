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
@property int selectedRegion;

//@property UITextField *jobSearchTextField;

@property NSDictionary *regionsDict;

@property float screenWidth;
@property float screenHeight;

@property UITableView *tableView;
@property UIImageView *bungeeJumper;
@property UILabel *titleLabel;
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
    
    UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 100)];
    instructionsLabel.font = [UIFont fontWithName:@"Armata-Regular" size:25];
    [instructionsLabel setText:@"Select a region to find which jobs are most in demand:"];
    [instructionsLabel setNumberOfLines:2];
    [instructionsLabel setTextAlignment:NSTextAlignmentCenter];
    instructionsLabel.center = CGPointMake(self.screenWidth/2, self.titleLabel.center.y+80);
    [instructionsLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:instructionsLabel];
    
    self.regionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth/2, self.screenHeight/4)];
    [self.regionPicker setCenter:CGPointMake(self.screenWidth/2, instructionsLabel.center.y + self.regionPicker.bounds.size.height-50)];
    [self.regionPicker setShowsSelectionIndicator:YES];
    [self.regionPicker setDelegate:self];
    [self.regionPicker setDataSource:self];
    [self.view addSubview:self.regionPicker];
    
    [APIDataFetcher fetchRegionWithCompletionBlock:^(NSDictionary *regionsDict, NSError *error) {
        if (!error) {
            self.regionsDict = regionsDict;
            NSLog(@"Got regionsDict: %@", regionsDict);
            [self.regionPicker reloadAllComponents];
        }
        else {
            NSLog(@"error fetching regions: %@", error.localizedDescription);
        }
    }];
    
    UIButton *selectRegionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [selectRegionButton setFrame:CGRectMake(0, 0, self.regionPicker.bounds.size.width, 30)];
    [selectRegionButton setCenter:CGPointMake(self.regionPicker.center.x, self.regionPicker.frame.origin.y + self.regionPicker.frame.size.height + selectRegionButton.bounds.size.height/2)];
    [selectRegionButton setTitle:@"Select" forState:UIControlStateNormal];
    [selectRegionButton addTarget:self action:@selector(regionSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectRegionButton];


    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:1
                     animations:^{
                         [self.bungeeJumper setCenter:CGPointMake(self.bungeeJumper.center.x, self.bungeeJumper.center.y-300)];
                     }
     ];
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

-(void)fetchJobDataForSocCode:(NSString *)socCode jobTitle:(NSString *)jobTitle{

    [APIDataFetcher jobDataSearch:socCode jobTitle:jobTitle completion:^(NSDictionary *results, NSError *error) {
        if(error == nil){
            
            [self.resultsDict addEntriesFromDictionary:results];
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self.tableView setCenter:CGPointMake(self.screenWidth/2, self.screenHeight-self.tableView.bounds.size.height*0.8)];
//                                 [self.jobSearchTextField setCenter:CGPointMake(self.jobSearchTextField.center.x, self.jobSearchTextField.bounds.size.height + self.jobSearchTextField.bounds.size.height*0.1)];
                                 [self.bungeeJumper setCenter:CGPointMake(self.screenWidth - self.bungeeJumper.bounds.size.width/2, self.screenHeight/2)];
                                 [self.titleLabel setCenter:CGPointMake(160, 80)];
                                 [self.titleLabel setFont:[UIFont fontWithName:@"Armata-Regular" size:25]];
                             }
             ];
            [self.tableView reloadData];
        }
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(void)showResults:(NSString *)jobName{
    
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

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSArray *regionNames = [self.regionsDict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    return regionNames[row];
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.regionsDict.allKeys.count;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"selected row %d", row);
    self.selectedRegion = row;
}

-(void)regionSelected{
    
}


@end
