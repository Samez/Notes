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
#import "askPasswordViewController.h"
#import "testAddViewController.h"

@interface notesListViewController ()

@property (nonatomic)noteListCell* selectedCell;

@end

@implementation notesListViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize noteCell;
@synthesize selectedCell;

- (void)viewDidLoad
{
    [self setTitle:@"Notes"];

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    [self tableView].tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.tableView indexPathForSelectedRow] isEqual:indexPath]){
        return [selectedCell heightForTableView];
    }
    return 50;
}

- (void)showNote:(Note *)note animated:(BOOL)animated;
{
    /*if (![note.isPrivate boolValue])
    {        
        testAddViewController *nextC = [[testAddViewController alloc] init];
        [nextC setNote:note];
        [nextC setForEditing:YES];
        [nextC setManagedObjectContext:managedObjectContext];
        nextC.notesCount = [[fetchedResultsController fetchedObjects] count];
        [self.navigationController pushViewController:nextC animated:YES];
    } else
    {
        askPasswordViewController * nextController = [[askPasswordViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [nextController setNote:note];
        [nextController setManagedObjectContext:managedObjectContext];
        [nextController setNotesCount:[[fetchedResultsController fetchedObjects] count]];
        //[self.navigationController pushViewController:nextController animated:YES];
    }*/
    
}

-(void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
    [cell setN:note];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
    selectedCell=(noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [selectedCell tryOpen:self];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //[self showNote:note animated:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectedCell.passwordField resignFirstResponder];
    selectedCell=nil;
    //[super tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

-(NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self.tableView indexPathForSelectedRow] isEqual:indexPath])
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [selectedCell.passwordField resignFirstResponder];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        return nil;
    }
    return indexPath;
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
    // Detemine if it's in editing mode
    if (self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)add:(id)sender
{
    testAddViewController *nextC = [[testAddViewController alloc] init];
    
    //addNewNoteViewController *addController = [[addNewNoteViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
	Note *newNote = (Note*)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
	//addController.note = newNote;
    
    nextC.note = newNote;
    nextC.managedObjectContext = managedObjectContext;
    nextC.notesCount = [[fetchedResultsController fetchedObjects] count];
    
    [self.navigationController pushViewController:nextC animated:YES];
    //addController.managedObjectContext = managedObjectContext;
    
    //[self.navigationController pushViewController:addController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[fetchedResultsController sections] count];
    
	if (count == 0)
    {
		count = 1;
	}
	
    return count;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"noteListCell";
    noteListCell *MYcell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if (MYcell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"noteListCell" owner:self options:nil];
        MYcell = noteCell;
        noteCell = nil;
    }
    
    [self configureCell:MYcell atIndexPath:indexPath];
    MYcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    MYcell.delegate=self;
    
    return MYcell;
}

#define fetched result controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
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
			[self configureCell:(noteListCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
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

- (void)viewDidUnload {
    [self setNoteCell:nil];
    [super viewDidUnload];
}

-(void) openNote:(Note *)note
{
    testAddViewController *nextC = [[testAddViewController alloc] init];
    [nextC setNote:note];
    [nextC setForEditing:YES];
    [nextC setManagedObjectContext:managedObjectContext];
    nextC.notesCount = [[fetchedResultsController fetchedObjects] count];
    [self.navigationController pushViewController:nextC animated:YES];
}
@end
