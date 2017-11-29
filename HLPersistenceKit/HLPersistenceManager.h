//
//  HLPersistenceManager.h
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPersistenceDefine.h"

//_______________________________________________________________________________________________________________

#pragma mark Configuration delegate
@class HLPersistenceConfiguration;

@protocol HLPersistenceConfigurationDelegate <NSObject>

@optional

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Under the option HLPersistenceOptionGUI
//if not complement or return invalid value, this option HLPersistenceOptionGUI can not be supported
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 offer the path of visualization file
 
 @return path of visualization file, now just support plist
 */
- (nonnull NSString *)pathForVisualizationFile;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Under the option HLPersistenceOptionCode
//if not complement or return invalid value, the option HLPersistenceOptionCode can not be supported
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 offer configured instance of HLPersistenceConfiguration
 
 @return instance of HLPersistenceConfiguration
 */
- (nonnull HLPersistenceConfiguration *)configuredInstance;

@end

//_______________________________________________________________________________________________________________

#pragma mark Persistence Manager
@interface HLPersistenceManager : NSObject

@property (nonnull, class, strong, readonly) HLPersistenceManager *sharedManager; //single instance, -init will be invalid
@property (nullable, nonatomic, weak) id<HLPersistenceConfigurationDelegate> delegate; //configuration delegate, option of Code or GUI need to implement
@property (nonatomic, assign) HLPersistenceOption configurationOption; //supported options

/**
 obtain the stored object
 firstly obtain from cache, if not in cache, will get it from disk and save it to cache

 @param persistenceKey :global unique key, the key need to be configured previously
 @return stored object
 */
- (nullable id)objectForKey:(nonnull NSString *)persistenceKey;

/**
 store object for key
 firstly compare difference, then save it to both cache and disk
 if save to disk failed, then cache save operate will not succeed also
 */
- (void)setObject:(nonnull id)object forKey:(nonnull NSString *)persistenceKey;

/**
 remove object from both cache and disk
 */
- (void)removeObjectForKey:(nonnull NSString *)persistenceKey;

@end
