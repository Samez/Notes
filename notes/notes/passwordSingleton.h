//
//  passwordSingleton.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface passwordSingleton : NSObject
{
    NSString *password;
}

@property NSString *password;

+(id)password;
@end
