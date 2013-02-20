//
//  addNewNoteViewController.h
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "privateSwitcherCell.h"
#import "enterNameCell.h"
#import "enterTextCell.h"

@protocol NoteAddDelegate;

@interface addNewNoteViewController : UITableViewController

@property (nonatomic, retain) Note *note;
@property(nonatomic, assign) id <NoteAddDelegate> delegate;

@end


@protocol NoteAddDelegate <NSObject>

- (void)NoteAddViewController:(addNewNoteViewController *)addNoteViewController didAddNote:(Note *)note;

@end