//
//  FontPickingViewController.h
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontPickingViewController : UITableViewController
{
    NSMutableArray *fontsArray;
    UIColor *selectedColor;
    UIColor *unselectedColor;
}
@property NSString *identificator;

@end
