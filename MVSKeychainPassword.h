//
//  MVSKeychainPassword.h
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/6/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_MVSKeychainPassword.h"

extern NSString *const kMVSKeychainPasswordErrorDomain;

@interface MVSKeychainPassword : _MVSKeychainPassword <MVSKeychainItemProtocol>

// CONSTRUCTORS
- (id)initWithLabel:(NSString*)theLabel
        accessGroup:(NSString*)theAccessGroup
            account:(NSString*)theAccount;

+ (MVSKeychainPassword *)passwordItemForLabel:(NSString*)theLabel
                                  accessGroup:(NSString*)theAccessGroup
                                      account:(NSString*)theAccount;
                                  

// PROPERTIES
@property (nonatomic) NSString *password;

// ATTRIBUTES
@property (nonatomic) NSString *account;
@property (nonatomic) NSString *service;
@property (nonatomic) NSData *generic;

- (NSData*)passwordData;
- (NSString*)genericString;
@end

/*
 These are the default constants and their respective types,
 available for the kSecClassGenericPassword Keychain Item class:
 
 kSecAttrAccessible     - ???
 kSecAttrAccessGroup			-		CFStringRef
 kSecAttrCreationDate		-		CFDateRef
 kSecAttrModificationDate    -		CFDateRef
 kSecAttrDescription			-		CFStringRef
 kSecAttrComment				-		CFStringRef
 kSecAttrCreator				-		CFNumberRef
 kSecAttrType                -		CFNumberRef
 kSecAttrLabel				-		CFStringRef
 kSecAttrIsInvisible			-		CFBooleanRef
 kSecAttrIsNegative			-		CFBooleanRef
 kSecAttrAccount				-		CFStringRef
 
 kSecAttrService				-		CFStringRef
 kSecAttrGeneric				-		CFDataRef
 
 See the header file Security/SecItem.h for more details.
 */

/*
 @constant kSecAttrAccount Specifies a dictionary key whose value is the
 item's account attribute. You use this key to set or get a CFStringRef
 that contains an account name. (Items of class
 kSecClassGenericPassword, kSecClassInternetPassword have this
 attribute.)
 
 @constant kSecAttrService Specifies a dictionary key whose value is the
 item's service attribute. You use this key to set or get a CFStringRef
 that represents the service associated with this item. (Items of class
 kSecClassGenericPassword have this attribute.)
 
 @constant kSecAttrGeneric Specifies a dictionary key whose value is the
 item's generic attribute. You use this key to set or get a value of
 CFDataRef that contains a user-defined attribute. (Items of class
 kSecClassGenericPassword have this attribute.)
 */
