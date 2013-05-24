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
#import "MyButton.h"

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
        orientation = 0;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{ 
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:saveButton animated:YES];
    
    if (forEditing)
    {
        self.navigationItem.titleView = trashButton;
        [self updateTimeText];
    }
    
    [myTextView setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteTextFont"] size:[[NSUserDefaults standardUserDefaults] integerForKey:@"noteTextFontSize"]]];
    
    [myNameField setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"] size:[[NSUserDefaults standardUserDefaults] integerForKey:@"noteNameFontSize"]]];
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

-(void)setMyTextViewHeight:(CGFloat)height withDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration delay:0 options:nil
                     animations:^{
                         [self.myTextView setFrame:CGRectMake(11, 55, myTextView.frame.size.width, height)];
                     } completion:^(BOOL finished) {
                     }];
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

    [self becomeFirstResponder];
    
    CGRect rect = myTextView.frame;
    rect.size.height = 200;
    myTextView.frame = rect;
    
    [myTextView addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [self observeValueForKeyPath:@"frame" ofObject:myTextView change:nil context:nil];
    
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


    } else
    {
        notesCount--;

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
    
    UIDevice *device = [UIDevice currentDevice];					
	[device beginGeneratingDeviceOrientationNotifications];			
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	
	[nc addObserver:self											
		   selector:@selector(orientationChanged:)
			   name:UIDeviceOrientationDidChangeNotification
			 object:device];
    
    orientation = device.orientation;
    
    
    
    [backView setBackgroundColor:[UIColor whiteColor]];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    
    [myTextView setBackgroundColor:[UIColor whiteColor]];
    
    
    
    if ((orientation == 3) || (orientation == 4))
    {        
        myTextView.frame = CGRectMake(11, 55, self.view.frame.size.width - 22, 197);
    } else
    {
        CGFloat height = 0.0;
        
        if ((orientation == 1) || (orientation == 2))
        {   
            if(forEditing)
            {
                height = myTextView.contentSize.height;
                
                if (height > 400)
                    height = 400;
                else
                    if (height < 200)
                        height = 200;
            } else
                height = 200;
           
            CGRect rect = myTextView.frame;
            rect.size.height = height;
            myTextView.frame = rect;
        }
    }
    
    self.myTextView.layer.cornerRadius = 5;
    self.myTextView.layer.masksToBounds=YES;
    

    
    [self updateTimeText];
    [[self view] addSubview:backView];
    [[self view] addSubview:myTextView];
    [[self view] addSubview:alertLabel];
    [[self view] addSubview:timeText];
    [[self view] addSubview:myNameField];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIImage *firstImage;
    UIImage *secondImage;
    
    if (isPrivate)
    {
        firstImage  = [UIImage imageNamed:@"locked.png"];
        secondImage = [UIImage imageNamed:@"unlocked.png"];
    } else
    {
        firstImage  = [UIImage imageNamed:@"unlocked.png"];
        secondImage = [UIImage imageNamed:@"locked.png"];
    }
    
    UIView *container    = [UIButton flipButtonWithFirstImage:firstImage
                                                  secondImage:secondImage
                                              firstTransition:UIViewAnimationTransitionFlipFromRight
                                             secondTransition:UIViewAnimationTransitionFlipFromRight
                                               animationCurve:UIViewAnimationCurveEaseInOut
                                                     duration:0.4
                                                       target:self
                                                     selector:@selector(clickLockButton:)];
    
    [lockButton addSubview:container];
    
    [[self view] addSubview:lockButton];
    
    [myTextView setNeedsDisplay];
    
    [self setupButtons];
}

-(void)updateTimeText
{
    CGRect rect = [[myTextView valueForKeyPath:@"frame"] CGRectValue];
    CGRect rect2 = timeText.frame;
    
    rect2.origin.y = rect.origin.y + rect.size.height;
    
    timeText.frame = rect2;
}

-(void)updateBackView
{
    CGRect rect = [[myTextView valueForKeyPath:@"frame"] CGRectValue];
    CGRect rect2 = backView.frame;
    
    rect2.size.height = rect.size.height;
    
    backView.frame = rect2;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateTimeText];
    [self updateBackView];
}

-(void) keyboardWillShow:(NSNotification*) notification
{
    if ((orientation == 3)||(orientation == 4))
    {
        
        [self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, 158, 0)];
    } else
        {
            [self.myTextView setContentInset:UIEdgeInsetsZero];
        }
    
    if ((orientation == 1)||(orientation == 2))
    {
        [self setMyTextViewHeight:200 withDuration:0.2];
    }
}

-(void) keyboardWillHide:(NSNotification*) notification
{
    [self.myTextView setContentInset:UIEdgeInsetsMake(0, 0, myTextView.contentSize.height, 0)];
    
    if ((orientation == 1)||(orientation == 2))
    {
        CGFloat height = myTextView.contentSize.height;
        
        if (height > 400)
            height = 400;
        else
            if (height < 200)
                height = 200;
        
        [self setMyTextViewHeight:height withDuration:0.2];
    }
    
    [self.myTextView setContentInset:UIEdgeInsetsZero];
}


- (void)orientationChanged:(NSNotification *)notification
{
    orientation = [[notification object] orientation];
    
    if ((orientation == 3)||(orientation == 4))
    {
        myTextView.frame = CGRectMake(myTextView.frame.origin.x, myTextView.frame.origin.y, myTextView.frame.size.width, (self.view.frame.size.height - myTextView.frame.origin.y - 21));
    } else
        if ((orientation == 1)||(orientation == 2))
        {
            CGFloat height = myTextView.contentSize.height;
            
            if (height > 400)
                height = 400;
            else
                if (height < 200)
                    height = 200;
            
            myTextView.frame = CGRectMake(myTextView.frame.origin.x, myTextView.frame.origin.y, myTextView.frame.size.width, height);
            
            backView.frame = CGRectMake(backView.frame.origin.x, backView.frame.origin.y, backView.frame.size.width, 200);
        }
    
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

}

- (void)clickTrashButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
                                  destructiveButtonTitle:NSLocalizedString(@"DeleteButton", nil)
                                  otherButtonTitles:nil,nil];
    
    [actionSheet showInView:self.view];
}
- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
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
            break;
        }
        case 1:
        {
            break;
        }
    }
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
