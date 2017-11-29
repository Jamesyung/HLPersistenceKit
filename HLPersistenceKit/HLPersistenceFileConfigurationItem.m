//
//  HLPersistenceFileConfigurationItem.m
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/28.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import "HLPersistenceFileConfigurationItem.h"

@implementation HLPersistenceFileConfigurationItem

- (NSString *)fileAbsolutePosition {
    
    if ([_filePosition length] == 0) {
        return @"";
    }
    
    NSMutableString *handledPosition = [NSMutableString stringWithString:_filePosition];
    while ([handledPosition length] > 0 && [handledPosition hasPrefix:@"/"]) {
        [handledPosition deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:handledPosition];
}

@end
