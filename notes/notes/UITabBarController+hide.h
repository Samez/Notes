//
//  UITabBarController+hide.h
//  notes
//
//  Created by Samez on 06.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (hide)

@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
