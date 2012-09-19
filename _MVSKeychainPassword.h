//
//  _MVSKeychainPassword.h
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/7/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_MVSKeychainItem.h"

@interface _MVSKeychainPassword : _MVSKeychainItem <MVSKeychainItemProtocol>

// ATTRIBUTES
@property (readonly) NSDate *creationDate;
@property (readonly) NSDate *modificationDate;
@property (nonatomic) NSString *descriptionInKeychain;
@property (nonatomic) NSString *comment;
@property (nonatomic) NSNumber *creator;
@property (nonatomic) NSNumber *type;
@property (nonatomic, getter = isInvisible) BOOL isInvisible;
@property (nonatomic, getter = isNegative) BOOL isNegative;

@end
