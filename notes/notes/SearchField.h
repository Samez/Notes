//
//  SearchField.h
//  notes
//
//  Created by Samez on 18.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchField : UITextField {
    UIView *cursor_;
}

@property (nonatomic, strong) UIColor *cursorColor;

@end
