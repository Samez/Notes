//
//  FontCell.h
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontSizeCell.h"

@interface FontCell : UITableViewCell

@property NSString* myIdentificator;
@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDetailLabel;

-(void)setupWithIdentificator:(NSString*)identificator;

@end
