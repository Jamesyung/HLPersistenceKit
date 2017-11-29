//
//  HLPersistenceConfiguration.m
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import "HLPersistenceConfiguration.h"
#import "HLPersistenceBaseConfigurationItem.h"
#import "HLPersistenceFileConfigurationItem.h"

@interface HLPersistenceConfiguration ()

@property (nonatomic, copy) NSMutableDictionary *configurationItems;

@end

@implementation HLPersistenceConfiguration

- (id)copyWithZone:(nullable NSZone *)zone {
    
    HLPersistenceConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.configurationItems = [self.configurationItems mutableCopyWithZone:zone];
    
    return configuration;
}

- (NSMutableDictionary *)configurationItems {
    if (_configurationItems == nil) {
        _configurationItems = [NSMutableDictionary dictionary];
    }
    return _configurationItems;
}

- (void)addItems:(NSDictionary<NSString *, HLPersistenceBaseConfigurationItem *> *)items {
    [self.configurationItems setDictionary:items];
}

- (HLPersistenceBaseConfigurationItem *)findConfigurationItem:(NSString *)persistenceKey {
    return [self.configurationItems objectForKey:persistenceKey];
}

@end

@implementation NSArray (ConvertToHLPersistenceConfiguration)

- (HLPersistenceConfiguration *)convertToHLPConfiguration {
    
    NSMutableDictionary *generateItems = [NSMutableDictionary dictionary];
    for (NSDictionary *oneItem in self) {
        if (![oneItem objectForKey:@"persistenceType"]
            || ![oneItem objectForKey:@"persistenceKey"]) {
            continue;
        }
        
        HLPersistenceType oneItemType = [[oneItem objectForKey:@"persistenceType"] integerValue];
        NSString *persistenceKey = [oneItem objectForKey:@"persistenceKey"];
        switch (oneItemType) {
            case HLPersistenceTypeFile:{
                HLPersistenceFileConfigurationItem *newItem = [HLPersistenceFileConfigurationItem new];
                newItem.persistenceKey = persistenceKey;
                newItem.persistenceType = oneItemType;
                newItem.fileName = [oneItem objectForKey:@"fileName"];
                newItem.filePosition = [oneItem objectForKey:@"filePosition"];
                [generateItems setObject:newItem forKey:persistenceKey];
            }
                break;
            case HLPersistenceTypeUserDefaults: {
                HLPersistenceBaseConfigurationItem *newItem = [HLPersistenceBaseConfigurationItem new];
                newItem.persistenceKey = persistenceKey;
                newItem.persistenceType = oneItemType;
                [generateItems setObject:newItem forKey:persistenceKey];
            }
                break;
            default:
                break;
        }
    }
    
    HLPersistenceConfiguration *generateConfiguration = [HLPersistenceConfiguration new];
    [generateConfiguration addItems:generateItems];
    return generateConfiguration;
}

@end

@implementation HLPersistenceConfiguration (ConvertToNSDictionary)

- (NSArray *)convertToArray {
    
    NSMutableArray *generateArray = [NSMutableArray array];
    for (HLPersistenceBaseConfigurationItem *item in self.configurationItems.allValues) {
        switch (item.persistenceType) {
            case HLPersistenceTypeUserDefaults: {
                NSDictionary *object = @{@"persistenceKey":(item.persistenceKey?item.persistenceKey:@""),
                                         @"persistenceKey":@(item.persistenceType)};
                [generateArray addObject:object];
            }
                break;
            case HLPersistenceTypeFile: {
                HLPersistenceFileConfigurationItem *fileItem = (HLPersistenceFileConfigurationItem *)item;
                NSDictionary *object = @{@"persistenceKey":(fileItem.persistenceKey?fileItem.persistenceKey:@""),
                                         @"persistenceKey":@(fileItem.persistenceType),
                                         @"fileName":(fileItem.fileName?fileItem.fileName:@""),
                                         @"filePosition":(fileItem.filePosition?fileItem.filePosition:@"")
                                         };
                [generateArray addObject:object];
            }
                break;
            default:
                break;
        }
    }
    
    return generateArray;
}

@end
