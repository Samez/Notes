//
//  passwordSingleton.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "passwordSingleton.h"

static passwordSingleton *password = nil;

@implementation passwordSingleton

@synthesize password;

-(id) init
{
    if(self = [super init])
    {
        password = [[NSString alloc]init];
    }
    return self;
}

+(id)password
{
    if (password == nil)
    {
        password = [[super allocWithZone:NULL] init];
    }
    return password;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self password] ;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
