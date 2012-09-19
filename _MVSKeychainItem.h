//
//  MVSKeychainItem.h
//  MVSKeychain Demo
//
//  Created by Mario Sepulveda on 9/6/12.
//  Copyright (c) 2012 Geekonastick LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVSKeychain.h"
#import "MVSKeychainQuery.h"

extern NSString *const kMVSKeychainItemErrorDomain;


@interface _MVSKeychainItem : NSObject <MVSKeychainItemProtocol>

// PROPERTIES
@property (nonatomic) MVSKeychainQuery *queries;
@property (nonatomic) NSDictionary *keychainAttributes;
@property BOOL shouldLogActions;

// ATTRIBUTES
@property (readonly) MVSKeychainClass keychainClass;
@property (nonatomic) NSString *accessible;
@property (nonatomic) NSString *accessGroup;
@property (nonatomic) NSString *label;

// GENERIC ATTRIBUTE ACCESS
- (id)objectForKey:(id)key;
- (BOOL)boolForKey:(id)theKey;

// CONSTRUCTOR
- (id)initWithLabel:(NSString*)theLabel;
- (id)initWithLabel:(NSString*)theLabel
        accessGroup:(NSString*)theAccessGroup;
- (id)initWithAttributes:(NSDictionary*)theAttributes;

// ACTIONS
- (BOOL)deleteWithError:(NSError **)theError;
- (BOOL)saveWithError:(NSError **)theError;

// QUERY ACTIONS
- (BOOL)successfullyQueriedForKeychainItemWithError:(NSError**)theError;

@end



/*
 @constant kSecAttrAccessible Specifies a dictionary key whose value
 indicates when your application needs access to an items data.  You
 should choose the most restrictive option that meets your applications
 needs to allow the system to protect that item in the best way
 possible.
 */

/*!
 @enum kSecAttrAccessible Value Constants
 
 @discussion Predefined item attribute constants used to get or set values
 in a dictionary. The kSecAttrAccessible constant is the key and its
 value is one of the constants defined here.
 When ask SecItemCopyMatching to return the items data the error
 errSecInteractionNotAllowed will be returned if the items data is not
 available until a device unlock occurs.
 
 @constant kSecAttrAccessibleWhenUnlocked item's data can only be accessed
 while the device is unlocked. This is recommended for items that only
 need be accesible while the application is in the foreground.  Items
 with this attribute will migrate to a new device when using encrypted
 backups.
 
 @constant kSecAttrAccessibleAfterFirstUnlock item's data can only be
 accessed once the device has been unlocked after a restart.  This is
 recommended for items that need to be accesible by background
 applications. Items with this attribute will migrate to a new device
 when using encrypted backups.
 
 @constant kSecAttrAccessibleAlways item's data can always be accessed
 regardless of the lock state of the device.  This is not recommended
 for anything except system use. Items with this attribute will migrate
 to a new device when using encrypted backups.
 
 @constant kSecAttrAccessibleWhenUnlockedThisDeviceOnly item's data can only
 be accessed while the device is unlocked. This is recommended for items
 that only need be accesible while the application is in the foreground.
 Items with this attribute will never migrate to a new device, so after
 a backup is restored to a new device these items will be missing.
 
 @constant kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly item's data can
 only be accessed once the device has been unlocked after a restart.
 This is recommended for items that need to be accessible by background
 applications. Items with this attribute will never migrate to a new
 device, so after a backup is restored to a new device these items will
 be missing.
 
 @constant kSecAttrAccessibleAlwaysThisDeviceOnly item's data can
 always be accessed regardless of the lock state of the device.  This
 is not recommended for anything except system use. Items with this
 attribute will never migrate to a new device, so after a backup is
 restored to a new device these items will be missing.
 */


/*
 @constant kSecAttrAccessible Specifies a dictionary key whose value
 indicates when your application needs access to an items data.  You
 should choose the most restrictive option that meets your applications
 needs to allow the system to protect that item in the best way
 possible.
 
 @constant kSecAttrAccessGroup Specifies a dictionary key whose value is
 a CFStringRef indicating which access group an item is in.  The access
 groups that a particular application has access to are determined by
 two entitlements for that application.  The application-identifier
 entitlement contains the applications single access group, unless
 there is a keychain-access-groups entitlement present.  The latter
 has as its value a list of access groups.   The first (or only)
 access group an application is in is the default one new items are
 created in.  By default SecItemCopyMatching searches all the access
 groups an item is a member of.  Specifying this attribute to
 SecItemAdd, changes the access group an item will be added to, or
 limits which access groups are searched for SecItemUpdate,
 SecItemDelete or SecItemCopyMatching calls.  To share keychain items
 between multiple applications they need to have a common group listed
 in their keychain-access-groups entitlement, and they must both specify
 this shared access group name as the value for this key in the
 dictionary passed to SecItemAdd().
 
 @constant kSecAttrCreationDate (read-only) Specifies a dictionary key whose
 value is the item's creation date. You use this key to get a value
 of type CFDateRef that represents the date the item was created.
 
 @constant kSecAttrModificationDate (read-only) Specifies a dictionary key
 whose value is the item's modification date. You use this key to get
 a value of type CFDateRef that represents the last time the item was
 updated.
 
 @constant kSecAttrDescription Specifies a dictionary key whose value is
 the item's description attribute. You use this key to set or get a
 value of type CFStringRef that represents a user-visible string
 describing this particular kind of item (e.g., "disk image password").
 
 @constant kSecAttrComment Specifies a dictionary key whose value is the
 item's comment attribute. You use this key to set or get a value of
 type CFStringRef containing the user-editable comment for this item.
 
 @constant kSecAttrCreator Specifies a dictionary key whose value is the
 item's creator attribute. You use this key to set or get a value of
 type CFNumberRef that represents the item's creator. This number is
 the unsigned integer representation of a four-character code (e.g.,
 'aCrt').
 
 @constant kSecAttrType Specifies a dictionary key whose value is the item's
 type attribute. You use this key to set or get a value of type
 CFNumberRef that represents the item's type. This number is the
 unsigned integer representation of a four-character code (e.g.,
 'aTyp').
 
 @constant kSecAttrLabel Specifies a dictionary key whose value is the
 item's label attribute. You use this key to set or get a value of
 type CFStringRef containing the user-visible label for this item.
 
 @constant kSecAttrIsInvisible Specifies a dictionary key whose value is the
 item's invisible attribute. You use this key to set or get a value
 of type CFBooleanRef that indicates whether the item is invisible
 (i.e., should not be displayed.)
 
 @constant kSecAttrIsNegative Specifies a dictionary key whose value is the
 item's negative attribute. You use this key to set or get a value of
 type CFBooleanRef that indicates whether there is a valid password
 associated with this keychain item. This is useful if your application
 doesn't want a password for some particular service to be stored in
 the keychain, but prefers that it always be entered by the user.
 */

/*
 Item Class Value Constants
 
 Values used with the kSecClass key in a search dictionary.
 
 CFTypeRef kSecClassGenericPassword;
 CFTypeRef kSecClassInternetPassword;
 CFTypeRef kSecClassCertificate;
 CFTypeRef kSecClassKey;
 CFTypeRef kSecClassIdentity;
 */