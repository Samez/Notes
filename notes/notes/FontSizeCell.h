//
//  FontSizeCell.h
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FontSizeCellDelegate;

@interface FontSizeCell : UITableViewCell

@property NSString *identificator;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property id<FontSizeCellDelegate> delegate;

-(void)setupWithIdentificator:(NSString*)aIdentificator;

@end

@protocol FontSizeCellDelegate <NSObject>

-(void)fontSizeCell:(FontSizeCell*)cell didChangeFontSizeTo:(int)size;

@end
