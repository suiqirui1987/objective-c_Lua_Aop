# objective-c_Lua_Aop

1.complie LuaJIT-2.1.0-beta3

sh LuaJit-ios.sh


2.run dm_ios_sdk_demo

  lua_class = [[DMLuaClass alloc] initWithClassName:@"ViewController"];
        [lua_class aspect:self];
