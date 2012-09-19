//
//  MVSKeychainItem.m
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/6/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//


#import "_MVSKeychainItem.h"

NSString *const kMVSKeychainItemErrorDomain = @"com.geekonastick.mvskeychainitem";


@interface _MVSKeychainItem ()
- (BOOL)addWithError:(NSError **)error;
- (BOOL)updateWithError:(NSError **)error;
- (CFTypeRef)keychainClassRef;
@end

@implementation _MVSKeychainItem

// PROPERTIES
@synthesize shouldLogActions = _shouldLogActions;
@synthesize keychainAttributes = _keychainAttributes;
@synthesize queries = _queries;

// ATTRIBUTES
@synthesize keychainClass = _keychainClass;
@synthesize accessible = _accessible;
@synthesize label = _label;
@synthesize accessGroup = _accessGroup;


#pragma mark PROPERTIES

// PUBLIC
- (NSDictionary*)keychainAttributes
{
  if (!_keychainAttributes) {
    _keychainAttributes = [[self class] defaultAttributeValues];
  }
  return _keychainAttributes;
}

// PUBLIC
- (MVSKeychainQuery*)queries
{
  if (!_queries) {
    _queries = [[MVSKeychainQuery alloc] initWithAttributesToMatch:self.keychainAttributes
                                                        matchLimit:kMATCH_ONE
                                                     keychainClass:self.keychainClass];
  }
  return _queries;
}

#pragma mark ATTRIBUTES

// PUBLIC
- (NSString*)accessGroup
{
  if (_accessGroup) return _accessGroup;
  return [self objectForKey:(__bridge id)kSecAttrAccessGroup];
}

// PUBLIC
- (NSString*)label
{
  if (_label) return _label;
  return [self objectForKey:(__bridge id)kSecAttrLabel];  
}

// PUBLIC
- (NSString*)accessible
{
  if (_accessible) return _accessible;
  return [self objectForKey:(__bridge id)kSecAttrAccessible];
}

#pragma mark CONSTRUCTORS

// OVERIDE
- (id)init
{
  if ((self = [super init])) {
    _shouldLogActions = YES;
    _keychainClass = [[self class] keychainClass];
  }
  return self;
}

// PUBLIC
- (id)initWithLabel:(NSString*)theLabel
{
  return [self initWithLabel:theLabel accessGroup:nil];
}

// PUBLIC
- (id)initWithLabel:(NSString*)theLabel
        accessGroup:(NSString*)theAccessGroup
{
  if (!theLabel) return nil;
  if ((self = [self init])) {
    _label = theLabel;
    _accessGroup = theAccessGroup;
  }
  return self;
}

// PUBLIC
- (id)initWithAttributes:(NSDictionary*)theAttributes
{
  if (!theAttributes) return nil;
  if ((self = [self init])) {
    _keychainAttributes = [NSDictionary dictionaryWithDictionary: theAttributes];
  }
  return self;
}

// PUBLIC
+ (id)keychainItemWithLabel:(NSString*)theLabel
                     accessGroup:(NSString*)theAccessGroup
{
  NSError *localError;
  _MVSKeychainItem *item = [[_MVSKeychainItem alloc] initWithLabel:theLabel
                                                            accessGroup:theAccessGroup];
  if (![item successfullyQueriedForKeychainItemWithError:&localError]) return nil;
  if (localError) return nil;
  return item;
}

// OVERIDE
- (NSString*)description
{
  NSMutableDictionary *temp = [NSMutableDictionary dictionary];
  [temp addEntriesFromDictionary:self.keychainAttributes];
  [temp addEntriesFromDictionary:self.modifiedAttributes];
  return [NSString stringWithFormat:@"attributes: %@", temp];
}

#pragma mark ACTIONS METHODS

// PUBLIC
- (BOOL)saveWithError:(NSError **)error
{
  if (!self.label) return NO;
  NSError *localError = nil;
  BOOL bResult = NO;
  BOOL bExists = [MVSKeychain itemExistsForQuery:self.queries.queryWithMatchLimit];
  if (self.shouldLogActions) NSLog(@"saveWithError - exists: %d, query: %@", bExists, self.queries.queryWithMatchLimit);
  if (bExists) {
    bResult = [self updateWithError:&localError];
  } else {
    bResult = [self addWithError:&localError];
  }
  
  if (localError) {
    if (self.shouldLogActions) NSLog(@"saveWithError - error: %@", localError);
    if (error != NULL) *error = localError;
    return NO;
    
  } else if (bResult) {
    [self dataWasSaved];
    
  }
  return bResult;
}


