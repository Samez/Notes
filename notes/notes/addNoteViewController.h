//
//  addNoteViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol NoteAddDelegate;


@interface addNoteViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) Note * note;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *textField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *privateSwitcher;


@property(nonatomic, assign) id <NoteAddDelegate> delegate;

- (void)save;
- (void)cancel;

@end

@protocol NoteAddDelegate <NSObject>

- (void)NoteAddViewController:(addNoteViewController *)addNoteViewController didAddNote:(Note *)note;

@end
