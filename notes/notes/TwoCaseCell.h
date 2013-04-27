//
//  TwoCaseCell.h
//  notes
//
//  Created by Samez on 26.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoCaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property BOOL leftSelected;
- (IBAction)leftButtonClick:(id)sender;
- (IBAction)rightButtonClick:(id)sender;

@end
