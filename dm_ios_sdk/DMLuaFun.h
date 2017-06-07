//
//  DMLuaFun.h
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DMLuaCore.h"


void luabridge_push_object(lua_State *L, id obj);


int luafunc_newstack(lua_State *L);
int luafunc_push(lua_State *L);
int luafunc_pop(lua_State *L);
int luafunc_clear(lua_State *L);
int luafunc_operate(lua_State *L);
int luafunc_getclass(lua_State *L);
int luafunc_extract(lua_State *L);

