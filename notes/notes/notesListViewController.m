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
#import "Note.h"
#import "passwordAlertView.h"

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

-(void)fillBD
{
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    int len = 14;
    
    for (int i = 0; i<15; ++i)
    {
        NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
        
        for (int i=0; i<len; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
        }
        
        Note *note = (Note*)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
        [note setText:@"lolwto"];
        [note setName:randomString];
        [note setDate:[NSDate date]];
        [note setIsPrivate:[NSNumber numberWithUnsignedInt:arc4random()%2]];
    }
    
    NSError *error = nil;
    
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    for (UITableViewCell* cell in [self.tableView visibleCells])
    {
        if ([swipedCells containsObject:[self.tableView indexPathForCell:cell]])
        {
            [self swipeCellAtIndexPath:[self.tableView indexPathForCell:cell] at:+2 withTargetColor:[UIColor redColor]];
        }
    }
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkSettings];
    
    [self.tableView setDelegate:self];
    
    [self setTitle:NSLocalizedString(@"NotesTitle", nil)];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    
    [[self navigationItem] setRightBarButtonItem:addButtonItem];
    
    UIBarButtonItem *fillBD = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fillBD)];
    
    [[self navigationItem] setLeftBarButtonItem:fillBD];
    
    NSError *error = nil;
    
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
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
}

-(BOOL)showPromptAlert
{
    passwordAlertView *passwordAlert = [[passwordAlertView alloc] initWithTitle:NSLocalizedString(@"PasswordCheckAlertViewTitle", nil)
                                                            message:NSLocalizedString(@"EnterPasswordToDeleteTitle",nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                                  otherButtonTitles:@"OK", nil];
    
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.secureTextEntry = YES;
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.delegate = self;
    [passwordField setTag:1919];
    [passwordField becomeFirstResponder];
    [passwordAlert addSubview:passwordField];
        
    [passwordAlert show];
    
    [passwordAlert setDelegate:self];
    
    return YES;
}

-(void)deleteSwipedCells
{
    for (int i = 0; i < [swipedCells count]; ++i)
    {
        Note* mo = (Note*)[fetchedResultsController objectAtIndexPath:swipedCells[i]];
        
        [managedObjectContext deleteObject:mo];
    }
    
    NSError *error = nil;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    swipedCells = nil;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    [self.tableView setAllowsSelection:YES];
    
}

-(void)deselectSwipedCells
{
    for (int i = 0; i < [swipedCells count]; ++i)
        {
            [self swipeCellAtIndexPath:swipedCells[i] at:-27 withTargetColor:[UIColor whiteColor]];
        }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    [self.tableView setAllowsSelection:YES];
    
    swipedCells = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
        for (UIView* view in alertView.subviews)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                UITextField* textField = (UITextField*)view;
                if ([[textField text] isEqualToString:[PSWD password]])
                {
                    [self deleteSwipedCells];
                    [(passwordAlertView*)alertView setPasswordIsAccepted:YES];
                }
                else
                    [alertView setMessage:NSLocalizedString(@"WrongPasswordAlert", nil)];
            } 
        }

    if (buttonIndex == 0 )
        [self deselectSwipedCells];
}

-(void)tryToDeleteSelectedCells
{
    BOOL havePrivateNote = NO;
    
    for (int i = 0; i < [swipedCells count]; ++i)
    {
        if ([[(Note*)[fetchedResultsController objectAtIndexPath:swipedCells[i]] isPrivate] boolValue])
            havePrivateNote = YES;
    }
    
    if (havePrivateNote)
        [self showPromptAlert];
    else
        [self deleteSwipedCells];
}

/*
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
*/

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (swipedCells == nil)
        swipedCells = [[NSMutableArray alloc] init];

    if ([swipedCells containsObject:indexPath])
    {
        [swipedCells removeObject:indexPath];
        [self swipeCellAtIndexPath:indexPath at:-27 withTargetColor:[UIColor whiteColor]];
        //noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        //[cell swipeCellAt:-27];
    }
    
    noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    [[cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    
    if ([swipedCells count] == 0)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        [self.tableView setAllowsSelection:YES];
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    
    [self.tableView setAllowsSelection:NO];
    
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (indexPath != nil)
    {
        if ([swipedCells count] == 0)
        {
            UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tryToDeleteSelectedCells)];
            self.navigationItem.rightBarButtonItem = deleteButton;
        }

        if (iP != nil)
        {
            [self didSelectPrivateNoteAtIndexPath:iP];
        }
        
        if (swipedCells == nil)
            swipedCells = [[NSMutableArray alloc] init];

        if (![swipedCells containsObject:indexPath])
        {
            
            [swipedCells addObject:indexPath];
            
            [self swipeCellAtIndexPath:indexPath at:+27 withTargetColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3]];
            //noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            //[cell swipeCellAt:+27];
        }
        
        noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];

        [[cell timeLabel] setTextColor:[UIColor whiteColor]];
    }
}

-(void)swipeCellAtIndexPath:(NSIndexPath*)indexPath at:(CGFloat)xPixels withTargetColor:(UIColor*)color
{
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                         [cell setBackgroundColor:color];
                         [cell setFrame:CGRectMake(cell.frame.origin.x + xPixels, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [self deselectSwipedCells];
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
    
    [[cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    
    [[cell passwordField]  setReturnKeyType:UIReturnKeyDone];
    
    [[cell passwordField] setDelegate:self];
    
    [[cell passwordField]  setSecureTextEntry:[[NSUserDefaults standardUserDefaults] boolForKey:@"secureTextEntry"]];

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
        
        [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
        
        [self.tableView beginUpdates];
        
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
            [self deselectPrivateRowAtIndexPath:iP];
            
            iP = indexPath;
            
            [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
            
        } else
        {
            [self deselectPrivateRowAtIndexPath:iP];
            
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

-(void)deselectPrivateRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:indexPath] passwordField] setTag:nil];
    
    [(noteListCell*)[[self tableView] cellForRowAtIndexPath:indexPath] hidePasswordField];
    
    [(noteListCell*)[[self tableView] cellForRowAtIndexPath:indexPath] setNormalImage];
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
    return [[fetchedResultsController fetchedObjects] count];
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
    
    MYcell.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;

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
