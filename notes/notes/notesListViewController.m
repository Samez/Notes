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
@synthesize addButton;
@synthesize deselectButton;
@synthesize fillBDButton;

-(void)loadSettings
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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] != nil)
    {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"];
        swipeColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
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
        //[note setIsPrivate:[NSNumber numberWithBool:YES]];
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
            [cell setBackgroundColor:swipeColor];
                
            [[(noteListCell*)cell noteNameLabel] setTextColor:[UIColor blackColor]];
            
            if ([swipeColor isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]])
                [[(noteListCell*)cell timeLabel] setTextColor:[UIColor whiteColor]];
                
            CGRect t=cell.frame ;
            t.origin.x+=_SHIFT_CELL_LENGTH;
            cell.frame=t;
        }
}

-(void)setupButtons
{
    UIImage* image3 = [UIImage imageNamed:@"add.png"];
    CGRect frameimg = CGRectMake(0, 0, 34, 29);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(add:)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIImage* image2 = [UIImage imageNamed:@"trash2.png"];
    CGRect frameimg2 = CGRectMake(0, 0, 34, 29);
    UIButton *someButton2 = [[UIButton alloc] initWithFrame:frameimg2];
    [someButton2 setBackgroundImage:image2 forState:UIControlStateNormal];
    [someButton2 addTarget:self action:@selector(tryToDeleteSelectedCells)
          forControlEvents:UIControlEventTouchUpInside];
    [someButton2 setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *bufButton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.addButton=bufButton;
    
    UIBarButtonItem *bufButton2 =[[UIBarButtonItem alloc] initWithCustomView:someButton2];
    self.deleteButton=bufButton2;
    
    self.deselectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(deselectSwipedCells)];
    
    self.fillBDButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fillBD)];
    
    [[self navigationItem] setRightBarButtonItem:self.addButton animated:NO];
    
    [[self navigationItem] setLeftBarButtonItem:self.fillBDButton];
}

-(void)setupRecognizers
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ??? [self.tableView setDelegate:self];
    
    [self setTitle:NSLocalizedString(@"NotesTitle", nil)];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    NSError *error = nil; 
    
	if (![[self fetchedResultsController] performFetch:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    [self setupButtons];
    [self setupRecognizers];
    
    iP = nil;
    
    canSwipe = YES;
    canDelete = YES;
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
    passwordField.secureTextEntry = [[NSUserDefaults standardUserDefaults] boolForKey:@"secureTextEntry"];
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

        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             
                             for (int i = 0; i < [swipedCells count]; ++i)
                             {
                                 [managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:swipedCells[i]]];
                             }
                         }
                         completion:^(BOOL finished){

                             NSError *error = nil;
                             if (![managedObjectContext save:&error])
                             {
                                 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                 abort();
                             }

                         }];

        
        swipedCells = nil;
        
        [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.tableView setAllowsSelection:YES];
    
}

-(void)deselectSwipedCells
{
    for (int i = 0; i < [swipedCells count]; ++i)
        {
            [self swipeCellAtIndexPath:swipedCells[i] at:-_SHIFT_CELL_LENGTH withTargetColor:[UIColor whiteColor] andWithDuration:0.3];
        }
    
    [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.tableView setAllowsSelection:YES];
    
    swipedCells = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
        {
            [self deselectSwipedCells];
            break;
        }
            
        case 1:
        {
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
            break;
        }
            
    }
}

