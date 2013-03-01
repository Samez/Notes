//
//  passwordViewController.m
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _OLD 100
#define _NEW1 101
#define _NEW2 102

NSString * const  _INCORRECT_OLD_PASSWORD = @"Incorrect old password";

NSString * const _PASSWORDS_ARE_NOT_EQUAL = @"Passwords are not equal";

NSString * const _PASSWORD_IS_TOO_SHORT = @"You have entered is too short password. Please, come up with a new password of sufficient length. The password can not be shorter than 8 characters";

NSString * const _DEFAULT_PASSWORD_WARNING=  @"You are using the default password - 'Password'. For the safety come up and enter a new password that is at least 8 characters";

NSString * const _CANT_SAVE = @"I can't save the password";

NSString * const _PASSWORD_DID_CHANGE = @"Password successfully changed";

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
        bottomTitle = nil;
        forOldPassword = nil;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    forOldPassword = nil;
    [super viewWillDisappear:animated];
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

    pass = (Pswd*)fetchedResultsController.fetchedObjects[0];
    
    if([pass.password isEqualToString:@"Password"])
    {
        [self showBottomTitle:_DEFAULT_PASSWORD_WARNING];
        forOldPassword = pass.password;
    }
    
    self.tableView.allowsSelection = NO;
}

-(void)showBottomTitle:(NSString*)title
{
    bottomTitle = title;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)compareNewPasswordOne:(NSString*)passwordOne andNewPasswordTwo:(NSString*)passwordTwo
{
    BOOL flag = NO;
    
    if ([passwordOne isEqualToString:passwordTwo])
    {
        if ([passwordOne length]>=8)
        {
            [self showBottomTitle:_PASSWORD_DID_CHANGE];
            flag = YES;
        } else
        {
            [self showBottomTitle:_PASSWORD_IS_TOO_SHORT];
            flag = NO;
        }
    } else
    {
        [self showBottomTitle:_PASSWORDS_ARE_NOT_EQUAL];
        flag = NO;
    }
    
    return flag;
}

-(BOOL)compareOldPassword:(NSString*)oldPassword andNewPassword:(NSString*)newPassword
{
    BOOL flag = NO;
    
    if ([oldPassword isEqualToString:newPassword])
    {
        forOldPassword = oldPassword;
        flag = YES;
    }
    else
    {
        forOldPassword = nil;
        [self showBottomTitle:_INCORRECT_OLD_PASSWORD];
        flag = NO;
    }
    return flag;
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
        
        if ([self compareOldPassword:pass.password andNewPassword:oldPass])
        {
            if ([self compareNewPasswordOne:newPassOne andNewPasswordTwo:newPassTwo])
            {
                pass.password = newPassOne;
                [self savePass];
            }
        }
    } else
    {
        newPassOne = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) passwordField] text];
        newPassTwo = [[((passwordCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) passwordField] text];
        
        if ([self compareNewPasswordOne:newPassOne andNewPasswordTwo:newPassTwo])
        {
            pass.password = newPassOne;
            [self savePass];
        }
    }
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0 ] withRowAnimation:UITableViewRowAnimationNone];
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
    if ((textField.tag == _OLD)||(textField.tag == _NEW1)||(textField.tag == _NEW2))
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
                    
                    if (forOldPassword)
                        passCell.passwordField.text = forOldPassword;
                    
                    passCell.passwordField.delegate = self;
                    passCell.passwordField.tag = _OLD;
                    break;
                }
                    
                case 1:
                {
                    [passCell.passwordField setPlaceholder:@"Enter new password"];
                    passCell.passwordField.delegate = self;
                    passCell.passwordField.tag = _NEW1;
                    break;
                }
                case 2:
                {
                    [passCell.passwordField setPlaceholder:@"Repeat new password"];
                    passCell.passwordField.delegate = self;
                    passCell.passwordField.tag = _NEW2;
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
