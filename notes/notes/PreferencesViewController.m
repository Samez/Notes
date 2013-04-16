//
//  PreferencesViewController.m
//  notes
//
//  Created by Samez on 10.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "PreferencesViewController.h"
#import "res.h"

#define _SIMPLE_TABBAR 0
#define _ADAPTIVE_BACKGROUND 1
#define _HIDE_PASSWORD 0
#define _UNSAFE_DELETION 1

#define _VISUAL_SECTION 0
#define _SECURITY_SECTION 1

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
    [self LoadSettings];
}

-(void)backgroundstyleWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_ADAPTIVE_BACKGROUND inSection:_VISUAL_SECTION]];
    
    backgroundIsAdaptive = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: backgroundIsAdaptive forKey: @"adaptiveBackground"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)tabBarStyleWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_SIMPLE_TABBAR inSection:_VISUAL_SECTION]];
    
    simplyStyle = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: simplyStyle forKey: @"simplyTabBarStyle"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self restyleTabBar:[self tabBarController]];
    
}

-(void)secureTextEntryWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_HIDE_PASSWORD inSection:_SECURITY_SECTION]];
    
    textEntryIsSecured = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: textEntryIsSecured forKey: @"secureTextEntry"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)unsafeDeletionWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_UNSAFE_DELETION inSection:_SECURITY_SECTION]];
    
    textEntryIsSecured = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: textEntryIsSecured forKey: @"unsafeDeletion"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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

}

- (void) LoadSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"simplyTabBarStyle"] != nil)
    {
        simplyStyle = [[NSUserDefaults standardUserDefaults] boolForKey: @"simplyTabBarStyle"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"adaptiveBackground"] != nil)
    {
        backgroundIsAdaptive = [[NSUserDefaults standardUserDefaults] boolForKey: @"adaptiveBackground"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"secureTextEntry"] != nil)
    {
        textEntryIsSecured = [[NSUserDefaults standardUserDefaults] boolForKey: @"secureTextEntry"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] != nil)
    {
        unsafeDeletion = [[NSUserDefaults standardUserDefaults] boolForKey:@"unsafeDeletion"];
    }
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
    NSInteger count = 0;
    
    switch (section)
    {
        case _VISUAL_SECTION:
            count = 2;
            break;
        case _SECURITY_SECTION:
            count = 2;
            break;
    }
    
    return count;
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
    
    switch (indexPath.section)
    {
        case _VISUAL_SECTION:
        {
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
            break;
        }
        case _SECURITY_SECTION:
        {
            switch(indexPath.row)
            {
                case _HIDE_PASSWORD:
                {
                    [[MYcell myTextLabel] setText:NSLocalizedString(@"HidePasswordCell", nil)];
                    
                    [MYcell.stateSwitcher addTarget:self action:@selector(secureTextEntryWasChanged) forControlEvents:UIControlEventValueChanged];
                    
                    [[MYcell stateSwitcher] setOn:textEntryIsSecured];
                    break;
                }
                case _UNSAFE_DELETION:
                {
                    [[MYcell myTextLabel] setText:NSLocalizedString(@"unsafeDetetionCell", nil)];
                    
                    [MYcell.stateSwitcher addTarget:self action:@selector(unsafeDeletionWasChanged) forControlEvents:UIControlEventValueChanged];
                    
                    [[MYcell stateSwitcher] setOn:unsafeDeletion];
                    break;
                }    
            }
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
