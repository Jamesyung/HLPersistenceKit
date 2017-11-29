//
//  HLPersistenceBaseConfigurationItem.h
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPersistenceDefine.h"

@interface HLPersistenceBaseConfigurationItem : NSObject

@property (nonatomic, copy) NSString *persistenceKey;   //global unique key
@property (nonatomic, assign) HLPersistenceType persistenceType;    //belong to which persistence type

@end
