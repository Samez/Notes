//
//  notesListViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "notesListViewController.h"
#import "detailViewController.h"
#import "addNewNoteViewController.h"
#import "testAddViewController.h"
#import "Pswd.h"
#import "res.h"

@interface notesListViewController ()

@property UIBarButtonItem* editButton;
@property UIBarButtonItem* doneButton;
@property UIBarButtonItem* deleteButton;

@end

@implementation notesListViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize noteCell;
@synthesize passwordFetchedResultsController;
@synthesize editButton;
@synthesize doneButton;

-(void)checkSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"simplyTabBarStyle"] != nil)
    {
        simpleTabBar = [[NSUserDefaults standardUserDefaults] boolForKey: @"simplyTabBarStyle"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkSettings];
    
    [self setTitle:NSLocalizedString(@"NotesTitle", nil)];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    self.editButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editing)];
    self.doneButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editing)];

    
    [[self navigationItem] setRightBarButtonItem:addButtonItem];
    [self.navigationItem setLeftBarButtonItem:self.editButton];
    
    NSError *error = nil;
    
    self.tableView.allowsMultipleSelectionDuringEditing=YES;
    
	if (![[self fetchedResultsController] performFetch:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    NSError *err = nil;
    
    if (![[self passwordFetchedResultsController] performFetch:&err])
    {
		NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
		abort();
	}
    
    if ([[passwordFetchedResultsController fetchedObjects] count] > 0)
        PSWD = [passwordFetchedResultsController fetchedObjects][0];
    
    iP = nil;
    keyboardIsActive = NO;
}

-(void) editing
{
    if ([self.tableView isEditing])
    {
        [self.navigationItem setLeftBarButtonItem:self.editButton];
        [self.tableView setEditing:NO animated:YES];   
    }else{
        [self.navigationItem setLeftBarButtonItem:self.doneButton];
        [self.tableView setEditing:YES animated:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showTabBar:[self tabBarController]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [self checkSettings];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    int height = 0;
    
    if (simpleTabBar)
        height = _SIMLPE_TABBAR_HEIGHT;
    else
        height = _STANDART_TABBAR_HEIGHT;
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    for(UIView *view in [[tabbarcontroller view] subviews])
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([iP isEqual:indexPath])
        return 85;
    else
        return 50;
}

- (void)showNote:(Note *)note animated:(BOOL)animated;
{  
        testAddViewController *nextC = [[testAddViewController alloc] init];
        [nextC setNote:note];
        [nextC setForEditing:YES];
        [nextC setManagedObjectContext:managedObjectContext];
        [nextC setNotesCount:[[fetchedResultsController fetchedObjects] count]];
        
        [[self navigationController] pushViewController:nextC animated:YES];
}

-(void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
    [cell setN:note];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [[cell passwordField]  setReturnKeyType:UIReturnKeyDone];
    
    [[cell passwordField] setDelegate:self];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"secureTextEntry"])
        [[cell passwordField]  setSecureTextEntry:YES];
    else
        [[cell passwordField]  setSecureTextEntry:NO];
}

-(void)tryEnter
{
    noteListCell *cell = (noteListCell*)[[self tableView] cellForRowAtIndexPath:iP];

    
    if ([[[cell passwordField] text] isEqualToString:[PSWD password]])
    {
        testAddViewController *nextC = [[testAddViewController alloc] init];
        
        [nextC setManagedObjectContext:managedObjectContext];
        [nextC setNotesCount:[[fetchedResultsController fetchedObjects] count]];
        [nextC setNote:[[fetchedResultsController fetchedObjects] objectAtIndex:iP.row]];
        iP = nil;
        [[self navigationController] pushViewController:nextC animated:YES];
        
    } else
    {
        [cell setAlertImage];
    }
}

-(void)changeTableViewHeightAt:(CGFloat)deltaHeight
{
    [UIView animateWithDuration:0.25 delay:0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.tableView.frame= CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + deltaHeight);
                     }
                     completion:^(BOOL finished){
                     }];
    
    if (deltaHeight < 0)
        [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    else
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
     

}

-(void)didSelectPrivateNoteAtIndexPath:(NSIndexPath*)indexPath
{
    if (iP == nil)
    {
        iP = indexPath;
        
        [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
        
        [self.tableView beginUpdates];
        
        [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
        
        [self.tableView endUpdates];
        
        if (simpleTabBar)
            [self changeTableViewHeightAt:-_SIMPLY_TABBAR_CHANGE_VALUE];
        else
            [self changeTableViewHeightAt:-_NORMAL_TABBAR_CHANGE_VALUE];
    }
    else
    {
        if (![iP isEqual:indexPath])
        {
            [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:nil];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] hidePasswordField];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] setNormalImage];
            
            iP = indexPath;
            
            [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
            
        } else
        {
            [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:nil];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] hidePasswordField];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] setNormalImage];
            
            if (simpleTabBar)
                [self changeTableViewHeightAt:_SIMPLY_TABBAR_CHANGE_VALUE];
            else
                [self changeTableViewHeightAt:_NORMAL_TABBAR_CHANGE_VALUE];
            
            iP = nil;
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        [[self.tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleGray];
    }else [[self.tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        return;
    }
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    
    Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
        
    if ([[note isPrivate] boolValue])
    {
        [self didSelectPrivateNoteAtIndexPath:indexPath];
    } else
    {
        if (iP != nil)
        {
            [[(noteListCell*)[tableView cellForRowAtIndexPath:iP] passwordField] setTag:nil];
            [(noteListCell*)[tableView cellForRowAtIndexPath:iP] hidePasswordField];
            iP = nil;
        }
        [self showNote:note animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
	}
    
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isEditing])
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)add:(id)sender
{
    if (iP != nil)
    {
        [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] hidePasswordField];
        iP = nil;
    }
    
    testAddViewController *nextC = [[testAddViewController alloc] init];
    
    [nextC setManagedObjectContext:managedObjectContext];
    [nextC setNotesCount:[[fetchedResultsController fetchedObjects] count]];
    [nextC setNote:nil];
    
    [[self navigationController] pushViewController:nextC animated:YES];
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
    NSInteger numberOfRows = 0;
	
    if ([[fetchedResultsController sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] == 666)
    {
        [textField resignFirstResponder];
        [self tryEnter];
        return NO;
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"noteListCell";
    
    noteListCell *MYcell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (!MYcell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"noteListCell" owner:self options:nil];
        MYcell = noteCell;
        noteCell = nil;
    }
    
    [[MYcell passwordField] setAlpha:0.0];
    
    [self configureCell:MYcell atIndexPath:indexPath];


    return MYcell;
}

#define fetched result controller

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
        {
			[self configureCell:(noteListCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            if ([[passwordFetchedResultsController fetchedObjects] count] > 0)
                PSWD = [passwordFetchedResultsController fetchedObjects][0];

			break;
        }
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (NSFetchedResultsController *)passwordFetchedResultsController
{
    // Set up the fetched results controller if needed.
    if (passwordFetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pswd" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"password" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        
        self.passwordFetchedResultsController = aFetchedResultsController;
    }
    
	return passwordFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
    }
	
	return fetchedResultsController;
}

- (void)viewDidUnload
{
    [self setNoteCell:nil];
    [super viewDidUnload];
}
@end
