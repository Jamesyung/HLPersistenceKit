//
//  HLPersistenceConfiguration.h
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPersistenceDefine.h"

//_______________________________________________________________________________________________________________

#pragma mark Configuration class
@class HLPersistenceBaseConfigurationItem;

@interface HLPersistenceConfiguration : NSObject <NSCopying>

/**
 add configuration items

 @param items NSDictionary{PersistenceKey:item(maybe HLPersistenceBaseConfigurationItem/HLPersistenceFileConfigurationItem/and so)}
 */
- (void)addItems:(NSDictionary<NSString *, HLPersistenceBaseConfigurationItem *> *)items;

/**
 find item by persistenceKey

 @param persistenceKey global unique key
 @return item
 */
- (HLPersistenceBaseConfigurationItem *)findConfigurationItem:(NSString *)persistenceKey;

@end

//_______________________________________________________________________________________________________________

@interface NSArray (ConvertToHLPersistenceConfiguration)

- (HLPersistenceConfiguration *)convertToHLPConfiguration;

@end

//_______________________________________________________________________________________________________________

@interface HLPersistenceConfiguration (ConvertToNSDictionary)

- (NSArray *)convertToArray;

@end
