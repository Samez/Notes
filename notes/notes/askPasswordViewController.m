//
//  askPasswordViewController.m
//  notes
//
//  Created by Samez on 27.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _INCORRECT_PSWD @"Incorrect password!"

#import "askPasswordViewController.h"
#import "addNewNoteViewController.h"
#import "testAddViewController.h"

@interface askPasswordViewController ()

@end

@implementation askPasswordViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize note;
@synthesize pass;
@synthesize notesCount;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        passViewController = [[passwordViewController alloc] initWithStyle:style];
        bottomTitle = nil;
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 666)
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self tryToEnter];
}

-(void)tryToEnter
{
    passwordCell *cell = (passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if ([cell.passwordField.text isEqualToString:pass.password])
    {
        testAddViewController *nextC = [[testAddViewController alloc] init];
        [nextC setNote:note];
        [nextC setForEditing:YES];
        [nextC setManagedObjectContext:managedObjectContext];
        nextC.notesCount = notesCount;
        [self.navigationController pushViewController:nextC animated:YES];
        
    } else
    {
        [self showBottomTitle:_INCORRECT_PSWD];
    }
    
}

-(void)showBottomTitle:(NSString*)title
{
    if (title)
    {
        bottomTitle = title;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationFade];
    } else
    {
        bottomTitle = nil;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    pass = (Pswd*)fetchedResultsController.fetchedObjects[0];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(tryToEnter)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    self.tableView.allowsSelection = NO;
    
    self.tableView.backgroundColor=[UIColor clearColor];
    UIImage *backgroundImage = [UIImage imageNamed:@"woodenBackground.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:backgroundImage];
    self.tableView.backgroundView=backgroundImageView;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case 0:
            title = bottomTitle;
            break;
    }
    
    return title;
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *passCellIdentifier = @"pswdCell";
    
    passwordCell *passCell = [tableView dequeueReusableCellWithIdentifier:passCellIdentifier];
    
    if (passCell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"passwordCell" owner:passViewController options:nil];
        passCell = [topLevelObjects objectAtIndex:0];
    }
    
    [passCell.passwordField setPlaceholder:@"Enter password"];
    
    [passCell.passwordField setDelegate:self];
    [passCell.passwordField setTag:666];
    [passCell.passwordField setReturnKeyType:UIReturnKeyDone];
    [passCell.passwordField setSecureTextEntry:YES];
    
    return passCell;
}


#pragma mark - Table view delegate

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
        self.fetchedResultsController = aFetchedResultsController;
        
    }
	
	return fetchedResultsController;
}

@end
