//
//  HLPersistenceDefine.h
//  HLPersistenceKit
//
//  Created by yanglihua on 2017/11/27.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#ifndef HLPersistenceDefine_h
#define HLPersistenceDefine_h

/**
 Supported Configuration Option
 
 - HLPersistenceOptionAll:  support all options
 - HLPersistenceOptionCode: implement the specific method
 - HLPersistenceOptionGUI: plist file
 */
typedef NS_OPTIONS(NSUInteger, HLPersistenceOption) {
    HLPersistenceOptionAll = 1 << 0,
    HLPersistenceOptionCode = 1 << 1,
    HLPersistenceOptionGUI = 1 << 2,
};

/**
 Supported Persistence Type

 - HLPersistenceTypeUserDefaults: NSUserDefaults
 - HLPersistenceTypeFile: achived file
 */
typedef NS_ENUM(NSUInteger, HLPersistenceType) {
    HLPersistenceTypeUserDefaults,
    HLPersistenceTypeFile,
};

#endif /* HLPersistenceDefine_h */
