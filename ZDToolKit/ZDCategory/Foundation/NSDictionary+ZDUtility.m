//
//  NSDictionary+ZDUtility.m
//  Pods
//
//  Created by Zero on 2017/5/20.
//
//

#import "NSDictionary+ZDUtility.h"
#import <Security/Security.h>

@implementation NSDictionary (ZDUtility)

// ref: http://stackoverflow.com/questions/9948698/store-nsdictionary-in-keychain
- (void)storeToKeychainWithKey:(NSString *)aKey {
    // serialize dict
    NSString *error;
    NSData *serializedDictionary = [NSPropertyListSerialization dataFromPropertyList:self format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    // encrypt in keychain
    if(!error) {
        // first, delete potential existing entries with this key (it won't auto update)
        [self deleteFromKeychainWithKey:aKey];
        
        // setup keychain storage properties
        NSDictionary *storageQuery = @{
                                       (id)kSecAttrAccount:    aKey,
                                       (id)kSecValueData:      serializedDictionary,
                                       (id)kSecClass:          (id)kSecClassGenericPassword,
                                       (id)kSecAttrAccessible: (id)kSecAttrAccessibleWhenUnlocked
                                       };
        OSStatus osStatus = SecItemAdd((CFDictionaryRef)storageQuery, nil);
        if(osStatus != noErr) {
            // do someting with error
        }
    }
}

+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)aKey {
    // setup keychain query properties
    NSDictionary *readQuery = @{
                                (id)kSecAttrAccount: aKey,
                                (id)kSecReturnData: (id)kCFBooleanTrue,
                                (id)kSecClass:      (id)kSecClassGenericPassword
                                };
    
    CFTypeRef serializedDictionary = NULL;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)readQuery, &serializedDictionary);
    if(osStatus == noErr) {
        // deserialize dictionary
        NSString *error;
        NSDictionary *storedDictionary = [NSPropertyListSerialization propertyListFromData:(__bridge NSData *)(serializedDictionary) mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&error];
        if (error) NSLog(@"%@", error);
        return storedDictionary;
    }
    else {
        // do something with error
        return nil;
    }
}

- (void)deleteFromKeychainWithKey:(NSString *)aKey {
    // setup keychain query properties
    NSDictionary *deletableItemsQuery = @{
                                          (id)kSecAttrAccount:        aKey,
                                          (id)kSecClass:              (id)kSecClassGenericPassword,
                                          (id)kSecMatchLimit:         (id)kSecMatchLimitAll,
                                          (id)kSecReturnAttributes:   (id)kCFBooleanTrue
                                          };
    
    CFArrayRef itemList = NULL;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)deletableItemsQuery, (CFTypeRef *)&itemList);
    // each item in the array is a dictionary
    NSArray *itemListArray = (__bridge NSArray *)itemList;
    for (NSDictionary *item in itemListArray) {
        NSMutableDictionary *deleteQuery = [item mutableCopy];
        [deleteQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        // do delete
        osStatus = SecItemDelete((CFDictionaryRef)deleteQuery);
        if(osStatus != noErr) {
            // do something with error
        }
    }
}

@end
