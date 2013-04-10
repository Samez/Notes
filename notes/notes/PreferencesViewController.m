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

@synthesize backgroundFRC, tabBarStyleFRC;
@synthesize managedObjectContext;
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

-(void) tabBarStyleWasChanged
{
    CellWithSwitcher *cell = (CellWithSwitcher*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_SIMPLE_TABBAR inSection:0]];
    
    simplyStyle = [NSNumber numberWithBool:[[cell stateSwitcher] isOn]];
    
    if ([[tabBarStyleFRC fetchedObjects] count] >0)
        [(TabBarStyle*)[tabBarStyleFRC fetchedObjects][0] setSimplyStyle: [NSNumber numberWithBool:[[cell stateSwitcher] isOn]]];
    
    NSError *error;
    
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
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
    
    NSError *error = nil;
    
	if (![[self tabBarStyleFRC] performFetch:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    if ([[tabBarStyleFRC fetchedObjects] count] > 0)
        simplyStyle = [[(TabBarStyle*)[tabBarStyleFRC fetchedObjects][0] simplyStyle] boolValue];
    NSError *err = nil;
    
    if (![[self backgroundFRC] performFetch:&err])
    {
		NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
		abort();
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
            break;
        }
        
    }
    
    return MYcell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] endUpdates];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
            if ([[tabBarStyleFRC fetchedObjects] count] > 0)
                simplyStyle = [[(TabBarStyle*)[tabBarStyleFRC fetchedObjects][0] simplyStyle] boolValue];
            //[self restyleTabBar:[self tabBarController]];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (NSFetchedResultsController *)tabBarStyleFRC
{
    // Set up the fetched results controller if needed.
    if (tabBarStyleFRC == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TabBarStyle" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"simplyStyle" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.tabBarStyleFRC = aFetchedResultsController;
        
    }

	return tabBarStyleFRC;
}

- (NSFetchedResultsController *)backgroundFRC
{
    // Set up the fetched results controller if needed.
    if (backgroundFRC == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AdaptiveBackground" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"backgroundIsAdaptive" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.backgroundFRC = aFetchedResultsController;
        
    }
	
	return backgroundFRC;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
@end
