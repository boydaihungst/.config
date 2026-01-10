-- Trambo.Library
-- Author="TRAMBO"
-- Version="1.5.1" updated on 230108

include("karaskel.lua") -- karaskel.lua written by Niels Martin Hansen and Rodrigo Braz Monteiro

trambo = aegisub.decode_path("?user") .. "\\Trambo"

function remove_accents_v1(text)
  local aList = "áảàãạâấầẩậẫăắằẳẵặāǎ"
  local AList = "ÁẢÀÃẠÂẤẦẨẬẪĂẮẰẲẴẶĀǍ"
  local oList = "óòỏõọôốồổỗộơớờởỡợǒō"
  local OList = "ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢǑŌ"
  local eList = "éèẻẽẹêếềểễệēě"
  local EList = "ÉÈẺẼẸÊẾỀỂỄỆĒĚ"
  local iList = "íìỉĩịīǐ"
  local IList = "ÍÌỈĨỊĪǏ"
  local uList = "úùủũụưứừửữựüūǔ"
  local UList = "ÚÙỦŨỤƯỨỪỬỮỰÜŪǓ"
  local yList = "ýỳỷỹỵ"
  local YList = "ÝỲỶỸỴ"

  local nline = ""
  local t = {}

  for c, i in unicode.chars(text) do
    table.insert(t, c)
  end

  local n = 1
  while (n <= #t) do
    if t[n] == "{" then
      while t[n] ~= "}" do
        nline = nline .. t[n]
        n = n + 1
      end
    else
      for c, j in unicode.chars(aList) do
        if t[n] == c then t[n] = "a" end
      end
      for c, j in unicode.chars(AList) do
        if t[n] == c then t[n] = "A" end
      end
      for c, j in unicode.chars(oList) do
        if t[n] == c then t[n] = "o" end
      end
      for c, j in unicode.chars(OList) do
        if t[n] == c then t[n] = "O" end
      end
      for c, j in unicode.chars(eList) do
        if t[n] == c then t[n] = "e" end
      end
      for c, j in unicode.chars(EList) do
        if t[n] == c then t[n] = "E" end
      end
      for c, j in unicode.chars(iList) do
        if t[n] == c then t[n] = "i" end
      end
      for c, j in unicode.chars(IList) do
        if t[n] == c then t[n] = "I" end
      end
      for c, j in unicode.chars(uList) do
        if t[n] == c then t[n] = "u" end
      end
      for c, j in unicode.chars(UList) do
        if t[n] == c then t[n] = "U" end
      end
      for c, j in unicode.chars(yList) do
        if t[n] == c then t[n] = "y" end
      end
      for c, j in unicode.chars(YList) do
        if t[n] == c then t[n] = "Y" end
      end
      if t[n] == "Đ" then t[n] = "D" elseif t[n] == "đ" then t[n] = "d" end
      nline = nline .. t[n]
      n = n + 1
    end
  end
  text = nline
  return text
end

function remove_accents_v2(sub,sel)
  local aList = "áảàãạâấầẩậẫăắằẳẵặāǎ"
  local AList = "ÁẢÀÃẠÂẤẦẨẬẪĂẮẰẲẴẶĀǍ"
  local oList = "óòỏõọôốồổỗộơớờởỡợǒō"
  local OList = "ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢǑŌ"
  local eList = "éèẻẽẹêếềểễệēě"
  local EList = "ÉÈẺẼẸÊẾỀỂỄỆĒĚ"
  local iList = "íìỉĩịīǐ"
  local IList = "ÍÌỈĨỊĪǏ"
  local uList = "úùủũụưứừửữựüūǔ"
  local UList = "ÚÙỦŨỤƯỨỪỬỮỰÜŪǓ"
  local yList = "ýỳỷỹỵ"
  local YList = "ÝỲỶỸỴ"

  for i, l in ipairs(sel) do
    local line = sub[l]
    local nline = ""
    local t = {}

    for c, i in unicode.chars(line.text) do
      table.insert(t, c)
    end

    local n = 1
    while (n <= #t) do
      if t[n] == "{" then
        while t[n] ~= "}" do
          nline = nline .. t[n]
          n = n + 1
        end
      else
        for c, j in unicode.chars(aList) do
          if t[n] == c then t[n] = "a" end
        end
        for c, j in unicode.chars(AList) do
          if t[n] == c then t[n] = "A" end
        end
        for c, j in unicode.chars(oList) do
          if t[n] == c then t[n] = "o" end
        end
        for c, j in unicode.chars(OList) do
          if t[n] == c then t[n] = "O" end
        end
        for c, j in unicode.chars(eList) do
          if t[n] == c then t[n] = "e" end
        end
        for c, j in unicode.chars(EList) do
          if t[n] == c then t[n] = "E" end
        end
        for c, j in unicode.chars(iList) do
          if t[n] == c then t[n] = "i" end
        end
        for c, j in unicode.chars(IList) do
          if t[n] == c then t[n] = "I" end
        end
        for c, j in unicode.chars(uList) do
          if t[n] == c then t[n] = "u" end
        end
        for c, j in unicode.chars(UList) do
          if t[n] == c then t[n] = "U" end
        end
        for c, j in unicode.chars(yList) do
          if t[n] == c then t[n] = "y" end
        end
        for c, j in unicode.chars(YList) do
          if t[n] == c then t[n] = "Y" end
        end
        if t[n] == "Đ" then t[n] = "D" elseif t[n] == "đ" then t[n] = "d" end
        nline = nline .. t[n]
        n = n + 1
      end
    end
    line.text = nline
    sub[l] = line
  end
end

function get_raw_v1(str)
  local t = {} -- full str
  for c, i in unicode.chars(str) do
    table.insert(t, c)
  end

  local p = {} --chars' position
  local n = 1
  while n <= #t do 
    if t[n] == "{" then
      while t[n] ~= "}" do
        n = n + 1
      end
      n = n + 1
    else
      table.insert(p, n)
      n = n + 1
    end
  end  
  return t, p
end

function get_raw_v2(str,choice)
  local t = {}; local p = {} --chars' position
  if choice == 1 then -- WORD
    local tchar = {} -- full str
    for c, i in unicode.chars(str) do
      table.insert(tchar, c)
    end

    local count = 0
    local n = 1
    local temp = ""
    while n <= #tchar do 
      if tchar[n] == "{" then
        while tchar[n] ~= "}" do
          temp = temp .. tchar[n]
          n = n + 1
        end
        temp = temp .. "}"
        table.insert(t,temp)
        temp = ""
        count = count + 1
        n = n + 1
      elseif tchar[n] == " " or tchar[n] == "*" then
        table.insert(t,tchar[n])
        count = count + 1
        table.insert(p,count)
        n = n + 1
      else       
        temp = temp .. tchar[n]
        n = n + 1
        if tchar[n] == "{" or tchar[n] == " " or tchar[n] == "*" or tchar[n] == nil then
          table.insert(t,temp)
          temp = ""
          count = count + 1
          table.insert(p,count)
        end
      end

  end
  
  elseif choice == 2 then --WORD NO SPACE
    local tchar = {} -- full str
    for c, i in unicode.chars(str) do
      table.insert(tchar, c)
    end

    local count = 0
    local n = 1
    local temp = ""
    while n <= #tchar do 
      if tchar[n] == "{" then
        while tchar[n] ~= "}" do
          n = n + 1
        end
        temp = temp .. "}"
        n = n + 1
      elseif tchar[n] == " " or tchar[n] == "*" then
        n = n + 1
      else       
        temp = temp .. tchar[n]
        n = n + 1
        if tchar[n] == "{" or tchar[n] == " " or tchar[n] == "*" or tchar[n] == nil then
          table.insert(t,temp)
          temp = ""
          count = count + 1
          table.insert(p,count)
        end
      end

    end
  elseif choice == 0 then --CHAR
    for c, i in unicode.chars(str) do
      table.insert(t, c)
    end

    local n = 1
    while n <= #t do 
      if t[n] == "{" then
        while t[n] ~= "}" do
          n = n + 1
        end
        n = n + 1
      else
        table.insert(p, n)
        n = n + 1
      end
    end  
  end

  return t, p
end

function getToken(str,choice,block) 
  -- must replace \\N with *N;
  local t = {}--token
  local p = {} --token position
  local tchar = {} --char table

  for c, i in unicode.chars(str) do
    table.insert(tchar, c)
  end
  for i=1,#tchar-2,1 do
    if tchar[i] == "*" and tchar[i+1] == "N" and tchar[i+2] == ";" then
      tchar[i] = "*N;"
      table.remove(tchar,i+1)
      table.remove(tchar,i+1)
    end
  end

  local count = 0
  local n = 1
  local temp = ""

  if choice == word then
    if block == false then
      while n <= #tchar do 
        if tchar[n] == "{" then
          while tchar[n] ~= "}" do
            temp = temp .. tchar[n]
            n = n + 1
          end
          temp = temp .. "}"
          table.insert(t,temp)
          temp = ""
          count = count + 1
          n = n + 1
        elseif tchar[n] == " " or tchar[n] == "*N;" then
          table.insert(t,tchar[n])
          count = count + 1
          table.insert(p,count)
          n = n + 1
        else       
          temp = temp .. tchar[n]
          n = n + 1
          if tchar[n] == "{" or tchar[n] == " " or tchar[n] == "*N;" or tchar[n] == nil then
            table.insert(t,temp)
            temp = ""
            count = count + 1
            table.insert(p,count)
          end
        end
      end
    else
      while n <= #tchar do 
        if tchar[n] == " " or tchar[n] == "*N;" then
          table.insert(t,tchar[n])
          count = count + 1
          table.insert(p,count)
          n = n + 1
        elseif tchar[n] == "{" then
          while tchar[n] ~= "}" do
            temp = temp .. tchar[n]
            n = n + 1
          end
          if tchar[n] == "}" then
            temp = temp .. tchar[n]
            local m = n + 1
            if tchar[m] == " " or tchar[m] == "*N;" then
              n = n + 1
              while tchar[n] == " " or tchar[n] == "*N;" do
                temp = temp .. tchar[n]
                n = n + 1
              end
            else
              n = n + 1
            end
          end
          while tchar[n] ~= " " and tchar[n] ~= "{" and tchar[n] ~= "*N;" and tchar[n] ~= nil do
            temp = temp .. tchar[n]
            n = n + 1
            if tchar[n] == " " or tchar[n] == "{" or tchar[n] == "*N;" or tchar[n] == nil then
              table.insert(t,temp)
              temp = ""
              count = count + 1
              table.insert(p,count)
            end
          end
        else
          while tchar[n] ~= " " and tchar[n] ~= "{" and tchar[n] ~= "*N;" and tchar[n] ~= nil do
            temp = temp .. tchar[n]
            n = n + 1
            if tchar[n] == " " or tchar[n] == "{" or tchar[n] == "*N;" or tchar[n] == nil then
              table.insert(t,temp)
              temp = ""
              count = count + 1
              table.insert(p,count)
            end
          end
        end
      end 
    end 

  else -- CHAR
    if block == false then
      t = tchar
      while n <= #tchar do 
        if tchar[n] == "{" then
          while tchar[n] ~= "}" do
            n = n + 1
          end
          n = n + 1
        else
          table.insert(p, n)
          n = n + 1
        end
      end    
    else --block == true    
      while n <= #tchar do 
        if tchar[n] == "{" then
          while tchar[n] ~= "}" do
            temp = temp .. tchar[n]
            n = n + 1
          end
          if tchar[n] == "}" then
            temp = temp .. tchar[n]
            local m = n + 1
            if tchar[m] == " " or tchar[m] == "*N;" then
              n = n + 1
              while tchar[n] == " " or tchar[n] == "*N;" do
                temp = temp .. tchar[n]
                n = n + 1
              end
            else
              n = n + 1
            end
            if tchar[n]~=nil then 
              temp = temp .. tchar[n]
              table.insert(t, temp)
              temp = ""
              count = count + 1
              table.insert(p, count)
              n = n + 1
            end
          end
        else
          table.insert(t, tchar[n])
          count = count + 1
          table.insert(p, count)
          n = n + 1
        end
      end
    end  
  end
  if block == true then
    local bl = {}
    for i, v in ipairs(p) do 
      if t[p[i]]:find("{.-}") then
        table.insert(bl,t[p[i]]:match("{.-}"))
      else
        table.insert(bl,"")
      end
--      end
    end
    for i, v in ipairs(p) do --DELETE BLOCKS IN t
      if bl[i] ~= "" then
        t[v] = t[v]:gsub("{.-}","")
      end
    end
    return t, p, bl
  else
    return t, p
  end
end

function add_accents_v1(new,old) -- parameters are strings
  local pNew = {}
  tNew, pNew = get_raw_v1(new)
  local pOld = {}
  tOld, pOld = get_raw_v1(old)
  local nText = ""
  local oText = ""
  for i, p in ipairs(pNew) do
    nText = nText .. tNew[p]
  end

  for i, p in ipairs(pOld) do
    oText = oText .. tOld[p]
  end

  if (#pOld ~= #pNew) then
    aegisub.debug.out("Failed to add accents: Two lines of text must have the same pattern.\n")
    aegisub.debug.out("Line 1: " .. nText .. "\n")
    aegisub.debug.out("Line 2: " .. oText .. "\n")
    aegisub.debug.out("Please edit one of two lines.")
  else
    for i, o in ipairs(pOld) do
      if tNew[pNew[i]] ~= tOld[o] then
        tOld[o] = tNew[pNew[i]]
      end
    end
  end

  local res = ""
  for i, c in ipairs(tOld) do
    res = res .. c 
  end
  return res
end

--convert original path to aegisub's legal path
function ass_path(path)
  return string.gsub(path, "\\", "/")
end

--draw mask for image/logo
function drawRect(w,h)
  return string.format("m 0 0 l %s 0 %s %s 0 %s", w, w, h, h)
end

--getImgSize function modified and shortened from Get Image Size by: MikuAuahDark
function getImgSize(file)

  file = assert(io.open(file))

  local width,height=0,0
  file:seek("set",1)
  -- Detect if PNG
  if file:read()=="PNG" then
    file:seek("set",16)
    local widthstr,heightstr=file:read(4),file:read(4)

    file:close()

    width=widthstr:sub(1,1):byte()*16777216+widthstr:sub(2,2):byte()*65536+widthstr:sub(3,3):byte()*256+widthstr:sub(4,4):byte()
    height=heightstr:sub(1,1):byte()*16777216+heightstr:sub(2,2):byte()*65536+heightstr:sub(3,3):byte()*256+heightstr:sub(4,4):byte()
    return width,height
  end

  file:seek("set")
  refresh()
end

function shuffle(table)
  math.randomseed(os.time())
  for i = #table, 2, -1 do
    local j = math.random(i)
    table[i], table[j] = table[j], table[i]
  end
end

function get_org_ltext(line)
  local orgline
  if line.text:find("{ol;.-}") then
    orgline = line.text:match("{ol;.-}")
  else
    orgline = "{ol;" .. line.text:gsub("{","h;"):gsub("}","t;"):gsub("\\","sl;") .. "}"
  end
  return orgline
end

function reset_ltext(line)
  if line.text:find("{ol;.-}") then
    line.text = line.text:match("{ol;(.-)}"):gsub("h;","{"):gsub("t;","}"):gsub("sl;","\\")
  end
  return line.text
end

function valid_file(path)
  local f = io.open(path,"r")
  if f ~= nil then 
    io.close(f) 
    return true 
  else 
    return false 
  end
end

function get_presetPath(file, dpath)
  local f = io.open(file,"r+")
  local l = f:read()
  if l == nil then
    f:write(dpath)
    return dpath
  else
    if not valid_file(l) then
      return dpath
    else
      return l
    end

  end
  f:close()
end

function getPreset(path,dpath,namePattern)
  local list = {}
  local f
  if not valid_file(path) then
    path = dpath
  end
  f = io.open(path,"r")
  for line in f:lines() do
    table.insert(list,line:match(namePat))
  end
  f:close()
  return list
end

function removePreset(p,path,namePattern)
  local f = io.open(path,"r")
  local list = {}
  for line in f:lines() do
    if line:match(namePattern) ~= p then
      table.insert(list,line)
    end
  end
  f:close()
  f = io.open(path,"w")
  for i=1,#list,1 do
    f:write(list[i] .. "\n")
  end
  f:close()
end

--***Function Template*** 
function updatePreset(p--[[param_list]])
  msg = [[Are you sure you want to update Preset "]] .. p .. [[" ?]]
  local updatePreset_GUI = {
        { class = "label", x=0, y=0, width=2, height=1, label=msg}
      }
      local updatePreset_buttons = {"YES","NO"}
      updatePreset_choice,updatePreset_res = aegisub.dialog.display(updatePreset_GUI,updatePreset_buttons)
      if updatePreset_choice == "YES" then
        --removePreset(p,path,namePattern)
        --savePreset <- implement in script
        --loadPreset <- implement in script, optional
      end
end

function renamePreset(cur,new,path,namePattern)
  local f = io.open(path,"r")
  local list={}
  for line in f:lines() do
    if line:match(namePattern) == cur then
      line = line:gsub(cur, new, 1)
    end
    table.insert(list,line)
  end
  f:close()
  f = io.open(path,"w")
  for i=1,#list,1 do
    f:write(list[i] .. "\n")
  end
  f:close()
end

function add_fimg_to_line(line, path, x, y,drawing)
  path = ass_path(path)
  local pos = ""
  if string.find(line.text,"\\pos%(") ~= nil then
    pos = string.match(line.text,"(\\pos.-%))")
  end
  line.text = "{\\an5\\bord0\\shad0\\p1\\1img(" .. path .. "," .. x .. "," .. y .. ")" .. pos .. "} ".. drawing
  return line
end

function add_img_to_line(line, path, x, y, mode)
  if mode == 0 then --logo
    local w, h = getImgSize(path)
    local drawing = draw(w,h)
    path = ass_path(path)

    local n = 0
    local pos = ""
    if string.find(line.text,"\\pos%(") ~= nil then
      pos = string.match(line.text,"(\\pos.-%))")
    end
    line.text = "{\\an5\\bord0\\shad0\\p1\\1img(" .. path .. "," .. x .. "," .. y .. ")" .. pos .. "} ".. drawing
  else -- mode = 1,2,3,4
    path = ass_path(path)
    tostring(mode)
    local add = "\\" .. mode .. "img(" .. path .. "," .. x .. "," .. y .. ")"
    if string.match(line.text, '{.*}') == nil or line.text == nil then
      line.text = "{" .. add .. "}" .. line.text
    else   
      if string.find(line.text,mode .. "img") == nil then 
        local tags = string.match(line.text, '{(.-)}')
        local new_tags = "{" .. add .. tags .. "}"
        line.text = string.gsub(line.text, "{(.-)}", new_tags,1)
      else
        subpath = "\\" .. mode .. "img(.-%))"
        if string.find(line.text, '\\p%d') == nil then
          line.text = string.gsub(line.text, subpath, add)
        end
      end
    end
  end
  return line
end


function point_between(x1,y1,x2,y2,t) --t=0->1
  x = x1 + t*(x2-x1)
  y = y1 + t*(y2-y1)
  return x,y
end

function rotatedPoint(x1,y1,xcent,ycent,angle) --(x1,y1) rotate about xcent,ycent
  r = math.rad(angle)
  x = (x1-xcent)*math.cos(r) - (y1-ycent)*math.sin(r) + xcent
  y = (x1-xcent)*math.sin(r) + (y1-ycent)*math.cos(r) + ycent
  return x,y
end

function getBezierPoint(x1,y1,x2,y2,x3,y3,x4,y4,t)
  xt = ((1-t)^3)*x1 + 3*((1-t)^2)*t*x2 + 3*(1-t)*(t^2)*x3 + (t^3)*x4 
  yt = ((1-t)^3)*y1 + 3*((1-t)^2)*t*y2 + 3*(1-t)*(t^2)*y3 + (t^3)*y4
  return xt,yt
end

function found_folder(folder_path)
  local f = io.open(folder_path .. [[\trambo_test.txt]],"w")
  if f ~= nil then
    f:close()
    os.remove(folder_path .. [[\trambo_test.txt]],"w")
    return true
  else
    return false
  end
  
  --using command is slower
--  local f = io.popen([[if exist ]] .. folder_path .. [[ (echo Yes) else (echo No)]])
--  output = f:read()
--  f:close()
--  if output:match("Yes") then return true else return false end
end

function check_folder(path)
  if not found_folder(path) then
    os.execute("mkdir " .. path)
  end
end

function found(file)
  local f = io.open(file,"r")
  if f ~= nil then 
    f:close()
    return true
  else
    return false
  end
end

function check_required_files(list_of_files)
  for i,file in ipairs(list_of_files) do
    if not found(file) then 
      local f = io.open(file, "w")
      f:close()
    end
  end 
end