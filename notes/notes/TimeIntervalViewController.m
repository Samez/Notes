//
//  TimeIntervalViewController.m
//  notes
//
//  Created by Samez on 28.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "TimeIntervalViewController.h"
#import "LocalyticsSession.h"

@interface TimeIntervalViewController ()

@end

@implementation TimeIntervalViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [[LocalyticsSession shared] tagScreen:@"Time interval"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(NSInteger)intervalIndex
{
    NSInteger index = 0;
    
    switch([[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"])
    {
        case 0:
        {
            index = 0;
            break;
        }
        case 60*60*24*7:
        {
            index = 1;
            break;
        }
        case 60:
        {
            index = 2;
            break;
        }
        case 60*5:
        {
            index = 3;
            break;
        }
        case 60*10:
        {
            index = 4;
            break;
        }
        case 60*30:
        {
            index = 5;
            break;
        }
    }
    
    return index;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    switch(indexPath.row)
    {
        case 0:
        {
            [[cell textLabel] setText:NSLocalizedString(@"RIEveryTime", nil)];
            break;
        }
        case 1:
        {
            [[cell textLabel]setText:NSLocalizedString(@"RTForOneSession", nil)];
            break;
        }
        case 2:
        {
            [[cell textLabel] setText:NSLocalizedString(@"RI1min", nil)];
            break;
        }
        case 3:
        {
            [[cell textLabel] setText:NSLocalizedString(@"RI5min", nil)];
            break;
        }
        case 4:
        {
            [[cell textLabel] setText:NSLocalizedString(@"RI10min", nil)];
            break;
        }
        case 5:
        {
            [[cell textLabel] setText:NSLocalizedString(@"RI30min", nil)];
            break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    if (indexPath.row == [self intervalIndex])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = nil;
    
    for (int i = 0; i < 6; ++i)
    {
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i != indexPath.row)
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        else
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    NSInteger interval = 0;
    
    switch(indexPath.row)
    {
        case 0:
        {
            interval = 0;
            break;
        }
        case 1:
        {
            interval = 60*60*24*7;
            break;
        }
        case 2:
        {
            interval = 60;
            break;
        }
        case 3:
        {
            interval = 60*5;
            break;
        }
        case 4:
        {
            interval = 60*10;
            break;
        }
        case 5:
        {
            interval = 60*30;
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:interval forKey:@"PasswordRequestInterval"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:1] forKey:@"lastTime"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
