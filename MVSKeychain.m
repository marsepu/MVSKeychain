//
//  MVSKeychain.m
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/5/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import "MVSKeychain.h"
#import "MVSKeychainQuery.h"

NSString *const kMVSKeychainErrorDomain = @"com.geekonastick.mvskeychain";

@implementation MVSKeychain

#pragma mark CF TRANSLATIONS

+ (CFTypeRef)CFTypeRefFromReturnType:(MVSKeychainReturnType)theReturnType
{
  CFTypeRef returnTypeRef = NULL;
  switch (theReturnType) {
    case kRETURN_ATTRIBUTES:
      returnTypeRef = kSecReturnAttributes;
      break;
    case kRETURN_DATA:
      returnTypeRef = kSecReturnData;
      break;
    case kRETURN_REF:
      returnTypeRef = kSecReturnRef;
      break;
    case kRETURN_PERSISTANT_REF:
      returnTypeRef = kSecReturnPersistentRef;
      break;
    default:
      break;
  }
  return returnTypeRef;
}

// PUBLIC
+ (CFTypeRef)CFTypeRefFromMatchLimit:(MVSKeychainMatchLimit)inputMatchLimit
{
  CFTypeRef outputMatchLimit = NULL;
  switch (inputMatchLimit) {
    case kMATCH_ALL:
      outputMatchLimit = kSecMatchLimitAll;
      break;
    case kMATCH_ONE:
      outputMatchLimit = kSecMatchLimitOne;
      break;
    default:
      break;
  }
  return outputMatchLimit;
}

+ (CFBooleanRef)CFBooleanRefFromNumber:(NSNumber*)theNumber
{
  if ([theNumber boolValue]) return kCFBooleanTrue;
  return kCFBooleanFalse;
}

// PUBLIC
+ (MVSKeychainClass)keychainClassFromRef:(CFTypeRef)theClass
{
  MVSKeychainClass result;
  if (theClass == kSecClassGenericPassword ) {
    result = kGENERIC_PASSWORD;
  } else if (theClass == kSecClassInternetPassword ) {
    result = kINTERNET_PASSWORD;
  } else if (theClass == kSecClassCertificate) {
    result = kCERTIFICATE;
  } else if (theClass == kSecClassKey) {
    result = kKEY;
  } else if (theClass == kSecClassIdentity) {
    result = kIDENTITY;
  } else {
    @throw [NSException exceptionWithName:kMVSKeychainErrorDomain
                                   reason:NSLocalizedString(@"unknown kSecClass constant: %@", theClass)
                                 userInfo:Nil];
  }
  return result;
}

// PUBLIC
+ (CFTypeRef)CFTypeRefFromKeychainClass:(MVSKeychainClass)theClass
{
  CFTypeRef theResult = NULL;
  switch (theClass) {
    case kGENERIC_PASSWORD:
      theResult = kSecClassGenericPassword;
      break;
    case kINTERNET_PASSWORD:
      theResult = kSecClassInternetPassword;
      break;
    case kCERTIFICATE:
      theResult = kSecClassCertificate;
      break;
    case kKEY:
      theResult = kSecClassKey;
      break;
    case kIDENTITY:
      theResult = kSecClassIdentity;
      break;
    default:
      break;
  }
  return theResult;
}

#pragma mark QUERY RESULTS

+ (NSArray*)itemsForQuery:(NSDictionary*)theQuery
                    error:(NSError**)theError
{
  if (!theQuery) return nil;
    
  OSStatus status = noErr;
  CFTypeRef resultRef = NULL;
  status = SecItemCopyMatching((__bridge CFDictionaryRef)theQuery, &resultRef);
  if (status != noErr) {
    if (theError != NULL) {
      *theError = [NSError errorWithDomain:kMVSKeychainErrorDomain
                                      code:status
                                  userInfo:nil];
    }
    return nil;
  }
  return (__bridge_transfer NSArray *)resultRef;
}

