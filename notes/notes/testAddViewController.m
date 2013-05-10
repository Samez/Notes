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

-(void)viewDidAppear:(BOOL)animated
{    
    if (!forEditing)
        [self.myTextView becomeFirstResponder];
    
    [[LocalyticsSession shared] tagScreen:@"New note / edit note"];
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
    
    [[self.navigationItem leftBarButtonItem] setAction:@selector(cancel)];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelButton",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveButton",nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupButtons];
    
    
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
    
    if (!forEditing)
    {
        [timeText setHidden:YES];
        [lockButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"unlocked.png"]]];

    } else
    {
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
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"woodenBackground.png"]]];
    //[self.paperView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.png"]]];
    [self.myTextView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self observeValueForKeyPath:@"contentSize" ofObject:self.myTextView change:nil context:nil];
    
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
    
    [self setBackgroundView:nil];
    [self setPaperView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object==self.myTextView)
    {
        [self.myTextView removeObserver:self forKeyPath:@"contentSize"];
        CGRect t=self.myTextView.frame;
        t.size=self.myTextView.contentSize;
        self.myTextView.frame=t;
        if(self.myTextView.frame.size.height<self.scrollView.bounds.size.height-self.myTextView.frame.origin.y)
        {
            CGRect t=self.myTextView.frame;
            t.size.height=self.scrollView.bounds.size.height-self.myTextView.frame.origin.y;
            self.myTextView.frame=t;
        }
        self.scrollView.contentSize=CGSizeMake(self.scrollView.contentSize.width, self.myTextView.frame.origin.y+self.myTextView.contentSize.height);
        [self.myTextView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
        
    }
}

-(void) keyboardWillShow:(NSNotification*) notification
{
    NSLog(@"show");
    self.view.superview.backgroundColor=[UIColor redColor];
    BOOL needResize=NO;
    if ([myTextView isFirstResponder]|| [myNameField isFirstResponder])
    {
        needResize=YES;
    }
    if (!needResize) return;
    
    NSDictionary* dict=[notification userInfo];
    CGRect t=self.view.frame;
    
    CGFloat keyboardPathLength=[[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y-[[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardTopOnTable=[self.view.superview convertPoint:[[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin fromView:nil].y;
    CGFloat tableBottom=self.view.superview.frame.size.height;
    CGFloat animationDuration=(tableBottom-keyboardTopOnTable)/(keyboardPathLength)*[[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat delay=[[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-animationDuration;
    NSLog(@"%f %f %f",keyboardTopOnTable,animationDuration ,delay);
    
    t.size.height=keyboardTopOnTable;
    if (animationDuration==INFINITY){
        self.view.frame=t;
    }else{
        
        [UIView animateWithDuration:animationDuration delay:delay options:0 animations:^{
            self.view.frame=t;
        } completion:nil];
    }
}

-(void) keyboardWillHide:(NSNotification*) notification
{
    NSLog(@"hide");
    BOOL needResize=NO;
    if ([myTextView isFirstResponder]|| [myNameField isFirstResponder])
    {
        needResize=YES;
    }
    if (!needResize) return;
    
    NSDictionary* dict=[notification userInfo];
    //NSLog(@"%@",dict);
    CGRect t=self.view.frame;
    
    CGFloat keyboardPathLength=[[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y-[[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    
    CGFloat keyboardTopOnTable=[self.view.superview convertPoint:[[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin fromView:nil].y;
    CGFloat tableBottom=self.view.superview.frame.size.height;
    CGFloat animationDuration=(keyboardTopOnTable-tableBottom)/(keyboardPathLength)*[[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    t.size.height=tableBottom;
    
    NSLog(@"%f",animationDuration);
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame=t;
    }];
}

@end
