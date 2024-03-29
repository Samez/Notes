//
//  OptionsViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _VISUAL_SECTION 0
    //#define _SWIPED_CELLS_COLOR 0
    #define _FONT 0

#define _SORT_SECTION 1
    #define _UNSAFE_DELETION 0

#define _SECURITY_SECTION 2
    #define _PSWD_REQUEST_INTERVAL 0
    #define _PSWD 1

#import "OptionsViewController.h"
#import "passwordViewController.h"
#import "TimeIntervalViewController.h"
#import "res.h"
#import "TwoCaseCell.h"
#import "Switchy.h"
#import "LocalyticsSession.h"
#import "notesListViewController.h"
#import "FontTableViewController.h"

@interface OptionsViewController ()

@property UIBarButtonItem* goToNotesListButton;

@end

@implementation OptionsViewController

@synthesize mySwitchCell;
@synthesize NLC;
@synthesize goToNotesListButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        intervalValueArray = [[NSMutableArray alloc] initWithObjects:@0,@(60*60*24*7),@60,@(60*5),@(60*10),@(60*30), nil];
        intervalNameArray = [[NSMutableArray alloc] initWithObjects:@"RIEveryTime",@"RTForOneSession",@"RI1min",@"RI5min",@"RI10min",@"RI30min", nil];
    }
    return self;
}

-(void)setButton
{
    [[self navigationItem] setLeftBarButtonItem:goToNotesListButton];
}

-(void)setupButtons
{
    UIImage* image = [UIImage imageNamed:@"list2.png"];
    CGRect frameimg = CGRectMake(12, 0, 23, 23);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(toNotes)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *bufButton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.goToNotesListButton=bufButton;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(setButton) withObject:nil afterDelay:0.8];
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
}
/*
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
*/
-(void)unsafeDeletionWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_UNSAFE_DELETION inSection:_SORT_SECTION]];
    
    unsafeDeletion = [[cell stateSwitcher] isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool: unsafeDeletion forKey: @"unsafeDeletion"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)toNotes
{

    [UIView transitionFromView:self.view
                        toView:NLC.view
                      duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
    
    [self.navigationController popToViewController:NLC animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupButtons];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setTitle:NSLocalizedString(@"OptionsTitle", nil)];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section)
    {
        case _VISUAL_SECTION:
            count = 1;
            break;
        case _SECURITY_SECTION:
            count = 2;
            break;
        case _SORT_SECTION:
            count = 1;
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
                    /*
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
                    CGContextFillRect(context, rect);
                    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [[MYcell stateSwitcher] setOnImage:img];
                    [[MYcell stateSwitcher] setOffImage:img];
                    
                    [MYcell.stateSwitcher addTarget: self action: @selector(swipeColorWasChanged) forControlEvents:UIControlEventValueChanged];
                    
                    [[MYcell stateSwitcher] setOn:swipeColorIsRed];
                    
                    break;
                }
                     */
                case _FONT:
                {
                    //TODO: FONT
                    
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                    [[cell textLabel] setText:NSLocalizedString(@"FontLabel", nil)];
                    return cell;
                    break;
                }
            }
            break;
        }
        case _SECURITY_SECTION:
        {
            switch(indexPath.row)
            {
                case _PSWD_REQUEST_INTERVAL:
                {
                    UITableViewCell *intervalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    
                    [[intervalCell textLabel] setText:NSLocalizedString(@"PasswordRequestIntervalCell", nil)];
                    
                    [[intervalCell detailTextLabel] setText:NSLocalizedString(@"PasswordRequestInterval", nil)];
                    
                    [intervalCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                    int index = [intervalValueArray indexOfObject:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"]]];
                    
                    [[intervalCell detailTextLabel] setText:NSLocalizedString(intervalNameArray[index], nil)];

                    [[intervalCell detailTextLabel] setTextColor:[UIColor blackColor]];
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
        case _VISUAL_SECTION:
        {
            switch(indexPath.row)
            {
                case _FONT:
                {
                    nextViewController = [[FontTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    break;
                }
            }
            break;
        }
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

- (void)viewDidUnload
{
    [super viewDidUnload];
}
@end