-(void)tryToDeleteSelectedCells
{
    BOOL havePrivateNote = NO;
    
    int i = 0;
    
    while ((i < [swipedCells count]) && !havePrivateNote)
    {
        if ([[(Note*)[fetchedResultsController objectAtIndexPath:swipedCells[i]] isPrivate] boolValue])
        {
            havePrivateNote = YES; // ???
            [self showPromptAlert];
            return;
        } else
            i++;
    }

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
        [[self navigationItem] setRightBarButtonItem:self.addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.tableView setAllowsSelection:YES];
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (canSwipe)
    {
        [self.tableView setAllowsSelection:NO];
        
        CGPoint location = [gestureRecognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
        
        if (indexPath != nil)
        {
            if ((unsafeDeletion) && (![[[fetchedResultsController objectAtIndexPath:indexPath] isPrivate] boolValue]) && ([swipedCells count] == 0))
            {
                [self swipeToDeleteCellAtIndexPath:indexPath];
            }
            else
            {
                if ([swipedCells count] == 0)
                {
                    [self.navigationItem setLeftBarButtonItem:self.deselectButton animated:YES];
                    [self.navigationItem setRightBarButtonItem:self.deleteButton animated:YES];
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
                    
                    [self swipeCellAtIndexPath:indexPath at:+_SHIFT_CELL_LENGTH withTargetColor:swipeColor andWithDuration:0.3];
                    
                }
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

-(void)swipeToDeleteCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (canDelete)
    {
        canDelete = NO;
        canSwipe = NO;
        [UIView animateWithDuration:0.4
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [self updateCellAtIndexPath:indexPath at:320 withTargetColor:swipeColor];
                         }
                         completion:^(BOOL finished){

                             [managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];

                             NSError *error = nil;
                             
                             if (![managedObjectContext save:&error])
                             {
                                 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                 abort();
                             }
                             
                             [self.tableView setAllowsSelection:YES];
                             canDelete = YES;
                             canSwipe = YES;
                        }];

    }
}

-(void)updateCellAtIndexPath:(NSIndexPath*)indexPath at:(CGFloat)xPixels withTargetColor:(UIColor*)color
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:color];
    
    if ([color isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]])
        [[(noteListCell*)cell timeLabel] setTextColor:[UIColor whiteColor]];
    else if ([color isEqual:[UIColor whiteColor]])
        [[(noteListCell*)cell timeLabel] setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    
    [cell setFrame:CGRectMake(cell.frame.origin.x + xPixels, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showTabBar:[self tabBarController]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [self loadSettings];
    canTryToEnter = YES;
    canSwipe = YES;
    canDelete = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self deselectSwipedCells];
    [self deselectPrivateRowAtIndexPath:iP];
    iP = nil;
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
    noteListCell* cell = (noteListCell*)[self.tableView cellForRowAtIndexPath:iP];
    
    [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [cell setBackgroundColor:[UIColor sashaGray]];
                         [[cell noteNameLabel] setTextColor:[UIColor whiteColor]];
                         [[cell timeLabel] setTextColor:[UIColor whiteColor]];
                         
                         if ([[note isPrivate] boolValue])
                         {
                             //
                             [[cell passwordField] setBackgroundColor:[UIColor whiteColor]];
                             [cell setNormalImage];
                         }
                     }
                     completion:^(BOOL finished){
                     }];
    
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
    
    [[cell noteNameLabel] setTextColor:[UIColor blackColor]];
}

-(void)tryEnter
{
    noteListCell *cell = (noteListCell*)[[self tableView] cellForRowAtIndexPath:iP];

    if ([[[cell passwordField] text] isEqualToString:PSWD])
    {
        [self showNote:[[fetchedResultsController fetchedObjects] objectAtIndex:iP.row] animated:YES];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastTime"];
    }
    else
        [cell setAlertImage];
}

-(void)changeTableViewHeightAt:(UIEdgeInsets)edgeInsets
{
    if (canTryToEnter)
    {
        canTryToEnter = NO;
        [UIView animateWithDuration:0.25 delay:0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [self.tableView setContentInset:edgeInsets];
                             [self.tableView setScrollIndicatorInsets:edgeInsets];
                         }
                         completion:^(BOOL finished){
                             canTryToEnter = YES;
                             int index = [[self.tableView visibleCells] indexOfObject:[self.tableView cellForRowAtIndexPath:iP]];
                             if (index == 0)
                                [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionTop animated:YES];
                             else if (index >=5)
                                     [self.tableView scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                         }];
        

        
    }
}

-(void)didSelectPrivateNoteAtIndexPath:(NSIndexPath*)indexPath
{
    if (canTryToEnter)
    {
        if (iP == nil)
        {
            canSwipe = NO;
            iP = indexPath;
            
            [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
            
            [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
            
            [self.tableView beginUpdates];
            
            [self.tableView endUpdates];
            
            
            if (simpleTabBar)
                [self changeTableViewHeightAt:UIEdgeInsetsMake(0, 0, _SIMPLY_TABBAR_CHANGE_VALUE, 0)];
            else
                [self changeTableViewHeightAt:UIEdgeInsetsMake(0, 0, _NORMAL_TABBAR_CHANGE_VALUE, 0)];
        }
        else
        {
            if (![iP isEqual:indexPath])
            {
                canSwipe = NO;
                [self deselectPrivateRowAtIndexPath:iP];
                
                iP = indexPath;
                
                [[(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] passwordField] setTag:666];
                
                [(noteListCell*)[[self tableView] cellForRowAtIndexPath:iP] showPasswordField];
                
            } else
            {
                canSwipe = YES;
                [self deselectPrivateRowAtIndexPath:iP];
                
                if (simpleTabBar)
                    [self changeTableViewHeightAt:UIEdgeInsetsZero];
                else
                    [self changeTableViewHeightAt:UIEdgeInsetsZero];
                
                iP = nil;
            }
        }
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } else
    {
        return;
    }
}

-(void)deselectPrivateRowAtIndexPath:(NSIndexPath*)indexPath
{
    noteListCell *cell = (noteListCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    [cell hidePasswordField];
    [[cell passwordField] setTag:nil];
    [cell setNormalImage];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = (Note*)[fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[note isPrivate] boolValue])
    {
        BOOL canShow = NO;
        
        NSDate *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTime"];
        
        NSDate *newDate = [NSDate dateWithTimeInterval:[[NSUserDefaults standardUserDefaults] integerForKey:@"PasswordRequestInterval"] sinceDate:lastTime];
        
        if ([newDate compare:[NSDate date]] == NSOrderedDescending)
            canShow = YES;
        
        if (canShow)
        {
            iP = indexPath;
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastTime"];
            [self showNote:note animated:YES];
        } else
            [self didSelectPrivateNoteAtIndexPath:indexPath];
        
    } else
    {
        if (iP != nil)
        {
            [self didSelectPrivateNoteAtIndexPath:iP];
        }
        
        iP = indexPath;
        
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
