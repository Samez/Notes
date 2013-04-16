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
#import "res.h"
#import "Note.h"

@interface notesListViewController ()

@property UIBarButtonItem* editButton;
@property UIBarButtonItem* doneButton;
@property UIBarButtonItem* deleteButton;
@property UIBarButtonItem* addButton;
@property UIBarButtonItem* deselectButton;
@property UIBarButtonItem* fillBDButton;

@end

@implementation notesListViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize noteCell;
@synthesize editButton;
@synthesize doneButton;
@synthesize addButton;
@synthesize deselectButton;
@synthesize fillBDButton;

-(void)checkSettings
{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"simplyTabBarStyle"] != nil)
    {
        simpleTabBar = [[NSUserDefaults standardUserDefaults] boolForKey: @"simplyTabBarStyle"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"password"] != nil)
    {
        PSWD = [[NSUserDefaults standardUserDefaults] objectForKey: @"password"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] != nil)
    {
        unsafeDeletion = [[NSUserDefaults standardUserDefaults] boolForKey:@"unsafeDeletion"];
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
        //[note setIsPrivate:[NSNumber numberWithUnsignedInt:arc4random()%2]];
        [note setIsPrivate:[NSNumber numberWithBool:YES]];
    }
    
    NSError *error = nil;
    
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([swipedCells containsObject:indexPath])
        {
            [cell setBackgroundColor:[UIColor sashaGray]];
            CGRect t=cell.frame ;
            t.origin.x+=_SHIFT_CELL_LENGTH;
            cell.frame=t;
        }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkSettings];
    
    [self.tableView setDelegate:self];
    
    [self setTitle:NSLocalizedString(@"NotesTitle", nil)];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tryToDeleteSelectedCells)];
    
    self.deselectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(deselectSwipedCells)];
    
    self.fillBDButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fillBD)];

    [[self navigationItem] setRightBarButtonItem:self.addButton];
    
    //[[self navigationItem] setLeftBarButtonItem:self.fillBDButton];
    
    NSError *error = nil;
    
	if (![[self fetchedResultsController] performFetch:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"password"] != nil)
        PSWD = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    
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
    customAlertView = [[CustomAlertView alloc]initWithTitle:NSLocalizedString(@"PasswordCheckAlertViewTitle", nil)
                                                                     message:NSLocalizedString(@"EnterPasswordToDeleteTitle", nil)
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@"Delete",nil];
    
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,85,252,25)];
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.secureTextEntry = YES;
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.delegate = self;
    [passwordField setTag:1919];
    [passwordField becomeFirstResponder];
    [customAlertView addSubview:passwordField];
    [customAlertView setDelegate:self];
	[customAlertView show];
    
    return YES;
}

-(void)deleteSwipedCells
{
    if (canDelete)
    {
        canDelete = NO;
            
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             
                             for (int i = 0; i < [swipedCells count]; ++i)
                             {
                                 
                                 [self swipeToDeleteCellAtIndexPath:swipedCells[i] ignoreCanDelete:YES];
                             }
                         }
                         completion:^(BOOL finished){

                             NSError *error = nil;
                             if (![managedObjectContext save:&error])
                             {
                                 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                 abort();
                             }
                             canDelete = YES;
                         }];

        
        swipedCells = nil;
        
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.leftBarButtonItem = nil;
        [self.tableView setAllowsSelection:YES];
    }
}

