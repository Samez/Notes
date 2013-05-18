//
//  SearchView.m
//  notes
//
//  Created by Samez on 16.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "SearchView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SearchView

@synthesize searchField,searchButton;
@synthesize searchingNow;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        oldFrame = frame;
        [self setUpWithFrame:frame];
        searchingNow = NO;
    }
    return self;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //[self.delegate searchView:self changeTextTo:[NSString stringWithFormat:@"%@%@",[searchField text],string]];
    [self performSelector:@selector(getText) withObject:nil afterDelay:0.05];
    return YES;
}

-(void)getText
{
    [self.delegate searchView:self changeTextTo:[searchField text]];
}

-(void)buttonClick
{
    if (!searchingNow)
    {
        //[searchField setCursorColor:[UIColor clearColor]];
        [searchField becomeFirstResponder];
        [self.delegate searchViewWillStartSearching:self];
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{

                             [searchField setAlpha:1.0];
                             
                             CGRect rect = oldFrame;
                             rect.size.width -= 34;
                             searchField.frame = rect;
                             
                         }
                         completion:^(BOOL finished){
                             searchingNow = YES;
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"searchingBegin" object:self];
                             [searchField setCursorColor:[UIColor colorWithRed:81.0f/255.0f green:106.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
                         }];

    } else
    {
        [self.delegate searchViewWillEndSearching:self];
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [searchField setAlpha:0.0];
                             [searchField resignFirstResponder];
                             searchField.frame = narrowFieldFrame;
                         }
                         completion:^(BOOL finished){
                             searchingNow = NO;
                             [searchField setText:nil];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"searchingEnd" object:self];
                         }];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


-(void)setUpWithFrame:(CGRect)frame
{

    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];

    unsearchingButtonRect = CGRectMake(frame.origin.x + frame.size.width/2 -15, frame.origin.y + frame.size.height/2 - 15, 34, 29);
    
    [button0 setFrame: unsearchingButtonRect];
    [button0 setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [button0 addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [button0 setShowsTouchWhenHighlighted:YES];
    
    searchButton = button0;
    
    narrowFieldFrame = CGRectMake(frame.origin.x + frame.size.width/2 -15 , frame.origin.y , 1, frame.size.height);
    searchField = [[SearchField alloc] initWithFrame: narrowFieldFrame];
    [searchField setBackgroundColor:[UIColor whiteColor]];
    //searchField.placeholder = @"search field";
    [searchField setBorderStyle:UITextBorderStyleRoundedRect];
    [searchField setAlpha:0.0];
    //searchField.rightViewMode = UITextFieldViewModeAlways;
    //[searchField setClearButtonMode:UITextFieldViewModeAlways];
    searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
    searchField.returnKeyType = UIReturnKeyDone;
    [searchField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self addSubview:searchField];
    [self addSubview:searchButton];
    [searchField setDelegate:self];
    
    [searchField addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [self observeValueForKeyPath:@"frame" ofObject:searchField change:nil context:nil];
    
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object==searchField)
    {
        CGRect rect = [[object valueForKeyPath:@"frame"] CGRectValue];
        CGRect rect2 = searchButton.frame;

        rect2.origin.x = rect.origin.x + rect.size.width;
        
        searchButton.frame = rect2;
    }
}

@end
