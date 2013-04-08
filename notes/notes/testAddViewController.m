//
//  testAddViewController.m
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "testAddViewController.h"

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
        oldNote = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(forEditing)
        self.navigationItem.title = @"Edit note";
    else
        self.navigationItem.title = @"New note";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if (forEditing)
    {
        [trashButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"trash2.png"]]];
        
    }
    
    myTextView.delegate = self;
    [myTextView setScrollEnabled:NO];
    myTextView.returnKeyType = UIReturnKeyNext;
    
    myNameField.delegate = self;
    
    if (!forEditing)
    {
        [timeText setHidden:YES];
    } else
    {
        [timeText setHidden:NO];
        NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
        [date_format setDateFormat: @"HH:mm MMMM d, YYYY"];
        NSString * timeString = [date_format stringFromDate: note.date];
        
        [timeText setText:timeString];
        
        [myTextView setText:[note text]];
        [myNameField setText:[note name]];
        
        [trashButton setImage:[UIImage imageNamed:@"trash2.png"] forState:UIControlStateNormal];
    }
    
    if (forEditing)
    {
        if ([[note isPrivate] boolValue])
            [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"locked.png"]]];
        else
            [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lock.png"]]];
    } else
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lock.png"]]];

    [alertLabel setHidden:YES];
    
    if (forEditing)
        oldNote = note;
    
    if (forEditing)
        notesCount--;
    
    switch (notesCount)
    {
        case 0:
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"oneNoteBackground.png"]];
            break;
        case 1:
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"twoNotesBackground.png"]];
            break;
        case 2:
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"threeNotesBackground.png"]];
            break;
        case 3:
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fourNotesBackground.png"]];
            break;
        default:
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fourNotesBackground.png"]];
            break;
    }
    
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAXLENGTH || returnKey;
}


-(void)clickLockButton:(id)sender
{
    [note setIsPrivate:[NSNumber numberWithBool:![[note isPrivate] boolValue]]];

    
    if (![[note isPrivate] boolValue])
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lock.png"]]];
    else
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"locked.png"]]];
}

- (IBAction)clickTrashButton:(id)sender
{
    [managedObjectContext deleteObject:note];
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)cancel
{
	if (!forEditing)
        [self.managedObjectContext deleteObject:note];
    else
        note = oldNote;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)save
{
    if ([[note isPrivate] boolValue])
    {
        if ([[myNameField text] length] == 0)
        {
            [alertLabel setText:@"Enter name for private note"];
            [alertLabel setHidden:NO];
            return;
        } 
    } else
    {
        if ([[myNameField text] length] == 0)
            if ([[myTextView text] length] == 0)
            {
                [alertLabel setText:@"Enter name or text for open note"];
                [alertLabel setHidden:NO];
                return;
            }
    }
    
    [note setName:[myNameField text]];
    [note setText:[myTextView text]];
    
    if(!forEditing)
        [note setDate:[NSDate date]];
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
{
    NSString* newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];

    CGSize tallerSize = CGSizeMake(aTextView.frame.size.width-15,aTextView.frame.size.height*2);
    CGSize newSize = [newText sizeWithFont:aTextView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
    
    if (newSize.height > aTextView.frame.size.height)
    {
        //aTextView.returnKeyType = UIReturnKeyDone;
        [aTextView resignFirstResponder];
        return NO;
    }
    else
    {
        //aTextView.returnKeyType = UIReturnKeyNext;
        return YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"Return pressed\n");
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self setMyNameField:nil];
    [self setTimeText:nil];
    [self setLockButton:nil];

    [self setAlertLabel:nil];
    [self setTrashButton:nil];
    [super viewDidUnload];
}

@end
