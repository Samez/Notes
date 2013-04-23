//
//  privateSwitcherCell.h
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellWithSwitcher: UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *stateSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;

@end
