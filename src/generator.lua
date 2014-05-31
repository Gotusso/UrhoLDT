require("ToDoxHook")

function getTypeReference(t)
  local result

  if t == "" then
    result = "Untyped"
  elseif t == "bool" then
    result = "#boolean"
  elseif t == "int" or t == "float" or t == "unsigned" then
    result = "#number"
  elseif t == "char" or t == "String" then
    result = "#string"      
  else
    result = t .. "#"..t
  end
  
  return result
end

function writeClass(file, class)
  file:write("---\n")
  file:write("-- Module " .. class.name .. "\n")
  if class.base ~= "" then
    file:write("-- Module " .. class.name .. " extends " .. class.base .. "\n")
  end
  file:write("-- Generated on " .. os.date('%Y-%m-%d') .. "\n")
  
  file:write("--\n")
  file:write("-- @module " .. class.name .. "\n\n")

  local target = class
  while target do
	if target.functions ~= nil then
	  for i, func in ipairs(target.functions) do
	    writeFunction(file, class.name, func)
	  end
	end

	if target.properties ~= nil then
	  for i, property in ipairs(target.properties) do
	    writeProperty(file, class.name, property, property.mod:find("tolua_readonly"))
	  end
	end

	target = classes[target.base]
  end

  file:write("\n")
end

function writeClasses(filedir)
  for name, class in pairs(classes) do
    local file = io.open(filedir..class.name..".lua", "wt")
    
    writeClass(file, class)

    file:write("return nil\n")
    file:close()
  end

end

function writeFunction(file, moduleName, func)  
  -- write description
  file:write("---\n")
  file:write("-- Function " .. func.name .. "()\n")

  if func.descriptions ~= nil then
    for i, description in ipairs(func.descriptions) do
      local fixedDescription = description:gsub([[(")]], [[\%1]])
      file:write("-- " .. fixedDescription .. "\n")
    end
  end

  file:write("--\n")

  -- write function header
  file:write("-- @function [parent=#" .. moduleName .. "] " .. func.name .. "\n")
  file:write("-- @param self Self reference\n")

  -- write parameters
  if func.declarations ~= nil then
    local count = table.maxn(func.declarations)
    for i = 1, count do
      local declaration = func.declarations[i]
      if declaration.type ~= "void" then
        file:write("-- @param " .. getTypeReference(declaration.type:gsub("const ", "")) .. " " .. declaration.name .. " " .. declaration.name)
        -- add paramter default value
        if declaration.def ~= "" then
          line = "(Default: " .. declaration.def .. ")"
        end
        file:write("\n")
      end
    end
  end

  -- write return type
  if func.type ~= "" and func.type ~= "void" then
    file:write("-- @return " .. getTypeReference(func.type) .. "\n")
  end
  
  file:write("\n")
end

function writeGlobalFunctions(file)  
  sortByName(globalFunctions)

  for i, func in ipairs(globalFunctions) do
    writeFunction(file, "global", func)
  end

  file:write("\n")
end

function writeGlobalConstants(file)
  sortByName(globalConstants)

  for i, constant in ipairs(globalConstants) do
    writeProperty(file, "global", constant, true)
  end

  file:write("\n")  
end

function writeGlobalProperties(file)
  sortByName(globalProperties)

  for i, property in ipairs(globalProperties) do
    writeProperty(file, "global", property, property.mod:find("tolua_readonly"))
  end

end

function writeEnumerates(file)
  sortByName(enumerates)
  for i, enumerate in ipairs(enumerates) do
    
    for i, value in ipairs(enumerate.values) do
      file:write("---\n")
      file:write("-- Enumeration value " .. enumerate.name .. "." .. value .. "\n")
      file:write("--\n")
      file:write("-- @field [parent=#global] #number " .. value .. "\n\n")
    end
    
    file:write("\n")
  end
end

function writeProperty(file, moduleName, property, constant)
  file:write("---\n")
  file:write("-- Field " .. property.name)
  if constant then
    file:write(" (Read only)\n")
  else
    file:write("\n")
  end
  file:write("--\n")
  file:write("-- @field [parent=#" .. moduleName .. "] " .. getTypeReference(property.type:gsub("const ", "")) .. " " .. property.name.."\n\n")
end

function classPackage:print()
  if flags.o == nil then
    print("Invalid output filename");
    return
  end

  curDir = getCurrentDirectory()

  local filename = flags.o
  local fileindex = string.find(filename, "%w+%.lua")
  local filedir = string.sub(filename, 1, fileindex - 1)

  local i = 1
  while self[i] do
    self[i]:print("","")
    i = i + 1
  end
  printDescriptionsFromPackageFile(flags.f)

  writeClasses(filedir)

  local globalfile = io.open(filedir.."global.lua", "a+")

  writeGlobalFunctions(globalfile)
  writeGlobalProperties(globalfile)
  writeGlobalConstants(globalfile)
  writeEnumerates(globalfile)

  globalfile:write("return nil\n")

  globalfile:close()
end
