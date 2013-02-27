//
//  passwordViewController.m
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "passwordViewController.h"
#import "Pswd.h"

@interface passwordViewController ()

@end

@implementation passwordViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize pass;
@synthesize pswdCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

        rowsCount =  0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if ([fetchedResultsController.fetchedObjects count] == 0)
    {
        Pswd* newPassword = (Pswd*)[NSEntityDescription insertNewObjectForEntityForName:@"Pswd" inManagedObjectContext:self.managedObjectContext];
        
        NSError *error = nil;
        
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        pass = newPassword;
    } else
    {
        pass = (Pswd*)fetchedResultsController.fetchedObjects[0];
    }
}

-(void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)save
{
    NSString *oldPass = nil;
    NSString *newPassOne = nil;
    NSString *newPassTwo = nil;
    
    if (pass.password)
    {
        oldPass = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) passwordField] text];
        newPassOne = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) passwordField] text];
        newPassTwo = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]) passwordField] text];
        
        if ([pass.password isEqualToString: oldPass])
        {
            if ([newPassTwo isEqualToString:newPassOne])
            {
                pass.password = newPassOne;
                [self savePass];
            } else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Не могу сохранить пароль" message:@"пароли не совпадают" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        } else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Не могу сохранить пароль" message:@"Вы ввели неверный старый пароль" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    } else
    {
        newPassOne = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) passwordField] text];
        newPassTwo = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) passwordField] text];
        
        if ([newPassTwo isEqualToString:newPassOne])
        {
            pass.password = newPassOne;
            [self savePass];
        }else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Не могу сохранить пароль" message:@"пароли не совпадают" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
    }

}

-(void)savePass
{
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ((textField.tag == 1)||(textField.tag == 2)||(textField.tag == 3))
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
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
    if (pass.password)
        return 3;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *passCellIdentifier = @"pswdCell";
    
    passwordCell *passCell = [tableView dequeueReusableCellWithIdentifier:passCellIdentifier];
    
    if (passCell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"passwordCell" owner:self options:nil];
        passCell = [topLevelObjects objectAtIndex:0];
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    if ([(Pswd*)fetchedResultsController.fetchedObjects[0] password])
                    {
                        [passCell.passwordField setPlaceholder:@"Enter old password"];
                    } else
                    {
                        [passCell.passwordField setPlaceholder:@"Enter new password"];
                    }
                    
                    passCell.passwordField.delegate = self;
                    passCell.passwordField.tag = 3;
                    break;
                }
                    
                case 1:
                {
                    [passCell.passwordField setPlaceholder:@"Enter new password"];
                    passCell.passwordField.delegate = self;
                    passCell.passwordField.tag = 1;
                    break;
                }
                case 2:
                {
                    [passCell.passwordField setPlaceholder:@"Repeat new password"];
                    passCell.passwordField.delegate = self;
                    passCell.passwordField.tag = 2;
                    break;
                }
            }
        }

    }
    
    [passCell.passwordField setSecureTextEntry:YES];
    return passCell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


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

- (void)viewDidUnload {
    [self setPswdCell:nil];
    [super viewDidUnload];
}
@end
