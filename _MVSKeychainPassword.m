//
//  _MVSKeychainPassword.m
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/7/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//



#import "_MVSKeychainPassword.h"

@interface _MVSKeychainPassword ()
@property NSNumber *invisible;
@property NSNumber *negative;
@end

@implementation _MVSKeychainPassword

// ATTRIBUTES
@synthesize descriptionInKeychain = _descriptionInKeychain;
@synthesize comment = _comment;
@synthesize creator = _creator;
@synthesize type = _type;

@synthesize invisible = _invisible;
@synthesize negative = _negative;

#pragma mark ATTRIBUTES

- (NSDate*)creationDate
{
  return [self objectForKey:(__bridge id)kSecAttrCreationDate];
}

- (NSDate*)modificationDate
{
  return [self objectForKey:(__bridge id)kSecAttrModificationDate];
}

- (NSString*)descriptionInKeychain
{
  if (_descriptionInKeychain) return _descriptionInKeychain;
  return [self objectForKey:(__bridge id)kSecAttrDescription];
}

- (NSString*)comment
{
  if (_comment) return _comment;
  return [self objectForKey:(__bridge id)kSecAttrComment];
}

- (NSNumber*)creator
{
  if (_creator) return _creator;
  return [self objectForKey:(__bridge id)kSecAttrCreator];
}

- (NSNumber*)type
{
  if (_type) return _type;
  return [self objectForKey:(__bridge id)kSecAttrType];
}

- (BOOL)isInvisible
{
  if (_invisible) return [_invisible boolValue];
  return [self boolForKey:(__bridge id)kSecAttrIsInvisible];
}

- (void)setIsInvisible:(BOOL)isInvisible
{
  _invisible = [NSNumber numberWithBool:isInvisible];
}

- (BOOL)isNegative
{
  if (_negative) return [_negative boolValue];
  return [self boolForKey:(__bridge id)kSecAttrIsNegative];
}

- (void)setIsNegative:(BOOL)isNegative
{
  _negative = [NSNumber numberWithBool:isNegative];
}

#pragma mark PROTOCOL METHODS
+ (NSDictionary*)defaultAttributeValues
{
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary: [super defaultAttributeValues]];
  // creationDate and modificationDate are read only and should not be in this list
  [result setObject:(__bridge id)kCFBooleanFalse forKey:(__bridge id)kSecAttrIsInvisible];
  [result setObject:(__bridge id)kCFBooleanFalse forKey:(__bridge id)kSecAttrIsNegative];
  return result;
}

+ (MVSKeychainClass)keychainClass
{
  return kGENERIC_PASSWORD;
}

// PUBLIC
+ (NSArray*)attributeKeys
{
  NSMutableArray *temp = [NSMutableArray arrayWithArray:[[super class] attributeKeys]];
  [temp addObject:(__bridge id)kSecAttrCreationDate];
  [temp addObject:(__bridge id)kSecAttrModificationDate];
  [temp addObject:(__bridge id)kSecAttrDescription];
  [temp addObject:(__bridge id)kSecAttrComment];
  [temp addObject:(__bridge id)kSecAttrCreator];
  [temp addObject:(__bridge id)kSecAttrType];
  [temp addObject:(__bridge id)kSecAttrIsInvisible];
  [temp addObject:(__bridge id)kSecAttrIsNegative];
  return [NSArray arrayWithArray:temp];
}

- (NSDictionary*)modifiedAttributes
{
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary: [super modifiedAttributes]];
  // creationDate and modificationDate are read only and should never be in this list
  if (_descriptionInKeychain) [result setObject:_descriptionInKeychain forKey:(__bridge id)kSecAttrDescription];
  if (_comment) [result setObject:_comment forKey:(__bridge id)kSecAttrComment];
  if (_creator) [result setObject:_creator forKey:(__bridge id)kSecAttrCreator];
  if (_type) [result setObject:_type forKey:(__bridge id)kSecAttrType];
  if (_invisible) {
    [result setObject:(__bridge id)[MVSKeychain CFBooleanRefFromNumber:_invisible] forKey:(__bridge id)kSecAttrIsInvisible];
  }
  if (_negative) {
    [result setObject:(__bridge id)[MVSKeychain CFBooleanRefFromNumber:_negative] forKey:(__bridge id)kSecAttrIsNegative];
  }
  return result;
}

+ (NSArray*)requiredAttributeKeysForInsert
{
  return [super requiredAttributeKeysForInsert];
}

- (void)dataWasSaved
{
  [super dataWasSaved];
  _descriptionInKeychain = nil;
  _comment = nil;
  _creator = nil;
  _type = nil;
  _invisible = nil;
  _negative = nil;
}


@end