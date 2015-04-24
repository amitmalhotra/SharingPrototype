//
//  EmailContactItem.h
//  SharingPrototype
//
//  Created by Patrick Arthurs on 4/20/15.
//  Copyright (c) 2015 TrackVia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailContactItem : NSObject

- (instancetype) initWithEmailAddress: (NSString *) emailAddress firstName:(NSString *) first lastName:(NSString *) last;

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *emailAddress;

@end
