//
//  testAddViewController.m
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "testAddViewController.h"
#import "res.h"

#define MAXLENGTH 25

@interface testAddViewController ()

@end

@implementation testAddViewController
@synthesize forEditing;
@synthesize myTextView;
@synthesize myNameField;
@synthesize managedObjectContext,fetchedResultsController;
@synthesize note;
@synthesize timeText;
@synthesize lockButton;
@synthesize alertLabel;
@synthesize notesCount;
@synthesize trashButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        nameSymbolCount = 0;
        isPrivate = NO;
        alertIsVisible = NO;
        alerting = NO;
        hidining = NO;
    }
    return self;
}

-(void)checkSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"adaptiveBackground"] != nil)
    {
        backgroundIsAdaptive = [[NSUserDefaults standardUserDefaults] boolForKey: @"adaptiveBackground"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self hideTabBar:[self tabBarController]];
    
    [self showTrashButtonWithDuration:0.4];
}

-(void)showTrashButtonWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [trashButton setAlpha:1.0];
                     } 
                     completion:^(BOOL finished){
                         [trashButton setEnabled:YES];
                     }];
}

-(void)showAlertMessageWithDuration:(CGFloat)duration
{
    if (alertIsVisible)
    {
        [self hideAlertMessageWithDuration:duration needReshow:YES];
        return;
    }
    
    if (!alerting)
    {
        alerting = YES;
        
        [UIView animateWithDuration:duration delay:0.1 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             [alertLabel setAlpha:1.0];
                         } completion:^(BOOL finished) {
                             alerting = NO;
                             alertIsVisible = YES;
                         }];
    }
}

-(void)hideAlertMessageWithDuration:(CGFloat)duration needReshow:(BOOL)need
{

    if (!alerting)
    {
        alerting = YES;
        
        [UIView animateWithDuration:duration delay:0.1 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             [alertLabel setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             alerting = NO;
                             alertIsVisible = NO;
                             if (need)
                                 [self showAlertMessageWithDuration:duration];
                         }];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hideAlertMessageWithDuration:0.5 needReshow:NO];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hideAlertMessageWithDuration:0.5 needReshow:NO];
}

-(void)dismissKeyboard
{
    [myTextView resignFirstResponder];
    [myNameField resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkSettings];
    
    myTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    myNameField.keyboardAppearance = UIKeyboardAppearanceAlert;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [alertLabel setAlpha:0.0];
    
    if (note != nil)
    {
        forEditing = YES;
        isPrivate = [[note isPrivate] boolValue];
        
        [[self navigationItem] setTitle:NSLocalizedString(@"EditNote", nil)];
    }
    else
    {
        note = (Note*)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
        
        [[self navigationItem] setTitle:NSLocalizedString(@"NewNote", nil)];
    }

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelButton",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    [[self navigationItem] setLeftBarButtonItem:cancelButtonItem];
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveButton",nil) style:UIBarButtonItemStyleDone target:self action:@selector(save)];

    [[self navigationItem] setRightBarButtonItem:saveButtonItem];
    
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [myTextView setDelegate:self];
    [myTextView setScrollEnabled:NO];
    [myTextView setReturnKeyType:UIReturnKeyNext];
    
    [myNameField setDelegate:self];
    
    if (!forEditing)
    {
        [timeText setHidden:YES];
        [trashButton setHidden:YES];
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];

    } else
    {
        notesCount--;
        
        if ([[note isPrivate] boolValue])
            [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"locked.png"]]];
        else
            [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];
        
        [trashButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"trash2.png"]]];
        [trashButton setAlpha:0.0];
        [trashButton setEnabled:NO];
    
        NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
        [date_format setDateFormat: @"HH:mm MMMM d, YYYY"];
        NSString * timeString = [date_format stringFromDate: [note date]];
        
        [timeText setText:timeString];
        [timeText setHidden:NO];
        
        [myTextView setText:[note text]];
        
        [myNameField setText:[note name]];
        
        [trashButton setImage:[UIImage imageNamed:@"trash2.png"] forState:UIControlStateNormal];
    }
    
    [self updateBackground];
}

-(void)updateBackground
{
    
    if (backgroundIsAdaptive)
    {
        switch (notesCount)
        {
            case 0:
                [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"oneNoteBackground.png"]]];
                break;
            case 1:
                [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"twoNotesBackground.png"]]];
                break;
            case 2:
                [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"threeNotesBackground.png"]]];
                break;
            case 3:
                [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"fourNotesBackground.png"]]];
                break;
            default:
                [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"fourNotesBackground.png"]]];
                break;
        }
    } else
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"oneNoteBackground.png"]]];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger oldLength = [[textField text] length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAXLENGTH || returnKey;
}

-(void)clickLockButton:(id)sender
{
    isPrivate = !isPrivate;
    
    [self hideAlertMessageWithDuration:0.5 needReshow:NO];
    
    if (!isPrivate)
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];
    else
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"locked.png"]]];
}

- (IBAction)clickTrashButton:(id)sender
{
    [managedObjectContext deleteObject:note];
    
    NSError *error = nil;
    
    if (![[self managedObjectContext] save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)cancel
{
	if (!forEditing)
        [[self managedObjectContext] deleteObject:note];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(void)save
{
    
    [myTextView resignFirstResponder];
    [myNameField resignFirstResponder];
    
    if (isPrivate)
    {
        if (([[myNameField text] length] == 0) || ([[myTextView text] length] == 0))
        {
            [alertLabel setText:NSLocalizedString(@"PrivateNoteRequirements", nil)];
            [self showAlertMessageWithDuration:0.6];
            return;
        }
    } else
    {
        if (([[myNameField text]length] == 0) && ([[myTextView text] length] == 0))
        {
            [alertLabel setText:NSLocalizedString(@"PublicNoteRequirements", nil)];
            [self showAlertMessageWithDuration:0.6];
            return;
        }
    }
    
    [note setIsPrivate:[NSNumber numberWithBool:isPrivate]];
    
    [note setText:[myTextView text]];
    
    if ([[myNameField text] length] != 0)
        [note setName:[myNameField text]];
    else
        [note setName:nil];
    
    if(!forEditing)
        [note setDate:[NSDate date]];
    
    NSError *error = nil;
    
    if (![[self managedObjectContext] save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
{
    NSString* newText = [[aTextView text] stringByReplacingCharactersInRange:aRange withString:aText];

    CGSize tallerSize = CGSizeMake(aTextView.frame.size.width-15,aTextView.frame.size.height*2);
    CGSize newSize = [newText sizeWithFont:aTextView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
    
    if (newSize.height > aTextView.frame.size.height)
    {
        [aTextView resignFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			break;
			
		case NSFetchedResultsChangeDelete:
			break;
			
		case NSFetchedResultsChangeUpdate:
        {
            //TODO: !
                [self updateBackground];
			break;
        }
		case NSFetchedResultsChangeMove:
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

- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, _HIDDEN_TABBAR_HEIGHT, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, 320, _HIDDEN_TABBAR_HEIGHT)];
        }
    }
    
    [UIView commitAnimations];
}

- (void)viewDidUnload {
    [self setMyNameField:nil];
    [self setTimeText:nil];
    [self setLockButton:nil];

    [self setAlertLabel:nil];
    [self setTrashButton:nil];
    
    [super viewDidUnload];
}

@end
