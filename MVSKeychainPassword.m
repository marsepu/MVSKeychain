//
//  MVSKeychainPassword.m
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/6/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import "MVSKeychainPassword.h"

#pragma mark CATEGORY ON MVSKeychainQuery
@implementation MVSKeychainQuery (MVSKeychainPassword)

+ (NSDictionary*)queryForAttributesWithLabel:(NSString*)theLabel
                                 accessGroup:(NSString*)theAccessGroup
                                     account:(NSString*)theAccount
{
  NSMutableDictionary *tempAttributes = [NSMutableDictionary dictionary];
  if (theLabel) [tempAttributes setObject:theLabel forKey:(__bridge id)kSecAttrLabel];
  if (theAccessGroup) [tempAttributes setObject:theAccessGroup forKey:(__bridge id)kSecAttrAccessGroup];
  if (theAccount) [tempAttributes setObject:theAccount forKey:(__bridge id)kSecAttrAccount];
  
  return [MVSKeychainQuery queryFromAttributes:tempAttributes
                                   matchLimit:kMATCH_ONE
                                keychainClass:kGENERIC_PASSWORD
                                   returnType:kRETURN_ATTRIBUTES];
}

@end

NSString *const kMVSKeychainPasswordErrorDomain = @"com.geekonastick.mvskeychainpassword";

@implementation MVSKeychainPassword
@synthesize password = _password;
@synthesize account = _account;
@synthesize service = _service;
@synthesize generic = _generic;

#pragma mark PROPERTIES

- (NSString*)password
{
  if (_password) return _password;  
  NSData *localData = [self passwordData];
  if (!localData) return nil;
  return [[NSString alloc] initWithBytes:localData.bytes
                                  length:localData.length
                                encoding:NSUTF8StringEncoding];
}

- (NSString*)account
{
  if (_account) return _account;
  return [self objectForKey:(__bridge id)kSecAttrAccount];
}

- (NSString*)service
{
  if (_service) return _service;
  return [self objectForKey:(__bridge id)kSecAttrService];
}

- (NSData*)generic
{
  if (_generic) return _generic;
  return [self objectForKey:(__bridge id)kSecAttrGeneric];
}

#pragma mark CONSTRUCTORS

// PUBLIC, NO QUERY PERFORMED FOR THIS ONE
- (id)initWithLabel:(NSString*)theLabel
        accessGroup:(NSString*)theAccessGroup
            account:(NSString*)theAccount
{
  if (!theAccount) return nil;
  if ((self = [self initWithLabel:theLabel accessGroup:theAccessGroup])) {
    _account = theAccount;
  }
  return self;
}

// PUBLIC, A QUERY IS PERFORMED HERE
+ (MVSKeychainPassword *)passwordItemForLabel:(NSString*)theLabel
                                  accessGroup:(NSString*)theAccessGroup
                                      account:(NSString*)theAccount
                                  
{
  if (!theAccount) return nil;
  
  NSDictionary *query = [MVSKeychainQuery queryForAttributesWithLabel:theLabel
                                                          accessGroup:theAccessGroup
                                                              account:theAccount];
  
  NSError *localError = nil;
  NSDictionary *attributes = nil;
  attributes = [MVSKeychain resultsForQuery:query
                                      error:&localError];
  if (localError) {
    NSLog(@"passwordItemForLabel:accessGroup:account: - query: %@ error: %@", query, localError);
    return nil;
  }
  if (!attributes) return nil;
  
  return [[MVSKeychainPassword alloc] initWithAttributes:attributes];
}

#pragma mark PASSWORD DATA

// PUBLIC
- (NSString*)genericString
{
  if (_generic) {
    return [[NSString alloc] initWithBytes:_generic.bytes
                                    length:_generic.length
                                  encoding:NSUTF8StringEncoding];
  }
  
  id test = [self objectForKey:(__bridge id)kSecAttrGeneric];
  // SOME OTHER APPS WRITE DATA AS AN NSSTRING INSTEAD OF NSDATA
  if ([test isKindOfClass:[NSString class]]) {
    return test;
  } else if ([test isKindOfClass:[NSData class]]) {
    return [[NSString alloc] initWithBytes:[(NSData*)test bytes]
                                    length:[(NSData*)test length]
                                  encoding:NSUTF8StringEncoding];
  }
  return nil;
}

// PUBLIC
- (NSData*)passwordData
{
  if (self.shouldLogActions) NSLog(@"passwordData - query: %@", self.queries.queryWithDataReturnType);
  
  NSError *localError = nil;
  NSData *data = nil;
  data = [MVSKeychain dataForQuery:self.queries.queryWithDataReturnType error:&localError];
  if (localError) {
    if (self.shouldLogActions) NSLog(@"passwordData - ERROR: %@", localError);
    return nil;
  }
  
  return data;
}

#pragma mark PROTOCOL METHODS


// PUBLIC
+ (NSArray*)attributeKeys
{
  NSMutableArray *temp = [NSMutableArray arrayWithArray:[super attributeKeys]];
  [temp addObject:(__bridge id)kSecAttrAccount];
  [temp addObject:(__bridge id)kSecAttrService];
  [temp addObject:(__bridge id)kSecAttrGeneric];
  return [NSArray arrayWithArray:temp];
}

// PUBLIC
+ (MVSKeychainClass)keychainClass
{
  return kGENERIC_PASSWORD;
}


// PUBLIC
- (NSDictionary*)modifiedAttributes
{    
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary: [super modifiedAttributes]];
  if (_account) [result setObject:_account forKey:(__bridge id)kSecAttrAccount];
  if (_service) [result setObject:_service forKey:(__bridge id)kSecAttrService];
  if (_generic) [result setObject:_generic forKey:(__bridge id)kSecAttrGeneric];
  if (_password) [result setObject:[self.password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
  
  return result;
}

// PUBLIC
+ (NSDictionary*)defaultAttributeValues
{
  NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary: [super defaultAttributeValues]];
  [temp setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];  
  [temp setObject:@"" forKey:(__bridge id)kSecAttrAccount];
  [temp setObject:[@"" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric];
  [temp setObject:@"" forKey:(__bridge id)kSecAttrService];
  [temp setObject:[@"" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];  
  return temp;
}

// PUBLIC
+ (NSArray*)requiredAttributeKeysForInsert
{
  NSMutableArray *temp = [NSMutableArray arrayWithArray:[super requiredAttributeKeysForInsert]];
  [temp addObject:(__bridge id)kSecValueData];
  [temp addObject:(__bridge id)kSecAttrAccount];
  return temp;
}

- (void)dataWasSaved
{
  [super dataWasSaved];
  _account = nil;
  _service = nil;
  _generic = nil;
  _password = nil;
}

@end