-(void)deselectSwipedCells
{
    for (int i = 0; i < [swipedCells count]; ++i)
        {
            [self swipeCellAtIndexPath:swipedCells[i] at:-_SHIFT_CELL_LENGTH withTargetColor:[UIColor whiteColor] andWithDuration:0.3];
        }
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = nil;
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
                if ([[textField text] isEqualToString:PSWD])
                {
                    [self deleteSwipedCells];
                    [(CustomAlertView*)alertView setPasswordIsAccepted:YES];
                }
                else
                {
                    [alertView setMessage:NSLocalizedString(@"WrongPasswordAlert", nil)];
                    [textField setText:nil];
                }
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

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (swipedCells == nil)
        swipedCells = [[NSMutableArray alloc] init];

    if ([swipedCells containsObject:indexPath])
    {
        [swipedCells removeObject:indexPath];
        [self swipeCellAtIndexPath:indexPath at:-_SHIFT_CELL_LENGTH withTargetColor:[UIColor whiteColor] andWithDuration:0.3];
        
        noteListCell *cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [[cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    }

    if ([swipedCells count] == 0)
    {
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.leftBarButtonItem = nil;
        [self.tableView setAllowsSelection:YES];
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (!canDelete)
        return;
    
    [self.tableView setAllowsSelection:NO];
    
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (indexPath != nil)
    {
        if ((unsafeDeletion) && (![[[fetchedResultsController objectAtIndexPath:indexPath] isPrivate] boolValue]) && ([swipedCells count] == 0))
        {
            [self swipeToDeleteCellAtIndexPath:indexPath ignoreCanDelete:NO];
        }
        else
        {
            if ([swipedCells count] == 0)
            {
                self.navigationItem.rightBarButtonItem = self.deleteButton;
                self.navigationItem.leftBarButtonItem = self.deselectButton;
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
                
                [self swipeCellAtIndexPath:indexPath at:+_SHIFT_CELL_LENGTH withTargetColor:[UIColor sashaGray] andWithDuration:0.3];
                
            }
        }
    }
}

-(void)swipeCellAtIndexPath:(NSIndexPath*)indexPath at:(CGFloat)xPixels withTargetColor:(UIColor*)color andWithDuration:(CGFloat)duration
{
    
    [UIView animateWithDuration:duration
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{

                         [self updateCellAtIndexPath:indexPath at:xPixels withTargetColor:color];
                     }
                     completion:^(BOOL finished){

                     }];
}

-(void)swipeToDeleteCellAtIndexPath:(NSIndexPath*)indexPath ignoreCanDelete:(BOOL)ignore
{
    if (ignore)
        canDelete = YES;
    
    if (canDelete)
    {
        canDelete = NO;
        [UIView animateWithDuration:0.4
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [self updateCellAtIndexPath:indexPath at:320 withTargetColor:[UIColor sashaGray]];
                         }
                         completion:^(BOOL finished){
                             [managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
                             canDelete = YES;
                             
                             if (!ignore)
                             {
                                 NSError *error = nil;
                                 
                                 if (![managedObjectContext save:&error])
                                 {
                                     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                     abort();
                                 }
                                 
                                 [self.tableView setAllowsSelection:YES];
                             }
                         }];
    }
    
}

-(void)updateCellAtIndexPath:(NSIndexPath*)indexPath at:(CGFloat)xPixels withTargetColor:(UIColor*)color
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:color];
    [cell setFrame:CGRectMake(cell.frame.origin.x + xPixels, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showTabBar:[self tabBarController]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [self checkSettings];
    canDelete = YES;
    canTryToEnter = YES;
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

    
    if ([[[cell passwordField] text] isEqualToString:PSWD])
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
    if (canTryToEnter)
    {
        canTryToEnter = NO;
        [UIView animateWithDuration:0.25 delay:0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.tableView.frame= CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + deltaHeight);
                         }
                         completion:^(BOOL finished){
                             canTryToEnter = YES;
                         }];
        
        int index = [[self.tableView visibleCells] indexOfObject:[self.tableView cellForRowAtIndexPath:iP]];
        
        if (deltaHeight < 0)
        {
            if (index >= 5)
            {
                [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            } else if (index == 0)
            {
                [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }

}

-(void)didSelectPrivateNoteAtIndexPath:(NSIndexPath*)indexPath
{
    if (!canTryToEnter)
        return;
        
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
    
    if ([textField tag] == 1919)
    {
        if ([[textField text] isEqualToString:PSWD])
        {
            [self deleteSwipedCells];
            [customAlertView dismissWithClickedButtonIndex:customAlertView.cancelButtonIndex animated:YES];
        } else
        {
            [textField setText:nil];
            [customAlertView setMessage:NSLocalizedString(@"WrongPasswordAlert", nil)];
        }

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
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
			break;
			
		case NSFetchedResultsChangeUpdate:
        {
            if ([[fetchedResultsController fetchedObjects] count] > 0)
                [self configureCell:(noteListCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            
			break;
        }
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

- (void)viewDidUnload
{
    [self setNoteCell:nil];
    [super viewDidUnload];
}
@end