// PUBLIC
+ (NSData*)dataForQuery:(NSDictionary*)theQuery
                  error:(NSError**)theError
{
  OSStatus status = noErr;
  CFTypeRef resultRef = NULL;
  status = SecItemCopyMatching((__bridge CFDictionaryRef)theQuery, &resultRef);
  if (status != noErr) {
    if (theError != NULL) *theError = [NSError errorWithDomain:kMVSKeychainErrorDomain
                                                          code:status
                                                      userInfo:nil];
    return nil;
  }
  return (__bridge_transfer NSData *)resultRef;
}

// PUBLIC
+ (NSDictionary*)resultsForQuery:(NSDictionary*)theOptions
                           error:(NSError**)theError
{
  OSStatus status = noErr;
  CFTypeRef resultRef = NULL;
  status = SecItemCopyMatching((__bridge CFDictionaryRef)theOptions, &resultRef);
  if (status != noErr) {
    if (status == errSecItemNotFound) return nil;
    
    if (theError != NULL) {
      *theError = [NSError errorWithDomain:kMVSKeychainErrorDomain
                                      code:status
                                  userInfo:nil];
    }          
    return nil;
	}    
  return (__bridge_transfer NSDictionary *)resultRef;
}

// PUBLIC
+ (BOOL)itemExistsForQuery:(NSDictionary*)query
{
  if (!query) return NO;
  NSDictionary *results = nil;
  NSError *localError = nil;
  
  NSMutableDictionary *localQuery = [NSMutableDictionary dictionaryWithDictionary:query];
  [localQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
  
  results = [MVSKeychain resultsForQuery:localQuery error:&localError];
  if (localError != NULL) return NO;
  return (results != nil);
}

#pragma mark ACTION METHODS

// PUBLIC
+ (NSError*)deleteItemForQuery:(NSDictionary*)theQuery
{
  NSError *localError = nil;
  OSStatus status = noErr;
  
  NSMutableDictionary *localQuery = [theQuery mutableCopy];
#if TARGET_IPHONE_SIMULATOR
  // Remove the access group if running on the iPhone simulator.
  [localQuery removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
    
  [localQuery removeObjectForKey:(__bridge id)kSecMatchLimit];
  
  status = SecItemDelete((__bridge CFDictionaryRef)localQuery);
  if (status != noErr) localError = [NSError errorWithDomain:kMVSKeychainErrorDomain
                                                        code:status
                                                    userInfo:nil];
	return localError;
}

// PUBLIC
+ (NSError *)addItemWithAttributes:(NSDictionary*)theAttributes
{
  NSError *localError = nil;
  
  NSMutableDictionary *localAttributes = [NSMutableDictionary dictionaryWithDictionary:theAttributes];
#if TARGET_IPHONE_SIMULATOR
  // Remove the access group if running on the iPhone simulator.
  [localAttributes removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
  
  OSStatus result = SecItemAdd((__bridge CFDictionaryRef)localAttributes, NULL);
  if (result != noErr) {
    localError = [NSError errorWithDomain:kMVSKeychainErrorDomain
                                     code:result
                                 userInfo:nil];
  }  
  return localError;
}

// PUBLIC
+ (NSError *)updateItemforQuery:(NSDictionary*)theQuery
         withModifiedAttributes:(NSDictionary*)theModifiedAttributes
{
  NSError *localError = nil;
  
  NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:theModifiedAttributes];
#if TARGET_IPHONE_SIMULATOR
  // Remove the access group if running on the iPhone simulator.
  [attributes removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
  
  // this should be considered read only
  [attributes removeObjectForKey:(__bridge id)kSecClass];
  
  // UPDATES FAIL WITH THIS
  NSMutableDictionary *localQuery = [theQuery mutableCopy];
  [localQuery removeObjectForKey:(__bridge id)kSecMatchLimit];
  
  OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)localQuery, (__bridge CFDictionaryRef)attributes);
  if (result != errSecSuccess) {
    localError = [NSError errorWithDomain:kMVSKeychainErrorDomain
                                     code:result
                                 userInfo:nil];
  }
  return localError;
}


@end
