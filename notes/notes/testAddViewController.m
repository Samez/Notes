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
#import <QuartzCore/QuartzCore.h>

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
@synthesize backView;

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
    
    self.myTextView.layer.cornerRadius = 5;
    self.myTextView.layer.masksToBounds=YES;
}

-(void)viewDidAppear:(BOOL)animated
{    
    if (!forEditing)
        [self.myTextView becomeFirstResponder];
    [myTextView setNeedsDisplay];

    [[LocalyticsSession shared] tagScreen:@"New note / edit note"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [myTextView setNeedsDisplay];
}

-(void)setMyTextViewHeight:(CGFloat)height
{
    [UIView animateWithDuration:0.2 delay:0 options:nil
                     animations:^{
                         [self.myTextView setFrame:CGRectMake(11, 50, myTextView.frame.size.width, height)];
                     } completion:^(BOOL finished) {
[self.myTextView setContentInset:UIEdgeInsetsZero];
                     }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hideAlertMessageWithDuration:0.2 needReshow:NO];
    //[self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, 198, 0)];
    [self setMyTextViewHeight:198];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    //[self.myTextView setContentInset:UIEdgeInsetsZero];
    [self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, -9999, 0)];

    CGFloat height = myTextView.contentSize.height;
    
    if (height > 400)
        height = 400;
    else
        if (height < 200)
            height = 200;
    
    [self setMyTextViewHeight:height];
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
    
    [[self.navigationItem leftBarButtonItem] setAction:@selector(cancel)];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelButton",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveButton",nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [backView setBackgroundColor:[UIColor whiteColor]];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    
    [[self view] addSubview:backView];
    [[self view] addSubview:myTextView];
    [[self view] addSubview:myNameField];
    [[self view] addSubview:lockButton];

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
    [myTextView setReturnKeyType:UIReturnKeyNext];

    [myNameField setDelegate:self];
    
    if (!forEditing)
    {
        [timeText setHidden:YES];
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];

    } else
    {
        [timeText setHidden:YES];
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
        //[timeText setHidden:NO];
        
        [myTextView setText:[note text]];
        
        [myNameField setText:[note name]];
    }
    [[self view] setBackgroundColor:[UIColor blackColor]];
    //[[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"oneNoteBackground.png"]]];
    
    CGFloat height = myTextView.contentSize.height;
    
    if( forEditing)
    {
        if (height > 400)
            height = 400;
        else
            if (height < 200)
                height = 200;
        
        [self setMyTextViewHeight:height];
    }
    
    [myTextView setNeedsDisplay];
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
            [self showAlertMessageWithDuration:0.3];
            return NO;
        }
    } else
    {
        if (([[myNameField text]length] == 0) && ([[myTextView text] length] == 0))
        {
            [alertLabel setText:NSLocalizedString(@"PublicNoteRequirements", nil)];
            [self showAlertMessageWithDuration:0.3];
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

- (void)viewDidUnload
{
    [self setMyNameField:nil];
    [self setTimeText:nil];
    [self setLockButton:nil];
    [self setAlertLabel:nil];
    
    [self setBackView:nil];
    [super viewDidUnload];
}

@end
