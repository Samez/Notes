//
//  PreferencesViewController.m
//  notes
//
//  Created by Samez on 10.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "PreferencesViewController.h"
#import "TabBarStyle.h"
#import "AdaptiveBackground.h"
#import "res.h"

#define _SIMPLE_TABBAR 0
#define _ADAPTIVE_BACKGROUND 1

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

@synthesize mySwitchCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)backgroundstyleWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_ADAPTIVE_BACKGROUND inSection:0]];
    
    backgroundIsAdaptive = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: [[cell stateSwitcher] isOn] forKey: @"adaptiveBackground"];
}

-(void) tabBarStyleWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_SIMPLE_TABBAR inSection:0]];
    
    simplyStyle = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: [[cell stateSwitcher] isOn] forKey: @"simplyTabBarStyle"];

    [self restyleTabBar:[self tabBarController]];
}

-(void)restyleTabBar:(UITabBarController*)tabbarcontroller
{
    int height = 0;
    
    if (simplyStyle)
        height = _SIMLPE_TABBAR_HEIGHT;
    else
        height = _STANDART_TABBAR_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, height, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, 320, height)];
        }
    }
    
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setAllowsSelection:NO];
    
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"simplyTabBarStyle"] != nil)
    {
        simplyStyle = [[NSUserDefaults standardUserDefaults] boolForKey: @"simplyTabBarStyle"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"adaptiveBackground"] != nil)
    {
        backgroundIsAdaptive = [[NSUserDefaults standardUserDefaults] boolForKey: @"adaptiveBackground"];
    }

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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"CellWithSwitcher";
    
    CellWithSwitcher *MYcell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (!MYcell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"CellWithSwitcher" owner:self options:nil];
        
        MYcell = mySwitchCell;
        
        mySwitchCell = nil;
    }
    
    switch (indexPath.row)
    {
        case _SIMPLE_TABBAR:
        {
            [[MYcell myTextLabel] setText:NSLocalizedString(@"SimpleTabBarStyleCell", nil)];
            
            [MYcell.stateSwitcher addTarget: self action: @selector(tabBarStyleWasChanged) forControlEvents:UIControlEventValueChanged];
            
            [[MYcell stateSwitcher] setOn:simplyStyle];
            
            break;
        }
        case _ADAPTIVE_BACKGROUND:
        {
            [[MYcell myTextLabel] setText:NSLocalizedString(@"AdaptiveBackgroundCell", nil)];
            
            [MYcell.stateSwitcher addTarget:self action:@selector(backgroundstyleWasChanged) forControlEvents:UIControlEventValueChanged];
            
            [[MYcell stateSwitcher] setOn:backgroundIsAdaptive];
            
            break;
        }
        
    }
    
    return MYcell;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
@end