// PUBLIC
- (BOOL)deleteWithError:(NSError **)error
{
  BOOL bExists = [MVSKeychain itemExistsForQuery:self.queries.queryWithMatchLimit];
  if (self.shouldLogActions) NSLog(@"deleteWithError - exists: %d, query: %@", bExists, self.queries.queryWithMatchLimit);
 
  if (!bExists) {
    if (error != NULL) {
      *error = [NSError errorWithDomain:kMVSKeychainItemErrorDomain
                                   code:1000
                               userInfo:nil];
    }
    return NO;
  }
  
  NSError *localError = nil;
  localError = [MVSKeychain deleteItemForQuery:self.queries.baseQuery];
  if (localError) {
    if (self.shouldLogActions) NSLog(@"deleteWithError - error: %@", localError);    
    if (error != NULL) *error = localError;
    return NO;
  }
  return YES;
}

// PRIVATE
- (BOOL)addWithError:(NSError **)error
{
  NSDictionary *defaults = [[self class] defaultAttributeValues];  
  if (self.shouldLogActions) NSLog(@"addWithError - defaultAttributeValues: %@", defaults);
  
  NSDictionary *modified = [self modifiedAttributes];
  if (self.shouldLogActions) NSLog(@"addWithError - modifiedAttributes: %@", modified);
  
  
  NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary: defaults];
  [combinedAttributes addEntriesFromDictionary:modified];
  if (self.shouldLogActions) NSLog(@"addWithError - combinedAttributes: %@", combinedAttributes);
    
  [combinedAttributes setObject:(__bridge id)self.keychainClassRef forKey:(__bridge id)kSecClass];
  
  NSArray *theRequiredAttributes = [NSArray arrayWithArray:[[self class] requiredAttributeKeysForInsert]];
  for (id aKey in theRequiredAttributes) {
    id anObject = nil;
    anObject = [combinedAttributes objectForKey:aKey];
    if (!anObject) {
      if (self.shouldLogActions) NSLog(@"addWithError - missing REQUIRED key/value pair! key: %@", aKey);
      if (error != NULL) {
        *error = [NSError errorWithDomain:kMVSKeychainItemErrorDomain
                                     code:1002
                                 userInfo:nil];
      }      
      return NO;
    }
  }
  
  NSError *localError;
  localError = [MVSKeychain addItemWithAttributes:combinedAttributes];
  if (localError) {
    if (self.shouldLogActions) NSLog(@"addWithError - error: %@", localError);
    if (error != NULL) *error = localError;
  } else {
    [combinedAttributes removeObjectForKey:(__bridge id)kSecAttrModificationDate];
    self.keychainAttributes = [NSDictionary dictionaryWithDictionary: combinedAttributes];
  }
  return (localError == nil);
}

// PRIVATE
- (BOOL)updateWithError:(NSError **)theError
{
  if (self.shouldLogActions) NSLog(@"updateWithError - query: %@", self.queries.queryWithMatchLimit);
  
  if (self.shouldLogActions) NSLog(@"updateWithError - modifiedAttributes: %@", self.modifiedAttributes);
  NSError *localError = nil;
  localError= [MVSKeychain updateItemforQuery:self.queries.queryWithMatchLimit
                        withModifiedAttributes:self.modifiedAttributes];
  
  if (localError) {
    if (self.shouldLogActions) NSLog(@"updateWithError - ERROR: %@", localError);
    if (theError != NULL) *theError =localError;
  } else {
    NSMutableDictionary *combinedAttributes = [NSMutableDictionary dictionaryWithDictionary: self.keychainAttributes];
    [combinedAttributes addEntriesFromDictionary:self.modifiedAttributes];
    [combinedAttributes removeObjectForKey:(__bridge id)kSecAttrModificationDate];
    _keychainAttributes = [NSDictionary dictionaryWithDictionary: combinedAttributes];
  }
  return (localError == nil);
}

