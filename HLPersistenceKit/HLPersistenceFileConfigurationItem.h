//
//  HLPersistenceFileConfigurationItem.h
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/28.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import "HLPersistenceBaseConfigurationItem.h"

@interface HLPersistenceFileConfigurationItem : HLPersistenceBaseConfigurationItem

@property (nonatomic, copy) NSString *fileName; //file name
@property (nonatomic, copy, getter=fileAbsolutePosition) NSString *filePosition; //position which file locates in

@end
