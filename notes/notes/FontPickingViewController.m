//
//  FontPickingViewController.m
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "FontPickingViewController.h"

@interface FontPickingViewController ()

@end

@implementation FontPickingViewController

@synthesize identificator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        fontsArray = [[NSMutableArray alloc] initWithObjects:@"HelveticaNeue",@"Noteworthy-Light",@"Thonburi",@"Verdana",@"GillSans", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[self navigationController]navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fontsArray count];
}

-(void)configureCell:(UITableViewCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    [[cell textLabel] setText:fontsArray[indexPath.row]];
    [[cell textLabel] setFont:[UIFont fontWithName:fontsArray[indexPath.row] size:17]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([[[cell textLabel] text] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:identificator]])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[cell textLabel] setTextColor:[UIColor blackColor]];
        //[[cell textLabel] setTextColor:[UIColor colorWithRed:81.0/255.0 green:102.0/255.0 blue:145.0/255.0 alpha:1.0]];
    } else
        [[cell textLabel] setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:fontsArray[indexPath.row] forKey:identificator];
    
    UITableViewCell* cell = nil;
    
    for (int i = 0; i < [fontsArray count]; ++i)
    {
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (i != indexPath.row)
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            //[[cell textLabel] setTextColor:[UIColor blackColor]];
            [[cell textLabel] setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            //[[cell textLabel] setTextColor:[UIColor colorWithRed:81.0/255.0 green:102.0/255.0 blue:145.0/255.0 alpha:1.0]];
            [[cell textLabel] setTextColor:[UIColor blackColor]];
        }
    }
}

@end
