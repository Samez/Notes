//
//  OptionsViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _PSWD 0
#define _PREF 1

#import "OptionsViewController.h"
#import "passwordViewController.h"
#import "PreferencesViewController.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"OptionsTitle", nil)];
    
    [[[self navigationController]navigationBar] setBarStyle:UIBarStyleBlack];
    
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    switch ([indexPath section])
    {
        case _PSWD:
        {
            [[cell textLabel] setText:NSLocalizedString(@"ChangePasswordCell", nil)];
            break;
        }
            
        case _PREF:
        {
            [[cell textLabel] setText:NSLocalizedString(@"PreferenceCell", nil)];
            break;
        }
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *nextViewController = nil;

    switch ([indexPath section])
    {
        case _PSWD:
        {
            nextViewController = [[passwordViewController alloc] initWithStyle:UITableViewStyleGrouped];            
            break;
        }
            
        case _PREF:
        {
            nextViewController = [[PreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            break;
        }
    }
    
    if (nextViewController)
    {
        [[self navigationController] pushViewController:nextViewController animated:YES];
    }
}


@end
