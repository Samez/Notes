//
//  addNewNoteViewController.m
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _NAME 1
#define _PRIVATE 0
#define _TEXT 2

#import "addNewNoteViewController.h"

@interface addNewNoteViewController ()

@end

@implementation addNewNoteViewController

@synthesize note;
@synthesize managedObjectContext;

@synthesize fromPass;
@synthesize forEditing;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        forEditing = NO;
        fromPass = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(forEditing)
        self.navigationItem.title = @"Edit note";
    else
        self.navigationItem.title = @"Add note";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)save
{
    
    if ([self saveName])
    {
        [self saveText];
        
        [self saveState];
        
        NSError *error = nil;
        
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if (!fromPass)
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self.navigationController popToRootViewControllerAnimated:YES];
        
    } else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Не могу сохранить заметку" message:@"У заметки должно быть название" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)cancel
{
	if (!forEditing)
        [self.managedObjectContext deleteObject:note];

    if (!fromPass)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)saveState
{
    privateSwitcherCell *getStateCell = (privateSwitcherCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_PRIVATE]];
    [note setIsPrivate:[NSNumber numberWithBool:[getStateCell.stateSwitcher isOn]]];
}

-(BOOL)saveName
{
    enterNameCell * getNameCell = (enterNameCell *)[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:_NAME]];
    
    if ([[[getNameCell nameField] text] length]!=0)
    {
        [note setName:[[getNameCell nameField] text]];
        return YES;
    }
    return NO;
}

-(void)saveText
{
    enterTextCell *getTextCell = (enterTextCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_TEXT]];
    
    [note setText:[[getTextCell textFieldView] text]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] == _NAME)
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView tag] == _TEXT)
    {
        if([text isEqualToString:@"\n"])
        {
            [textView resignFirstResponder];
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case _NAME:
            title = @"Name";
            break;
        case _PRIVATE:
            //title = @"";
            break;
        case _TEXT:
            title = @"Text";
            break;
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=0.0f;
    
    switch (indexPath.section)
    {
        case _PRIVATE:
            height = 44.0;
            break;
        case _TEXT:
            height = 132.0;
            break;
        case _NAME:
            height = 44.0;
            break;
    }
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    
    switch (indexPath.section)
    {
        case _PRIVATE:
        {
            static NSString *CellIdentifier = @"privateSwitcher";
            
            privateSwitcherCell *MYcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (MYcell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"privateSwitcher" owner:self options:nil];
                MYcell = [topLevelObjects objectAtIndex:0];
            }
            
            if (forEditing)
                [MYcell.stateSwitcher setOn:[note.isPrivate boolValue]];
            else
                [MYcell.stateSwitcher setOn:NO];
            
            return MYcell;
            break;
        }
        case _NAME:
        {
            static NSString *CellIdentifier = @"enterNameCell";
            enterNameCell *MYcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (MYcell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"enterNameCell" owner:self options:nil];
                MYcell = [topLevelObjects objectAtIndex:0];
            }
            
            [MYcell setNote:note];
            
            MYcell.nameField.delegate = self;
            MYcell.nameField.tag = _NAME;
            MYcell.nameField.returnKeyType = UIReturnKeyDone;
            
            return MYcell;
        }
        case _TEXT:
        {
            static NSString *CellIdentifier = @"enterTextCell";
            enterTextCell *MYcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (MYcell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"enterTextCell" owner:self options:nil];
                MYcell = [topLevelObjects objectAtIndex:0];
            }
            
            [MYcell setNote:note];
            
            MYcell.textFieldView.delegate = self;
            MYcell.textFieldView.tag = _TEXT;
            MYcell.textFieldView.returnKeyType = UIReturnKeyDone;
            
            return MYcell;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
