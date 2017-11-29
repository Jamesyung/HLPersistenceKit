//
//  HLPersistenceManager.m
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import "HLPersistenceManager.h"
#import "HLPersistenceConfiguration.h"
#import "HLPersistenceBaseConfigurationItem.h"
#import <objc/runtime.h>

//_________________________________________________________________________________________________________

//dynamic generate cache key based on persistence type
static char HLPFileCacheKey;
static char HLPUserDefaultsCacheKey;
static char HLPUnknownCacheKey;
static const char * HLPCacheKeyForType(HLPersistenceType persistenceType) {
    switch (persistenceType) {
        case HLPersistenceTypeFile:
            return &HLPFileCacheKey;
        case HLPersistenceTypeUserDefaults:
            return &HLPUserDefaultsCacheKey;
        default:
            return &HLPUnknownCacheKey;
    }
}

//_________________________________________________________________________________________________________

@interface HLPersistenceManager ()

@property (nonatomic, copy) HLPersistenceConfiguration *codeConfiguration;  //load configuration from code
@property (nonatomic, copy) HLPersistenceConfiguration *GUIConfiguration;   //load configuration from GUI

@end

@implementation HLPersistenceManager

#pragma mark OpenAPI

- (nullable id)objectForKey:(nonnull NSString *)persistenceKey {
    
    //1.query persistenceKey exists in configuration
    //2.read object based on key configuration info
    //2-1.read object from cache
    //2-2.cache is nil, read from disk, and save to cache
    
    HLPersistenceBaseConfigurationItem *findItem = [self findConfigurationItemUnderCurrentOption:persistenceKey];
    if (!findItem) {
        NSLog(@"get object failed, because persistence key:%@ is not registered in configuration",persistenceKey);
        return nil;
    }
    
    id findObject = nil;
    
    {
        findObject = [self findObjectInCacheForItem:findItem];
        if (findObject) {
            NSLog(@"get object success in cache, persistence key:%@",persistenceKey);
            return findObject;
        }
    }
    
    {
        findObject = [self findObjectInDiskForItem:findItem];
        if (findObject) {
            NSLog(@"get object success in disk, persistence key:%@",persistenceKey);
            return findObject;
        }
    }
    
    return findObject;
}

- (void)setObject:(nonnull id)object forKey:(nonnull NSString *)persistenceKey {
    
    //1.query persistenceKey exists in configuration
    //2.save object based on key configuration info
    //2-1.firstly, save object to disk
    //2-2.if save to disk success, then save it to cache
    
    HLPersistenceBaseConfigurationItem *findItem = [self findConfigurationItemUnderCurrentOption:persistenceKey];
    if (!findItem) {
        NSLog(@"set object failed, because persistence key:%@ is not registered in configuration",persistenceKey);
        return;
    }
    
    BOOL saveToDiskResult = [self saveObjectToDisk:object forItem:findItem];
    if (saveToDiskResult) {
        [self saveObjectToCache:object forItem:findItem];
    }
    else {
        NSLog(@"set object failed, because save it to disk failed and also not save it to cache");
    }
}

- (void)removeObjectForKey:(nonnull NSString *)persistenceKey {
    
    HLPersistenceBaseConfigurationItem *findItem = [self findConfigurationItemUnderCurrentOption:persistenceKey];
    if (!findItem) {
        NSLog(@"set object failed, because persistence key:%@ is not registered in configuration",persistenceKey);
        return;
    }
    
    [self removeObjectInDiskForItem:findItem];
    [self removeObjectInCacheForItem:findItem];
}

#pragma mark Property

+ (HLPersistenceManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    static HLPersistenceManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[HLPersistenceManager alloc] initManager];
    });
    
    return manager;
}

- (HLPersistenceConfiguration *)codeConfiguration {
    
    if (_codeConfiguration == nil) {
        
        if (!self.delegate || ![self.delegate respondsToSelector:@selector(configuredInstance)]
            || ![self.delegate configuredInstance]) {
            return nil;
        }
        
        _codeConfiguration = [[self.delegate configuredInstance] copy];
    }
    
    return _codeConfiguration;
}

- (HLPersistenceConfiguration *)GUIConfiguration {
    
    if (_GUIConfiguration == nil) {
        
        if (!self.delegate || ![self.delegate respondsToSelector:@selector(pathForVisualizationFile)]
            || [[self.delegate pathForVisualizationFile] length] == 0) {
            return nil;
        }
        
        NSString *plistPath = [self.delegate pathForVisualizationFile];
        NSArray *configPlist = [NSArray arrayWithContentsOfFile:plistPath];
        
        _GUIConfiguration = [[configPlist convertToHLPConfiguration] copy];
    }
    
    return _GUIConfiguration;
}

