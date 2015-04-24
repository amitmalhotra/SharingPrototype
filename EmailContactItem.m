//
//  EmailContactItem.m
//  SharingPrototype
//
//  Created by Patrick Arthurs on 4/20/15.
//  Copyright (c) 2015 TrackVia. All rights reserved.
//

#import "EmailContactItem.h"

@implementation EmailContactItem

- (instancetype) initWithEmailAddress: (NSString *) emailAddress firstName:(NSString *) first lastName:(NSString *) last
{
    self = [super init];
    
    if (self) {
        _emailAddress = emailAddress;
        _firstName = first;
        _lastName = last;
    }
    
    return self;
}

- (NSString *) description
{
    NSString *descriptionString = [[NSString alloc] initWithFormat:@"%@ :%@, %@",
                                   self.emailAddress,
                                   self.lastName,
                                   self.firstName];
    
    return descriptionString;
}

@end
