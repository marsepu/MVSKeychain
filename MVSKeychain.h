//
//  MVSKeychain.h
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/5/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

extern NSString *const kMVSKeychainErrorDomain;

typedef enum {
  kCLASS_NONE = 0,
  kGENERIC_PASSWORD = 1,
  kINTERNET_PASSWORD,
  kCERTIFICATE,
  kKEY,
  kIDENTITY
} MVSKeychainClass;

typedef enum {
  kMATCH_NONE= 0,
  kMATCH_ONE = 1,
  kMATCH_ALL
} MVSKeychainMatchLimit;

typedef enum {
  kRETURN_NONE= 0,
  kRETURN_ATTRIBUTES = 1,
  kRETURN_DATA,
  kRETURN_REF,
  kRETURN_PERSISTANT_REF
} MVSKeychainReturnType;

@interface MVSKeychain : NSObject

// CF TRANSLATIONS
+ (CFTypeRef)CFTypeRefFromReturnType:(MVSKeychainReturnType)theReturnType;
+ (CFTypeRef)CFTypeRefFromMatchLimit:(MVSKeychainMatchLimit)inputMatchLimit;
+ (CFBooleanRef)CFBooleanRefFromNumber:(NSNumber*)theNumber;
+ (MVSKeychainClass)keychainClassFromRef:(CFTypeRef)theClass;
+ (CFTypeRef)CFTypeRefFromKeychainClass:(MVSKeychainClass)theClass;

// QUERY RESULTS
+ (BOOL)itemExistsForQuery:(NSDictionary*)query;
+ (NSArray*)itemsForQuery:(NSDictionary*)theQuery
                    error:(NSError**)theError;
+ (NSData*)dataForQuery:(NSDictionary*)theQuery
                  error:(NSError**)theError;
+ (NSDictionary*)resultsForQuery:(NSDictionary*)theOptions
                           error:(NSError**)theError;

// ACTIONS
+ (NSError *)updateItemforQuery:(NSDictionary*)theQuery
         withModifiedAttributes:(NSDictionary*)theModifiedAttributes;
+ (NSError *)addItemWithAttributes:(NSDictionary*)theAttributes;
+ (NSError*)deleteItemForQuery:(NSDictionary*)theQuery;

@end


@protocol MVSKeychainItemProtocol <NSObject>
+ (NSDictionary*)defaultAttributeValues;
+ (NSArray*)attributeKeys;
+ (NSArray*)requiredAttributeKeysForInsert;
+ (MVSKeychainClass)keychainClass;
- (NSDictionary*)modifiedAttributes;
- (void)dataWasSaved;
@end