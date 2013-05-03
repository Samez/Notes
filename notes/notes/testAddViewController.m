//
//  testAddViewController.m
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "testAddViewController.h"
#import "res.h"
#import "LocalyticsSession.h"

#define MAXLENGTH 25

@interface testAddViewController ()

@property UIView* trashButton;
@property UIBarButtonItem* cancelButton;
@property UIBarButtonItem* saveButton;

@end

@implementation testAddViewController
@synthesize forEditing;
@synthesize myTextView;
@synthesize myNameField;
@synthesize managedObjectContext;
@synthesize note;
@synthesize timeText;
@synthesize lockButton;
@synthesize alertLabel;
@synthesize notesCount;
@synthesize trashButton;
@synthesize cancelButton;
@synthesize saveButton;

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

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:saveButton animated:YES];
    
    if (forEditing)
        self.navigationItem.titleView = trashButton;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [myTextView setText:nil];
    //[myNameField setText:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self hideTabBar:[self tabBarController]];
    
    if (!forEditing)
        [self.myTextView becomeFirstResponder];
    
    [self becomeFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [myTextView setNeedsDisplay];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hideAlertMessageWithDuration:0.2 needReshow:NO];
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
    [self hideAlertMessageWithDuration:0.2 needReshow:NO];
}

-(void)dismissKeyboard
{
    [myTextView resignFirstResponder];
    [myNameField resignFirstResponder];
}

-(void)setupButtons
{
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 29)];
    buttonContainer.backgroundColor = [UIColor clearColor];
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button0 setFrame:CGRectMake(0, 0, 34, 29)];
    [button0 setBackgroundImage:[UIImage imageNamed:@"trash2.png"] forState:UIControlStateNormal];
    [button0 addTarget:self action:@selector(clickTrashButton:) forControlEvents:UIControlEventTouchUpInside];
    [button0 setShowsTouchWhenHighlighted:YES];
    [buttonContainer addSubview:button0];
    
    self.trashButton = buttonContainer;
    
    //self.navigationItem.titleView = trashButton;
    
    [[self.navigationItem leftBarButtonItem] setAction:@selector(cancel)];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelButton",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    
    saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveButton",nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupButtons];
    
    [self becomeFirstResponder];
    
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

    
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];

    [myTextView setDelegate:self];
    //[myTextView setScrollEnabled:NO];
    [myTextView setReturnKeyType:UIReturnKeyNext];
    
    [myNameField setDelegate:self];
    
//    [myTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"textFieldBackgroundMin.png"]]];
    
    if (!forEditing)
    {
        [timeText setHidden:YES];
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];

    } else
    {
        notesCount--;
        
        if ([[note isPrivate] boolValue])
            [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"locked.png"]]];
        else
            [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];

        NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
        [date_format setDateFormat: @"HH:mm MMMM d, YYYY"];
        
        NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
        
        [date_format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:identifier]];
        
        NSString * timeString = [date_format stringFromDate: [note date]];
        
        [timeText setText:timeString];
        [timeText setHidden:NO];
        
        [myTextView setText:[note text]];
        
        [myNameField setText:[note name]];
    }
    
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
    
    [self hideAlertMessageWithDuration:0.2 needReshow:NO];
    
    if (!isPrivate)
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];
    else
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"locked.png"]]];
}

- (void)clickTrashButton:(id)sender
{
    [managedObjectContext deleteObject:note];
    
    NSError *error = nil;
    
    if (![[self managedObjectContext] save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [[LocalyticsSession shared] tagEvent:@"Old note was deleted"];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)cancel
{
    if (!forEditing)
    {
        [[self managedObjectContext] deleteObject:note];
    
        [[LocalyticsSession shared] tagEvent:@"Creating a new note has been canceled"];
    }
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(BOOL)checkFields
{
    if (isPrivate)
    {
        if (([[myNameField text] length] == 0) || ([[myTextView text] length] == 0))
        {
            [alertLabel setText:NSLocalizedString(@"PrivateNoteRequirements", nil)];
            [self showAlertMessageWithDuration:0.6];
            return NO;
        }
    } else
    {
        if (([[myNameField text]length] == 0) && ([[myTextView text] length] == 0))
        {
            [alertLabel setText:NSLocalizedString(@"PublicNoteRequirements", nil)];
            [self showAlertMessageWithDuration:0.6];
            return NO;
        }
    }
    
    return YES;
}

-(void)save
{
    [myTextView resignFirstResponder];
    [myNameField resignFirstResponder];
    
    if (![self checkFields])
        return;
    
    [note setIsPrivate:[NSNumber numberWithBool:isPrivate]];
    
    [note setText:[myTextView text]];
    
    if([[myNameField text] length] != 0)
        [note setName:[myNameField text]];
    else
        [note setName:nil];

    if(!forEditing || [[NSUserDefaults standardUserDefaults] boolForKey:@"needUpdateTime"])
        [note setDate:[NSDate date]];
    
    if (forEditing)
        [[LocalyticsSession shared] tagEvent:@"Old note was updated"];
    
    NSError *error = nil;
    
    if (![[self managedObjectContext] save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [[LocalyticsSession shared] tagEvent:@"New note was added"];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)viewDidUnload
{
    [self setMyNameField:nil];
    [self setTimeText:nil];
    [self setLockButton:nil];
    [self setAlertLabel:nil];
    
    [super viewDidUnload];
}

@end