#pragma mark GENERIC ATTRIBUTE ACCESS
// PUBLIC
- (id)objectForKey:(id)key
{
  return [self.keychainAttributes objectForKey:key];
}

// PUBLIC
- (BOOL)boolForKey:(id)theKey
{
  if (!self.keychainAttributes) return NO;
  CFBooleanRef myBool = NULL;
  myBool = (__bridge CFBooleanRef)([self objectForKey:(id)theKey]);
  return (myBool == kCFBooleanTrue);
}

// PRIVATE
- (CFTypeRef)keychainClassRef
{
  return [MVSKeychain CFTypeRefFromKeychainClass:self.keychainClass];
}

#pragma mark QUERY ACTIONS

// PUBLIC
- (BOOL)successfullyQueriedForKeychainItemWithError:(NSError**)theError
{
  NSError *localError;
  NSDictionary *queryResults = [MVSKeychain resultsForQuery:self.queries.queryWithMatchLimit
                                                           error:&localError];  
  if (self.shouldLogActions) NSLog(@"successfullyQueriedForKeychainItemWithError: - QUERY: %@",
                                   self.queries.queryWithMatchLimit);

  if (localError) {
    *theError = [NSError errorWithDomain:kMVSKeychainItemErrorDomain
                                    code:localError.code
                                userInfo:nil];
    if (self.shouldLogActions) NSLog(@"successfullyQueriedForKeychainItemWithError: - ERROR: %@",
                                     localError);
    return NO;
  }
  if (!queryResults) return NO;
  
  self.keychainAttributes = [self getAttributes];  
  return (self.keychainAttributes != nil);
}

// PRIVATE
- (NSDictionary *)getAttributes
{
  NSError *localError;
  if (self.shouldLogActions) NSLog(@"getAttributes: - QUERY: %@", self.queries.queryWithAttributesReturnType);
  NSDictionary *queryResults = [MVSKeychain resultsForQuery:self.queries.queryWithAttributesReturnType
                                                      error:&localError];
  if (localError != nil) {
    if (self.shouldLogActions) NSLog(@"getAttributes: - ERROR: %@", localError);
    return nil;
  }
  return queryResults;
}

#pragma mark PROTOCOL METHODS

// PUBLIC
+ (NSArray*)attributeKeys
{
  NSMutableArray *temp = [NSMutableArray array];
  [temp addObject:(__bridge id)kSecAttrAccessible];
  [temp addObject:(__bridge id)kSecAttrAccessGroup];
  [temp addObject:(__bridge id)kSecAttrLabel];
  [temp addObject:(__bridge id)kSecClass];
  return [NSArray arrayWithArray:temp];
}

- (NSDictionary*)modifiedAttributes
{
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  
  if (_label) [result setObject:_label forKey:(__bridge id)kSecAttrLabel];
  if (_accessible) [result setObject:_accessible forKey:(__bridge id)kSecAttrAccessible];
  if (_accessGroup) [result setObject:_accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
  // keychainClass is readonly
  return result;
}

+ (NSDictionary*)defaultAttributeValues
{
  NSMutableDictionary *temp = [NSMutableDictionary dictionary];
  [temp setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
  [temp setObject:(__bridge id)[MVSKeychain CFTypeRefFromKeychainClass:[[self class] keychainClass]] forKey:(__bridge id)kSecClass];
  [temp setObject:@"" forKey:(__bridge id)kSecAttrLabel];
  return temp;
}

+ (NSArray*)requiredAttributeKeysForInsert
{
  NSMutableArray *temp = [NSMutableArray array];
  [temp addObject:(__bridge id)kSecAttrAccessible];
  [temp addObject:(__bridge id)kSecClass];
  [temp addObject:(__bridge id)kSecAttrLabel];
  return [NSArray arrayWithArray:temp];
}

+ (MVSKeychainClass)keychainClass
{
  return kGENERIC_PASSWORD;
}

- (void)dataWasSaved
{
  _queries = nil;
  _label = nil;
  _accessible = nil;
  _accessGroup = nil;
}

@end
