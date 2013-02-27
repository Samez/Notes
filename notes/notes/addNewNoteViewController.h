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



@interface addNewNoteViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property BOOL forEditing;

@property (nonatomic, retain) Note *note;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
