function debug.dump(obj)  
    local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj  
    getIndent = function(level)  
        return string.rep("\t", level)  
    end  
    quoteStr = function(str)  
        str = string.gsub(str, "[%c\\\"]", {  
            ["\t"] = "\\t",  
            ["\r"] = "\\r",  
            ["\n"] = "\\n",  
            ["\""] = "\\\"",  
            ["\\"] = "\\\\",  
        })  
        return '"' .. str .. '"'  
    end  
    wrapKey = function(val)  
        if type(val) == "number" then  
            return "[" .. val .. "]"  
        elseif type(val) == "string" then  
            return "[" .. quoteStr(val) .. "]"  
        else  
            return "[" .. tostring(val) .. "]"  
        end  
    end  
    wrapVal = function(val, level)  
        if type(val) == "table" then  
            return dumpObj(val, level)  
        elseif type(val) == "number" then  
            return val  
        elseif type(val) == "string" then  
            return quoteStr(val)  
        else  
            return tostring(val)  
        end  
    end  
    local isArray = function(arr)  
        local count = 0   
        for k, v in pairs(arr) do  
            count = count + 1   
        end   
        for i = 1, count do  
            if arr[i] == nil then  
                return false  
            end   
        end   
        return true, count  
    end  
    dumpObj = function(obj, level)  
        if type(obj) ~= "table" then  
            return wrapVal(obj)  
        end  
        level = level + 1  
        local tokens = {}  
        tokens[#tokens + 1] = "{"  
        local ret, count = isArray(obj)  
        if ret then  
            for i = 1, count do  
                tokens[#tokens + 1] = getIndent(level) .. wrapVal(obj[i], level) .. ","  
            end  
        else  
            for k, v in pairs(obj) do  
                tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","  
            end  
        end  
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"  
        return table.concat(tokens, "\n")  
    end  
    return dumpObj(obj, 0)  
end  



local Class = {}
setmetatable(Class, { __index = function(list,key)

    local cls = objc.getclass(key)
    list[key] = cls
    return cls

end})

objc.class = Class


local Context = {}

function Context:create()
    local s = { stack = objc.newstack()}
    setmetatable(s, {__index = self})
    return s
end

function Context:sendMesg (target, selector, ...)
   local stack = self.stack
   local n = select("#", ...)
   for i = 1, n do
      local arg = select(-i, ...)
      objc.push(stack, arg)
   end
   objc.push(stack, target, selector)
   objc.operate(stack, "call")
   return objc.pop(stack)
end

function Context:wrap(obj)
   local o = {}
   setmetatable(o, {__call = function (func, ...)
                                local ret = self:sendMesg(obj, ...)
                                if type(ret) == "userdata" then
                                    return self:wrap(ret)
                                else
                                    return ret
                                end
                             end,
                    __unm = function (op)
                               return obj
                            end})
   return o
end

objc.context = Context






