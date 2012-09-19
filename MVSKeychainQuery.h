//
//  MVSKeychainQuery.h
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/13/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "MVSKeychain.h"

@interface MVSKeychainQuery : NSObject

@property (readonly) MVSKeychainClass keychainClass;
@property (readonly) NSDictionary *attributesToMatch;
@property (readonly) MVSKeychainMatchLimit matchLimit;

@property (readonly) NSDictionary *baseQuery;
@property (readonly) NSDictionary *queryWithMatchLimit;

@property (readonly) NSDictionary *queryWithAttributesReturnType;
@property (readonly) NSDictionary *queryWithDataReturnType;
@property (readonly) NSDictionary *queryWithRefReturnType;

- (id)initWithAttributesToMatch:(NSDictionary*)theAttributesToMatch;

- (id)initWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
                     matchLimit:(MVSKeychainMatchLimit)theMatchLimit;

- (id)initWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
                     matchLimit:(MVSKeychainMatchLimit)theMatchLimit
                  keychainClass:(MVSKeychainClass)theKeychainClass;

+ (id)keychainQueryWithAttributesToMatch:(NSDictionary*)theAttributesToMatch
                              matchLimit:(MVSKeychainMatchLimit)theMatchLimit
                           keychainClass:(MVSKeychainClass)theKeychainClass;

+ (NSDictionary*)queryFromAttributes:(NSDictionary*)theAttributes
                          matchLimit:(MVSKeychainMatchLimit)theMatchLimit
                       keychainClass:(MVSKeychainClass)theClass
                          returnType:(MVSKeychainReturnType)theReturnType;

@end

/*
 A typical query consists of:
 
 * a kSecClass key, whose value is a constant from the Class
 Constants section that specifies the class of item(s) to be searched
 
 * one or more keys from the "Attribute Key Constants" section, whose value
 is the attribute data to be matched
 
 * one or more keys from the "Search Constants" section, whose value is
 used to further refine the search
 
 * a key from the "Return Type Key Constants" section, specifying the type of
 results desired
 */

/*
 CFTypeRef kSecMatchPolicy;
 CFTypeRef kSecMatchItemList;
 CFTypeRef kSecMatchSearchList;
 CFTypeRef kSecMatchIssuers;
 CFTypeRef kSecMatchEmailAddressIfPresent;
 CFTypeRef kSecMatchSubjectContains;
 CFTypeRef kSecMatchCaseInsensitive;
 CFTypeRef kSecMatchTrustedOnly;
 CFTypeRef kSecMatchValidOnDate;
 CFTypeRef kSecMatchLimit;
 CFTypeRef kSecMatchLimitOne;
 CFTypeRef kSecMatchLimitAll;
*/

/*
 CFTypeRef kSecReturnData;
 CFTypeRef kSecReturnAttributes;
 CFTypeRef kSecReturnRef;
 CFTypeRef kSecReturnPersistentRef;
*/ 
