//
//  DMLuaCore.h
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#ifndef DMLuaCore_h
#define DMLuaCore_h


#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luajit.h"


#define LUA_ADDMETHOD(name) \
(lua_pushstring(L, #name), \
lua_pushcfunction(L, luafunc_ ## name), \
lua_settable(L, -3))


//全局引用
static int gc_metatable_ref=0;




#endif /* DMLuaCore_h */
