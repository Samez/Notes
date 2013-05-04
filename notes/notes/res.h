//
//  res.h
//  notes
//
//  Created by Samez on 10.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#ifndef notes_res_h
#define notes_res_h

#define _STANDART_TABBAR_HEIGHT 521
#define _HIDDEN_TABBAR_HEIGHT 570
#define _NORMAL_TABBAR_CHANGE_VALUE 170
#define  _SHIFT_CELL_LENGTH 30 


@interface UIColor (Extensions)

+(UIColor *) sashaGray;

@end

@implementation UIColor (Extensions)

+ (UIColor *)sashaGray
{
    return [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3];
}

@end

#endif