- (NSMutableDictionary *)cacheForType:(HLPersistenceType)type {
    
    NSMutableDictionary *cache = objc_getAssociatedObject(self, HLPCacheKeyForType(type));
    
    if (cache == nil) {
        cache = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, HLPCacheKeyForType(type), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return cache;
}

#pragma mark LifeCircle

- (instancetype)initManager {
    
    if (self = [super init]) {
        self.configurationOption = HLPersistenceOptionAll;
    }
    
    return self;
}

#pragma mark PrivateMethods

//find item in configuration which is decided by current HLPersistenceOption
- (HLPersistenceBaseConfigurationItem *)findConfigurationItemUnderCurrentOption:(NSString *)persistenceKey {
    
    HLPersistenceBaseConfigurationItem *findItem = nil;
    
    if (self.configurationOption&HLPersistenceOptionAll
        || self.configurationOption&HLPersistenceOptionCode) {
        
        findItem = [self.codeConfiguration findConfigurationItem:persistenceKey];
    }
    
    if (findItem) {
        return findItem;
    }
    
    if (self.configurationOption&HLPersistenceOptionAll
        || self.configurationOption&HLPersistenceOptionGUI) {
        
        findItem = [self.GUIConfiguration findConfigurationItem:persistenceKey];
    }
    
    return findItem;
}

- (id)findObjectInCacheForItem:(HLPersistenceBaseConfigurationItem *)item {
    
    if (item == nil) {
        return nil;
    }
    
    @synchronized(self) {
        NSMutableDictionary *cache = [self cacheForType:item.persistenceType];
        return [cache objectForKey:item.persistenceKey];
    }
}

- (void)saveObjectToCache:(id)object forItem:(HLPersistenceBaseConfigurationItem *)item {
    
    if (object == nil || item == nil) {
        return;
    }
    
    @synchronized(self) {
        NSMutableDictionary *cache = [self cacheForType:item.persistenceType];
        [cache setObject:object forKey:item.persistenceKey];
    }
}

- (void)removeObjectInCacheForItem:(HLPersistenceBaseConfigurationItem *)item {
    
    if (item == nil) {
        return;
    }
    
    @synchronized(self) {
        NSMutableDictionary *cache = [self cacheForType:item.persistenceType];
        [cache removeObjectForKey:item.persistenceKey];
    }
}

//find object in disk
//based on policy, if the object is not nil, save it to cache
- (id)findObjectInDiskForItem:(HLPersistenceBaseConfigurationItem *)item {
    
    id findObject = nil;
    
    switch (item.persistenceType) {
        case HLPersistenceTypeFile: {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
            if ([item respondsToSelector:@selector(fileAbsolutePosition)]
                && [item respondsToSelector:@selector(fileName)]) {
                
                NSString *fileAbsolutePosition = [item performSelector:@selector(fileAbsolutePosition)];
                NSString *fileName = [item performSelector:@selector(fileName)];
                NSString *path = [fileAbsolutePosition stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                findObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            }
#pragma clang diagnostic pop
            
        }
            break;
        case HLPersistenceTypeUserDefaults: {
            findObject = [[NSUserDefaults standardUserDefaults] objectForKey:item.persistenceKey];
        }
            break;
        default:
            break;
    }
    
    if (findObject) {
        [self saveObjectToCache:findObject forItem:item];
    }
    
    return findObject;
}

- (BOOL)saveObjectToDisk:(id)object forItem:(HLPersistenceBaseConfigurationItem *)item {
    
    switch (item.persistenceType) {
        case HLPersistenceTypeFile: {
            
            if (![object respondsToSelector:@selector(encodeWithCoder:)]) {
                NSLog(@"object not complement NSCoding");
                return NO;
            }

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
            if ([item respondsToSelector:@selector(fileAbsolutePosition)]
                && [item respondsToSelector:@selector(fileName)]) {
                NSString *fileAbsolutePosition = [item performSelector:@selector(fileAbsolutePosition)];
                NSString *fileName = [item performSelector:@selector(fileName)];
                
                //createDirectoryIfNeed
                {
                    BOOL isDirectory = NO;
                    BOOL isDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:fileAbsolutePosition isDirectory:&isDirectory];
                    if (!isDirectoryExists || !isDirectory) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:fileAbsolutePosition withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                }
                
                NSString *path = [fileAbsolutePosition stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                return [NSKeyedArchiver archiveRootObject:object toFile:path];
            }
#pragma clang diagnostic pop
            
        }
            break;
        case HLPersistenceTypeUserDefaults: {
            
            //exception:UIView
            [[NSUserDefaults standardUserDefaults] setObject:object forKey:item.persistenceKey];
            return YES;
        }
            break;
        default:
            break;
    }
    
    return NO;
}

- (void)removeObjectInDiskForItem:(HLPersistenceBaseConfigurationItem *)item {
    
    switch (item.persistenceType) {
        case HLPersistenceTypeFile: {

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
            if ([item respondsToSelector:@selector(fileAbsolutePosition)]
                && [item respondsToSelector:@selector(fileName)]) {
                NSString *fileAbsolutePosition = [item performSelector:@selector(fileAbsolutePosition)];
                NSString *fileName = [item performSelector:@selector(fileName)];
                
                NSString *path = [fileAbsolutePosition stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                NSError *error;
                if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error] == NO) {
                    NSLog(@"Unable to delete path:%@ error: %@",path, [error localizedDescription]);
                }
            }
#pragma clang diagnostic pop
            
        }
            break;
        case HLPersistenceTypeUserDefaults: {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:item.persistenceKey];
        }
            break;
        default:
            break;
    }
}

@end
