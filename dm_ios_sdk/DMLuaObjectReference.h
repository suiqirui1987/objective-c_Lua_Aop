//
//  DMLuaObjectReference.h
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DMLuaCore.h"

@interface DMLuaObjectReference : NSObject

@property int ref;
@property lua_State *L;

@end
