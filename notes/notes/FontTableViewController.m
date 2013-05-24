//
//  FontTableViewController.m
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "FontTableViewController.h"
#import "FontPickingViewController.h"

@implementation FontTableViewController

@synthesize fontSizeCell;
@synthesize fontCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"FontLabel", nil)];
    
    [[[self navigationController]navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"woodenBackground.png"]];
    
    [[self tableView] setBackgroundView:backgroundImageView];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(void)configureFontSizeCell:(FontSizeCell*)cell withidentificator:(NSString*)identificator
{
    [cell setupWithIdentificator:identificator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
}

-(void)configureFontPickCell:(FontCell*)cell withidentificator:(NSString*)identificator
{
    [cell setupWithIdentificator:identificator];
}

-(void)fontSizeCell:(FontSizeCell *)cell didChangeFontSizeTo:(int)size
{
    int section = 0;
    
    NSString *identificator = [NSString stringWithString:[cell identificator]];
    
    NSString *newStr;
    
    newStr = [identificator substringToIndex:[identificator length]-4];
    
    if (![newStr isEqualToString:@"noteNameFont"])
        section++;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    [((FontCell*)[self.tableView cellForRowAtIndexPath:indexPath]) myDetailLabel].font = [[[((FontCell*)[self.tableView cellForRowAtIndexPath:indexPath]) myDetailLabel] font] fontWithSize:size];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FontCell";
    FontCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FontCell" owner:self options:nil];
        cell = fontCell;
        fontCell = nil;
    }
    
    static NSString *MyFontSizeCellIdentifier = @"FontSizeCell";
    FontSizeCell * fontC = [tableView dequeueReusableCellWithIdentifier:MyFontSizeCellIdentifier];
    
    if (!fontC)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FontSizeCell" owner:self options:nil];
        fontC = fontSizeCell;
        fontSizeCell = nil;
    }
    
    UITableViewCell *cellToReturn = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch(indexPath.row)
            {
                case 0:
                {
                    [self configureFontPickCell:cell withidentificator:@"noteNameFont"];
                    cellToReturn = cell;
                    break;
                }
                case 1:
                {
                    [self configureFontSizeCell:fontC withidentificator:@"noteNameFontSize"];
                    cellToReturn = fontC;
                    break;
                }
            }
            break;
        }
        case 1:
        {
            switch(indexPath.row)
            {
                case 0:
                {
                    [self configureFontPickCell:cell withidentificator:@"noteTextFont"];
                    cellToReturn = cell;
                    break;
                }
                case 1:
                {
                    [self configureFontSizeCell:fontC withidentificator:@"noteTextFontSize"];
                    cellToReturn = fontC;
                    break;
                }
            }
            break;
        }
    }
    
    
    return cellToReturn;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *nextViewController = nil;
    
    switch(indexPath.section)
    {
        case 0:
        {
            switch(indexPath.row)
            {
                case 0:
                {
                    nextViewController = [[FontPickingViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [(FontPickingViewController*)nextViewController setIdentificator:@"noteNameFont"];
                    break;
                }
            }
            break;
        }
        case 1:
        {
            switch(indexPath.row)
            {
                case 0:
                {
                    nextViewController = [[FontPickingViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [(FontPickingViewController*)nextViewController setIdentificator:@"noteTextFont"];
                    break;
                }
            }
            break;
        }
    }
    
    if (nextViewController)
    {
        [[self navigationController] pushViewController:nextViewController animated:YES];
    }

}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case 0:
        {
            //title = @"Имя заметки";
            break;
        }
        case 1:
        {
            //title = @"Текст заметки";
            break;
        }
    }
    
    return title;
}

- (void)viewDidUnload
{
    [self setFontSizeCell:nil];
    [self setFontCell:nil];
    [self setFontCell:nil];
    [super viewDidUnload];
}
@end
