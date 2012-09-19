//
//  MVSKeychainQuery.m
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/13/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import "MVSKeychainQuery.h"

@implementation MVSKeychainQuery

@synthesize keychainClass = _keychainClass;
@synthesize attributesToMatch = _attributesToMatch;
@synthesize matchLimit = _matchLimit;

@synthesize baseQuery = _baseQuery;
@synthesize queryWithMatchLimit = _queryWithMatchLimit;

@synthesize queryWithAttributesReturnType = _queryWithAttributesReturnType;
@synthesize queryWithDataReturnType = _queryWithDataReturnType;
@synthesize queryWithRefReturnType = _queryWithRefReturnType;

#pragma mark CLASS

+ (NSDictionary*)queryFromAttributes:(NSDictionary*)theAttributes
                          matchLimit:(MVSKeychainMatchLimit)theMatchLimit
                       keychainClass:(MVSKeychainClass)theClass
                          returnType:(MVSKeychainReturnType)theReturnType
{
  NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    
  // ATTRIBUTES
  if (theAttributes) {
    NSArray *theKeys = [theAttributes allKeys];
    for (id aKey in theKeys) {
      [temp setObject:[theAttributes objectForKey:aKey] forKey:aKey];
    }
#if TARGET_IPHONE_SIMULATOR
    // THERE IS NO ACCESS GROUP ON THE SIMULATOR
    [temp removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
  }
  
  // MATCH LIMIT
  if (theMatchLimit != kMATCH_NONE) {
    [temp setObject:(__bridge id)[MVSKeychain CFTypeRefFromMatchLimit:theMatchLimit] forKey:(__bridge id)kSecMatchLimit];
  }
    
  // CLASS
  if (theClass != kCLASS_NONE) {
    [temp setObject:(__bridge id)[MVSKeychain CFTypeRefFromKeychainClass:theClass] forKey:(__bridge id)kSecClass];
  }

  // RETURN TYPE
  if (theReturnType != kRETURN_NONE) {
    [temp setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)[MVSKeychain CFTypeRefFromReturnType:theReturnType]];
  }
  
  return [NSDictionary dictionaryWithDictionary:temp];;
}

#pragma mark CONSTRUCTOR

- (id)init
{
  if ((self = [super init])) {
    _keychainClass = kGENERIC_PASSWORD;
    _matchLimit = kMATCH_ONE;
  }
  return self;
}

- (id)initWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
{
  return [self initWithAttributesToMatch:theAttributesToMatch
                              matchLimit:kMATCH_ONE
                           keychainClass:kGENERIC_PASSWORD];
}

- (id)initWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
                     matchLimit:(MVSKeychainMatchLimit)theMatchLimit
{
  return [self initWithAttributesToMatch:theAttributesToMatch
                              matchLimit:theMatchLimit
                           keychainClass:kGENERIC_PASSWORD];
}

- (id)initWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
                     matchLimit:(MVSKeychainMatchLimit)theMatchLimit
                  keychainClass:(MVSKeychainClass)theKeychainClass
{
  if (!theAttributesToMatch) return nil;
  if ((self = [self init])) {
    _keychainClass = theKeychainClass;
    _matchLimit = theMatchLimit;
    _attributesToMatch = [NSDictionary dictionaryWithDictionary: theAttributesToMatch];
  }
  return self;
}

+ (id)keychainQueryWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
                              matchLimit:(MVSKeychainMatchLimit)theMatchLimit
                           keychainClass:(MVSKeychainClass)theKeychainClass
{
  return [[MVSKeychainQuery alloc] initWithAttributesToMatch:theAttributesToMatch
                                                  matchLimit:theMatchLimit
                                               keychainClass:theKeychainClass];
}

#pragma mark QUERIES

// PUBLIC
- (NSDictionary*)baseQuery
{
  if (!_baseQuery) {
    _baseQuery = [[self class] queryFromAttributes:self.attributesToMatch
                                        matchLimit:kMATCH_NONE
                                     keychainClass:self.keychainClass
                                        returnType:kRETURN_NONE];
  }
  return _baseQuery;
}

// PUBLIC
- (NSDictionary*)queryWithMatchLimit
{
  if (!_queryWithMatchLimit) {
    _queryWithMatchLimit = [[self class] queryFromAttributes:self.attributesToMatch
                                                  matchLimit:self.matchLimit
                                               keychainClass:self.keychainClass
                                                  returnType:kRETURN_NONE];
  }
  return _queryWithMatchLimit;
}

// PUBLIC
- (NSDictionary*)queryWithAttributesReturnType
{
  if (!_queryWithAttributesReturnType) {
    _queryWithAttributesReturnType = [[self class] queryFromAttributes:self.attributesToMatch
                                                            matchLimit:self.matchLimit
                                                         keychainClass:self.keychainClass
                                                            returnType:kRETURN_ATTRIBUTES];
  }
  return _queryWithAttributesReturnType;
}

// PUBLIC
- (NSDictionary*)queryWithDataReturnType
{
  if (!_queryWithDataReturnType) {
    _queryWithDataReturnType = [[self class] queryFromAttributes:self.attributesToMatch
                                                      matchLimit:self.matchLimit
                                                   keychainClass:self.keychainClass
                                                      returnType:kRETURN_DATA];
  }
  return _queryWithDataReturnType;
}

- (NSDictionary*)queryWithRefReturnType
{
  if (!_queryWithRefReturnType) {
    _queryWithRefReturnType  = [[self class] queryFromAttributes:self.attributesToMatch
                                                      matchLimit:self.matchLimit
                                                   keychainClass:self.keychainClass
                                                      returnType:kRETURN_REF];
  }
  return _queryWithRefReturnType;
}

@end
