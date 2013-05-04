//
//  OptionsViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _VISUAL_SECTION 0
    #define _SWIPED_CELLS_COLOR 0
    #define _SIMPLE_TABBAR 1

#define _SORT_SECTION 1
    #define _UPDATE_TIME 0
    #define _UNSAFE_DELETION 1

#define _SECURITY_SECTION 2
    #define _HIDE_PASSWORD 0
    #define _PSWD_REQUEST_INTERVAL 1
    #define _PSWD 2

#import "OptionsViewController.h"
#import "passwordViewController.h"
#import "TimeIntervalViewController.h"
#import "res.h"
#import "TwoCaseCell.h"
#import "Switchy.h"
#import "LocalyticsSession.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

@synthesize mySwitchCell;
@synthesize twoCaseCell;

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
    [[LocalyticsSession shared] tagScreen:@"Options"];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case _VISUAL_SECTION:
        {
            //title = @"Внешний вид";
            break;
        }
        case _SORT_SECTION:
        {
            //title = @"";
            break;
        }
        case _SECURITY_SECTION:
        {
            //title = @"Безопасность";
            break;
        }
    }
    
    return title;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self LoadSettings];
    [self.tableView reloadData];
}

- (void) LoadSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"simplyTabBarStyle"] != nil)
    {
        simplyStyle = [[NSUserDefaults standardUserDefaults] boolForKey: @"simplyTabBarStyle"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"secureTextEntry"] != nil)
    {
        textEntryIsSecured = [[NSUserDefaults standardUserDefaults] boolForKey: @"secureTextEntry"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] != nil)
    {
        unsafeDeletion = [[NSUserDefaults standardUserDefaults] boolForKey:@"unsafeDeletion"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] != nil)
    {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"];
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
        if ([color isEqual:[UIColor sashaGray]])
            swipeColorIsRed = NO;
        else
            swipeColorIsRed = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"needUpdateTime"] != nil)
    {
        needUpdateTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"needUpdateTime"];
    }
}

-(void)needUpdateTimeWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_UPDATE_TIME inSection:_SORT_SECTION]];
    
    needUpdateTime = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: needUpdateTime forKey: @"needUpdateTime"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)swipeColorWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_SWIPED_CELLS_COLOR inSection:_VISUAL_SECTION]];
    
    swipeColorIsRed = [[cell stateSwitcher] isOn];
    
    UIColor *color = [[UIColor alloc] init];
    
    if (swipeColorIsRed)
        color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.8];
    else
        color = [UIColor sashaGray];
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"swipeColor"];
    
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
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_UNSAFE_DELETION inSection:_SORT_SECTION]];
    
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
    
    [self setTitle:NSLocalizedString(@"OptionsTitle", nil)];
    
    [[[self navigationController]navigationBar] setBarStyle:UIBarStyleBlack];
    
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
            count = 3;
            break;
        case _SORT_SECTION:
            count = 2;
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
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
                case _SWIPED_CELLS_COLOR:
                {
                    [[MYcell myTextLabel] setText:NSLocalizedString(@"CellsToDeleteColor", nil)];
                    [[MYcell stateSwitcher] setOnTintColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]];
                    [[MYcell stateSwitcher] setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
                    [[MYcell stateSwitcher] setThumbTintColor:[UIColor whiteColor]];
                    
                    CGRect rect = CGRectMake(-500, -500, 1, 1);
                    UIGraphicsBeginImageContext(rect.size);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetFillColorWithColor(context,
                                                   [[UIColor redColor] CGColor]);
                    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
                    CGContextFillRect(context, rect);
                    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [[MYcell stateSwitcher] setOnImage:img];
                    [[MYcell stateSwitcher] setOffImage:img];
                    
                    [MYcell.stateSwitcher addTarget: self action: @selector(swipeColorWasChanged) forControlEvents:UIControlEventValueChanged];
                    
                    [[MYcell stateSwitcher] setOn:swipeColorIsRed];
                    
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
                case _PSWD_REQUEST_INTERVAL:
                {
                    UITableViewCell *intervalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    
                    [[intervalCell textLabel] setText:NSLocalizedString(@"PasswordRequestIntervalCell", nil)];
                    
                    [[intervalCell detailTextLabel] setText:NSLocalizedString(@"PasswordRequestInterval", nil)];
                    
                    [intervalCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                    switch([[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"])
                    {
                        case 0:
                        {
                            [[intervalCell detailTextLabel] setText:NSLocalizedString(@"RIEveryTime", nil)];
                            break;
                        }
                        case 60*60*24*7:
                        {
                            [[intervalCell detailTextLabel] setText:NSLocalizedString(@"RTForOneSession", nil)];
                            break;
                        }
                        case 60:
                        {
                            [[intervalCell detailTextLabel] setText:NSLocalizedString(@"RI1min", nil)];
                            break;
                        }
                        case 60*5:
                        {
                            [[intervalCell detailTextLabel] setText:NSLocalizedString(@"RI5min", nil)];
                            break;
                        }
                        case 60*10:
                        {
                            [[intervalCell detailTextLabel] setText:NSLocalizedString(@"RI10min", nil)];
                            break;
                        }
                        case 60*30:
                        {
                            [[intervalCell detailTextLabel] setText:NSLocalizedString(@"RI30min", nil)];
                            break;
                        }
                    }
                    
                    return intervalCell;
                    break;
                }
                case _PSWD:
                {
                    [[cell textLabel] setText:NSLocalizedString(@"ChangePasswordCell", nil)];
                    
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                    
                    return cell;
                }
            }
            break;
        }
        case _SORT_SECTION:
        {
            
            switch (indexPath.row)
            {
                case _UPDATE_TIME:
                {
                    [[MYcell myTextLabel] setText:NSLocalizedString(@"UpdateTimeIfDidEdit", nil)];
                    
                    [MYcell.stateSwitcher addTarget:self action:@selector(needUpdateTimeWasChanged) forControlEvents:UIControlEventValueChanged];
                    
                    [[MYcell stateSwitcher] setOn:needUpdateTime];
                }
                break;
            
            
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
    
    [MYcell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIFont *myFont = [ UIFont fontWithName: @"Helvetica-Bold" size: 17.0];
    [[MYcell myTextLabel] setFont:myFont];
    return MYcell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *nextViewController = nil;

    switch ([indexPath section])
    {
        case _SECURITY_SECTION:
        {
            switch (indexPath.row)
            {
                case _PSWD:
                {
                    nextViewController = [[passwordViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    break;
                }
                case _PSWD_REQUEST_INTERVAL:
                {
                    nextViewController = [[TimeIntervalViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    break;
                }
            }
        break;
        }
    }
    
    if (nextViewController)
    {
        [[self navigationController] pushViewController:nextViewController animated:YES];
    }
}


- (void)viewDidUnload {
    [self setTwoCaseCell:nil];
    [super viewDidUnload];
}
@end
