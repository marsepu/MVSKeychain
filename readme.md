author: Mario Sepulveda (marsepu@gmail.com)
date: 2012-SEP-19

# MVSKeychain 

This is a set of Objective-C classes that provide a basic wrapper around the Apple provided generic password keychain service. After you have added MVSKeychain classes to your project you can:

+ Add new passwords to the keychain.
+ Query for passwords your application has stored in the keychain.
+ Modify your application's passwords.
+ Delete passwords from the keychain.

*NOTE: The simulator does not allow for **access group entitlements**, so, MVSKeychain will remove the **access group** attribute as needed.*

## REQUIREMENTS

1. ARC
2. Security.framework


## TODOS
+ UNIT TEST
+ implement query return type kSecReturnRef 
+ implement query return type kSecReturnPersistentRef
+ implement class for kSecClassInternetPassword
+ implement class for kSecClassCertificate
+ implement class for kSecClassKey
+ implement class for kSecClassIdentity

## KEYCHAIN TUTORIAL

If you don't want to use the MVSKeychain classes here are some basic code listing to help you navigate the generic password keychain.

Adding to the keychain via the **SecItemAdd** method:

	#import <Security/Security.h>

	// 1. CREATE A DICTIONARY OF ATTRIBUTES.
	NSMutableDictionary *localAttributes = [NSMutableDictionary dictionary];
	[localAttributes setObject:@"Password Example" forKey:(__bridge id)kSecAttrLabel];
	[localAttributes setObject:@"com.access.group.information" forKey:(__bridge id)kSecAttrAccessGroup];
	[localAttributes setObject:@"account@example.com" forKey:(__bridge id)kSecAttrAccount];
	[localAttributes setObject:@"example.com" forKey:(__bridge id)kSecAttrService]
	
	// 2. ADD *kSecAttrGeneric* AND *kSecValueData* ATTRIBUTES AS NSDATA OBJECTS
	[localAttributes setObject:[@"notes and other generic data" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric]
	[localAttributes setObject:[@"PASSWORD" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
	
	// 3. SPECIFY THE KEYCHAIN *kSecClass* ATTRIBUTE.
	[localAttributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// 4. GOTCHA! YOU CANNOT SPECIFY THE *kSecAttrAccessGroup* ATTRIBUTE IN THE SIMULATOR.
	#if TARGET_IPHONE_SIMULATOR
	[localAttributes removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
	#endif
	 
	// 5. EXECUTE.
	OSStatus result = SecItemAdd((__bridge CFDictionaryRef)localAttributes, NULL);
	
	// 6. CHECK FOR AN ERROR
	if (result != noErr) {
	  NSLog(@"error encounterred: %d", status);
	} else if (status == noErr) {
	  NSLog(@"success");
	}


Perform a basic password query via the **SecItemCopyMatching** method:

	#import <Security/Security.h>
	
	// 1. CREATE A DICTIONARY OF ATTRIBUTES TO SEARCH FOR.
	NSMutableDictionary *attributesToQueryFor = [NSMutableDictionary dictionary];
	[attributesToQueryFor setObject:@"Password Example" forKey:(__bridge id)kSecAttrLabel];
	[attributesToQueryFor setObject:@"com.access.group.information" forKey:(__bridge id)kSecAttrAccessGroup];
	[attributesToQueryFor setObject:@"account@example.com" forKey:(__bridge id)kSecAttrAccount];
	
	// 2. *kSecClass* ATTRIBUTE. (other options include: kSecClassInternetPassword, kSecClassCertificate, kSecClassKey and kSecClassIdentity)
	[attributesToQueryFor setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// 3. *kSecMatchLimit* ATTRIBUTE. (how many results)
	[attributesToQueryFor setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	
	// 4. YOU WANT THE PASSWORD DATA ONLY. (alternatively you can specify all-other-attributes, a temporary reference, or a permanent reference) 
	[attributesToQueryFor setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	/* IF YOU WANT THE ATTRIBUTES INSTEAD OF THE PASSWORD USE
	[attributesToQueryFor setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
	*/
	
	// 5. GOTCHA! YOU CANNOT SPECIFY THE *kSecAttrAccessGroup* ATTRIBUTE IN THE SIMULATOR.
	#if TARGET_IPHONE_SIMULATOR
	[attributesToQueryFor removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
	#endif
	
	// 6. EXECUTE.	
	OSStatus status = noErr;
	CFTypeRef resultRef = NULL;
	status = SecItemCopyMatching((__bridge CFDictionaryRef)attributesToQueryFor, &resultRef);
	
	// 7. CHECK FOR AN ERROR.
	if (status != noErr) {
	  NSLog(@"error encounterred: %d", status);
	}
	
	// 8. CHECK THE RESULT, SWITCH TO AN *NSData* OBJECT.
	if (resultRef) {
	  NSData *result = (__bridge_transfer NSData *)resultRef;
	  
	  /* IF YOU WANT THE ATTRIBUTES INSTEAD OF THE PASSWORD USE
	  NSDictionary *results = (__bridge_transfer NSDictionary *)resultRef;
	  */
	}
	

Deleting an keychain item via the **SecItemDelete** method:

	
	#import <Security/Security.h>
	
	// 1. SPECIFY YOU ATTRIBUTES TO SEARCH FOR.
	NSMutableDictionary *localQuery = … ; // SEE SecItemCopyMatching EXAMPLE
	
	// 2. DO NOT SPECIFY A *kSecMatchLimit* ATTRIBUTE
	[localQuery removeObjectForKey:(__bridge id)kSecMatchLimit];
	 
	// 3. GOTCHA! YOU CANNOT SPECIFY THE *kSecAttrAccessGroup* ATTRIBUTE IN THE SIMULATOR.
	#if TARGET_IPHONE_SIMULATOR
	[localQuery removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
	#endif
	 	
	// 4. EXECUTE
	OSStatus status = noErr;
	status = SecItemDelete((__bridge CFDictionaryRef)localQuery);
	
	// 5. CHECK FOR AN ERROR
	if (result != noErr) {
	  NSLog(@"error encounterred: %d", status);
	} else if (status == noErr) {
	  NSLog(@"success");
	}
	

Updating a keychain password via the **SecItemUpdate** method:

	#import <Security/Security.h>
	
	// 1. SPECIFY YOU ATTRIBUTES TO SEARCH FOR.
	NSMutableDictionary *localQuery = … ; // SEE SecItemCopyMatching EXAMPLE
	
	// 2. DO NOT SPECIFY A *kSecMatchLimit* ATTRIBUTE
	[localQuery removeObjectForKey:(__bridge id)kSecMatchLimit];
	 
	// 3. GOTCHA! YOU CANNOT SPECIFY THE *kSecAttrAccessGroup* ATTRIBUTE IN THE SIMULATOR.
	#if TARGET_IPHONE_SIMULATOR
	[localQuery removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
	#endif
	
	// 4. SPECIFY WHICH ATTRIBUTES YOU WANT TO MODIFIED
	NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionary];
	[modifiedAttributes setObject:[@"NEW PASSWORD" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
	
	// 4. EXECUTE
	OSStatus status = noErr;
	status = SecItemUpdate((__bridge CFDictionaryRef)localQuery, (__bridge CFDictionaryRef)modifiedAttributes);
	
	// 5. CHECK FOR AN ERROR
	if (result != noErr) {
	  NSLog(@"error encounterred: %d", status);
	} else if (status == noErr) {
	  NSLog(@"success");
	}

## MVSKEYCHAIN USAGE

If you already understand the dictionary keys that Apple specified you can use **procedural** style.
	
	
	#import "MVSKeychain.h"
	#import "MVSKeychainQuery.h"

	NSMutableDictionary *tempAttributes = [NSMutableDictionary dictionary];
	[tempAttributes setObject:@"Password Example" forKey:(__bridge id)kSecAttrLabel];
	[tempAttributes setObject:@"com.access.group.information" forKey:(__bridge id)kSecAttrAccessGroup];
	[tempAttributes setObject:@"account@example.com" forKey:(__bridge id)kSecAttrAccount];

	MVSKeychainQuery *testQuery = [MVSKeychainQuery queryFromAttributes:tempAttributes matchLimit:kMATCH_ONE keychainClass:kGENERIC_PASSWORD returnType:kRETURN_DATA];
	
	NSError *myError = nil;	
	NSData *passwordData = [MVSKeychain dataForQuery:testQuery error:&myError];
	
	if (myError) {
	  NSLog(@"ERROR: %@", myError);
	}
	
	if (passwordData) {	
	  NSLog(@"passwordData: %@", passwordData);
	  NSLog(@"password as a string: %@", [[NSString alloc] initWithBytes:passwordData.bytes length:passwordData.length encoding:NSUTF8StringEncoding]);
	}


## MVSKeychainPassword USAGE 

### CREATING A NEW PASSWORD OBJECT

	
	#import "MVSKeychainPassword.h"
	
	NSError *testError;
	MVSKeychainPassword *passwordObject = [[MVSKeychainPassword alloc] initWithLabel:@"Login Password Example" accessGroup:@"com.access.group.information" account:@"account@example.com"];
	passwordObject.password = @"your actual password";
	passwordObject.generic = [@"notes and other generic data" dataUsingEncoding:NSUTF8StringEncoding];
	passwordObject.service = @"example.com"
	
    if ([newPassword saveWithError:&testError]) {
      NSLog(@"successfully wrote the password.");
    } else {
      NSLog(@"did not write the password! error: %@", testError);
    }
    
    
### SEARCHING FOR A PREVIOUSLY SAVED PASSWORD OBJECT

	#import "MVSKeychainPassword.h"
	
	MVSKeychainPassword *passwordObject = [MVSKeychainPassword passwordItemForLabel:@"Login Password Example" accessGroup:@"com.access.group.information" account:@"account@example.com"];
	if (!passwordObject) {
		NSLog(@"failed to find that password in the keychain!");
	} else {
		NSLog(@"passwordObject: %@", passwordObject);
	}

### UPDATING A PASSWORD OBJECT
		
	#import "MVSKeychainPassword.h"
	
	MVSKeychainPassword *passwordObject = [MVSKeychainPassword passwordItemForLabel:@"Login Password Example" accessGroup:@"com.access.group.information" account:@"account@example.com"];
	if (passwordObject) {
		passwordObject.password = @"your NEW password"
		
		NSError *testError;
		if ([passwordObject saveWithError:&testError]) {
		 	NSLog(@"successfully wrote the password.");
    	} else {
      		NSLog(@"did not write the password! error: %@", testError);
    	}
	}

### DELETING A PASSWORD OBJECT
	
	#import "MVSKeychainPassword.h"
	
	MVSKeychainPassword *passwordObject = [MVSKeychainPassword passwordItemForLabel:@"Login Password Example" accessGroup:@"com.access.group.information" account:@"account@example.com"];
	if (passwordObject) {
		NSError *testError;
		if ([passwordObject deleteWithError:nil:&testError]) {
		 	NSLog(@"DELETED the password from the keychain.");
    	} else {
      		NSLog(@"did not delete the password! error: %@", testError);
    	}
	}
