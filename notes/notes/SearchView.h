//
//  SearchView.h
//  notes
//
//  Created by Samez on 16.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewDelegate;

@interface SearchView : UIView <UITextFieldDelegate>
{
    UITextField *searchField;
    UIButton *searchButton;
    BOOL searchingNow;
    CGRect unsearchingButtonRect;
    CGRect oldFrame;
    CGRect narrowFieldFrame;
    id <SearchViewDelegate> delegate;
}
@property id <SearchViewDelegate> delegate;
@property UITextField *searchField;
@property UIButton *searchButton;
@property BOOL searchingNow;

-(void)buttonClick;

@end


@protocol SearchViewDelegate <NSObject>
@optional
-(void)searchView:(SearchView *) sender changeTextTo:(NSString*)text;
-(BOOL)searchViewWillStartSearching:(SearchView *) sender;
-(BOOL)searchViewWillEndSearching:(SearchView *)sender;

@end