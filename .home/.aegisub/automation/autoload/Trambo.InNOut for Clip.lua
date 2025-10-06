script_name="@TRAMBO: In N Out for Clip"
script_description="In N Out for Clip"
script_author="TRAMBO"
script_version="1.1"

require "karaskel"

loadTime = ".                 Load time from Actor                 ."
apply =    ".                         Apply                         ."
cancel = ".        Close        ."

none = "None"; rand = "Random"; l2r = "L -> R"; r2l = "L <- R"; lr2c = "-> C <-"; c2lr = "<- C ->"; t2b = "T -> B"; b2t = "T <- B"; tb2m = "T -> M <- B"; m2tb = "T <- M -> B"; zin = "Zoom in"; zout = "Zoom out" 
tdir = {l2r,r2l,lr2c,c2lr,t2b,b2t,tb2m,m2tb,zin,zout}
tdirIn = {l2r,r2l,c2lr,t2b,b2t,m2tb,zout}
tdirOut = {l2r,r2l,lr2c,t2b,b2t,tb2m,zin}
dropdown = {none, rand, l2r, r2l, lr2c,c2lr, t2b,b2t,tb2m,m2tb,zin,zout}
s1 = 0
e1 = 0
s2 = 0
e2 = 0
d1 = none 
d2 = none 

--Main
function main(sub, sel, act)

  sel = open_dialog(sub,sel,act)
  aegisub.set_undo_point(script_name)
  return sel
end

function open_dialog(sub,sel,act)
  meta, styles = karaskel.collect_head(sub, false)
  local tempsub = {}
  for i, v in ipairs(sub) do
    table.insert(tempsub,v)
  end

  ADD = aegisub.dialog.display
  ADO = aegisub.debug.out
  ADOP = aegisub.dialog.open

  GUI = 
  {
    { class = "label", x = 0, y = 0, width = 4, height = 1, label = "IN"},

    { class = "label", x = 4, y = 0, width = 4, height = 1, label = "OUT"},
    { class = "label", x = 0, y = 1, width = 1, height = 1, label = "Start"},
    { class = "floatedit", x = 1, y = 1, width = 1, height = 1, min = -100000, max  = 100000, value = s1, name = "sIn", hint = "start time"},
    { class = "label", x = 2, y = 1, width = 1, height = 1, label = "End"},
    { class = "floatedit", x = 3, y = 1, width = 1, height = 1, min = -100000, max  = 100000, value = e1, name = "eIn", hint = "end time"},
    { class = "label", x = 4, y = 1, width = 1, height = 1, label = "Start"},
    { class = "floatedit", x = 5, y = 1, width = 1, height = 1, min = -100000, max  = 100000, value = s2, name = "sOut", hint = "start time"},
    { class = "label", x = 6, y = 1, width = 1, height = 1, label = "End"},
    { class = "floatedit", x = 7, y = 1, width = 1, height = 1, min = -100000, max  = 100000, value = e2, name = "eOut", hint = "end time"},

    { class = "label", x = 0, y = 2, width = 4, height = 1, label = "Direction"},
    { class = "label", x = 4, y = 2, width = 4, height = 1, label = "Direction"},
    { class = "dropdown", x = 0, y = 3, width = 4, height = 1, items= dropdown, value = d1, name = "d1", hint = ""},
    { class = "dropdown", x = 4, y = 3, width = 4, height = 1, items= dropdown, value = d2, name = "d2", hint = ""},

  }

  buttons = {loadTime,apply,cancel}
  choice,res = ADD(GUI,buttons)

  local timeActor = {}
  while choice == loadTime do
    local al = sub[act]
    karaskel.preproc_line(sub, meta, styles, al)
    for v in al.actor:gmatch("%d+%.?%d*") do
      table.insert(timeActor, v)
    end
    local time = {}
    for i=1,#timeActor,1 do
      time[i]=tonumber(timeActor[i])
    end
    s1 = time[1]
    e1 = time[2]
    s2 = time[3]
    e2 = time[4]
    GUI = updateGUI(s1,e1,s2,e2,d1,d2)
    choice,res = ADD(GUI,buttons)

  end

  if choice == apply then
    s1 = res.sIn
    e1 = res.eIn
    s2 = res.sOut
    e2 = res.eOut

    local time = {s1,e1,s2,e2}
    local ratio = {true,true,true,true}
    for i=1,#time,1 do 
      if time[i] > 1 or time[i] < -1 then
        ratio[i] = false
      end
    end

    local valid = true;
    if res.d1 == none and res.d2 == none then
      valid = false
    elseif (res.d1 == lr2c) and (res.d2 ~= none and res.d2 ~= c2lr and res.d2 ~= rand) then
      ADO("In effect ( -> C <- ) can only combine with Out effect ( <- C -> )")
      valid = false;
    elseif (res.d1 == tb2m) and (res.d2 ~= none and res.d2 ~= m2tb and res.d2 ~= rand) then
      ADO("In effect ( T -> M <- B ) can only combine with Out effect ( T <- M -> B )")
      valid = false;
    elseif (res.d1 ~= none and res.d1 ~= lr2c and res.d1 ~= rand) and (res.d2 == c2lr) then
      ADO("Out effect ( <- C -> ) can only combine with In effect ( -> C <- )")
      valid = false
    elseif (res.d1 ~= none and res.d1 ~= tb2m and res.d1 ~= rand) and (res.d2 == m2tb) then
      ADO("Out effect ( T <- M -> B ) can only combine with In effect ( T -> M <- B )")
      valid = false 
    elseif (res.d1 == zin) and (res.d2 ~= none and res.d2 ~= zout and res.d2 ~= rand) then
      ADO("In effect ( Zoom in ) can only combine with Out effect ( Zoom out )")
      valid = false;
    elseif (res.d1 ~= none and res.d1 ~= zin and res.d1 ~= rand) and (res.d2 == zout) then
      ADO("Out effect ( Zoom out ) can only combine with In effect ( Zoom in )")
      valid = false   
    end
    if valid then
      for si,li in ipairs(sel) do
        d1 = res.d1
        d2 = res.d2
        time[1] = res.sIn
        time[2] = res.eIn
        time[3] = res.sOut
        time[4] = res.eOut
        local line = sub[li]
        karaskel.preproc_line(sub, meta, styles, line)
        for i=1,#ratio,1 do
          if ratio[i] == true then
            time[i] = line.duration * time[i]
            if time[i] < 0 then 
              time[i] = line.duration + time[i]
            end
          elseif time[i] < 0 then
            time[i]=line.duration + time[i]
            if time[i] < 0 then
              time[i] = 0
            end
          end
        end
        s1 = time[1]
        e1 = time[2]
        s2 = time[3]
        e2 = time[4]
        if line.text:find("\\clip%(.-%)") then
          local fullClip = line.text:match("\\clip%(.-%)")
          local tvar = {}
          for v in fullClip:gmatch("%d+%.?%d*") do
            table.insert(tvar,v)
          end
          local sInClip = ""
          local eInClip = ""
          local sOutClip = ""
          local eOutClip = ""
          local cen = (tonumber(tvar[1])+tonumber(tvar[3]))/2
          local cenStr = string.format("%.3f",cen)
          local mid = (tonumber(tvar[2])+tonumber(tvar[4]))/2
          local midStr = string.format("%.3f",mid)

          math.randomseed( os.time() + li )
          if d1 == rand and d2 == none then
            d1 = tdir[math.random(#tdir)]
          elseif d1 == none and d2 == rand then
            d2 = tdir[math.random(#tdir)]
          elseif d1 == rand and d2 == rand then
            d1 = tdir[math.random(#tdir)]
            if d1 == lr2c then
              d2 = c2lr
            elseif d1 == tb2m then
              d2 = m2tb
            elseif d1 == zin then
              d2 = zout
            else  
              d2 = tdirOut[math.random(#tdirOut)]
            end 
          elseif d1 == rand then
            if d2 == c2lr then
              d1 = lr2c
            elseif d2 == m2tb then
              d1 = tb2m
            elseif d2 == zout then
              d1 = zin
            else 
              d1 = tdirIn[math.random(#tdirIn)]
            end

          elseif d2 == rand then
            if d1 == lr2c then 
              d2 = c2lr
            elseif d1 == tb2m then
              d2 = m2tb
            elseif d1 == zin then
              d2 = zout
            else
              d2 = tdirOut[math.random(#tdirOut)]
            end

          end

          -- IN  
          -- L -> R
          if d1 == l2r then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",tvar[1],tvar[2],tvar[1],tvar[4])
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
            -- L <- R  
          elseif d1 == r2l then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",tvar[3],tvar[2],tvar[3],tvar[4])
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
            -- -> C <- **
          elseif d1 == lr2c then
            sInClip = fullClip:gsub("\\clip","\\iclip")
            eInClip = string.format("\\t(%d,%d,\\iclip(%s,%s,%s,%s))",s1,e1,cenStr,tvar[2],cenStr,tvar[4])
            -- <- C -> 
          elseif d1 == c2lr then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",cenStr,tvar[2],cenStr,tvar[4])
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
            --T -> B
          elseif d1 == t2b then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",tvar[1],tvar[2],tvar[3],tvar[2])
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
            --B -> T
          elseif d1 == b2t then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",tvar[1],tvar[4],tvar[3],tvar[4])
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
            -- T -> M <- B **
          elseif d1 == tb2m then
            sInClip = fullClip:gsub("\\clip","\\iclip")
            eInClip = string.format("\\t(%d,%d,\\iclip(%s,%s,%s,%s))",s1,e1,tvar[1],midStr,tvar[3],midStr)
            -- T <- M -> B
          elseif d1 == m2tb then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",tvar[1],midStr,tvar[3],midStr)
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
          elseif d1 == zin then
            sInClip = fullClip:gsub("\\clip","\\iclip")
            eInClip = string.format("\\t(%d,%d,\\iclip(%s,%s,%s,%s))",s1,e1,cenStr,midStr,cenStr,midStr)
          elseif d1 == zout then
            sInClip = string.format("\\clip(%s,%s,%s,%s)",cenStr,midStr,cenStr,midStr)
            eInClip = string.format("\\t(%d,%d,%s)",s1,e1,fullClip)
          end
          -- OUT
          -- L -> R
          if d2 == l2r then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,tvar[3],tvar[2],tvar[3],tvar[4])
            -- L <- R  
          elseif d2 == r2l then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,tvar[1],tvar[2],tvar[1],tvar[4])
            -- -> C <- 
          elseif d2 == lr2c then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,cenStr,tvar[2],cenStr,tvar[4])
            -- <- C -> **
          elseif d2 == c2lr then
            sOutClip = string.format("\\iclip(%s,%s,%s,%s)",cenStr,tvar[2],cenStr,tvar[4])
            eOutClip = string.format("\\t(%d,%d,%s)",s2,e2,fullClip:gsub("\\clip","\\iclip"))
            --T -> B
          elseif d2 == t2b then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,tvar[1],tvar[4],tvar[3],tvar[4])
            --B -> T
          elseif d2 == b2t then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,tvar[1],tvar[2],tvar[3],tvar[2])
            -- T -> M <- B
          elseif d2 == tb2m then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,tvar[1],midStr,tvar[3],midStr)
            -- T <- M -> B **
          elseif d2 == m2tb then
            sOutClip = string.format("\\iclip(%s,%s,%s,%s)",tvar[1],midStr,tvar[3],midStr)
            eOutClip = string.format("\\t(%d,%d,%s)",s2,e2,fullClip:gsub("\\clip","\\iclip"))
          elseif d2 == zin then
            sOutClip = fullClip
            eOutClip = string.format("\\t(%d,%d,\\clip(%s,%s,%s,%s))",s2,e2,cenStr,midStr,cenStr,midStr)
          elseif d2 == zout then
            sOutClip = string.format("\\iclip(%s,%s,%s,%s)",cenStr,midStr,cenStr,midStr)
            eOutClip = string.format("\\t(%d,%d,%s)",s2,e2,fullClip:gsub("\\clip","\\iclip"))
          end
          if d1 ~= none and d2 ~= none then
            sOutClip = ""
          end

          line.text = line.text:gsub("\\clip%(.-%)",sInClip .. eInClip .. sOutClip .. eOutClip,1)
          sub[li] = line
        end

      end
      s1 = res.sIn
      e1 = res.eIn
      s2 = res.sOut
      e2 = res.eOut
      d1 = res.d1
      d2 = res.d2
    end
  end
  return sel
end

--update GUI
function updateGUI(s1,e1,s2,e2,d1,d2)
  local g = 
  {
    { class = "label", x = 0, y = 0, width = 4, height = 1, label = "IN"},

    { class = "label", x = 4, y = 0, width = 4, height = 1, label = "OUT"},
    { class = "label", x = 0, y = 1, width = 1, height = 1, label = "Start"},
    { class = "floatedit", x = 1, y = 1, width = 1, height = 1, min = 0, max  = 10000, value = s1, name = "sIn", hint = "start time"},
    { class = "label", x = 2, y = 1, width = 1, height = 1, label = "End"},
    { class = "floatedit", x = 3, y = 1, width = 1, height = 1, min = 0, max  = 10000, value = e1, name = "eIn", hint = "end time"},
    { class = "label", x = 4, y = 1, width = 1, height = 1, label = "Start"},
    { class = "floatedit", x = 5, y = 1, width = 1, height = 1, min = 0, max  = 10000, value = s2, name = "sOut", hint = "start time"},
    { class = "label", x = 6, y = 1, width = 1, height = 1, label = "End"},
    { class = "floatedit", x = 7, y = 1, width = 1, height = 1, min = 0, max  = 10000, value = e2, name = "eOut", hint = "end time"},

    { class = "label", x = 0, y = 2, width = 4, height = 1, label = "Direction"},
    { class = "label", x = 4, y = 2, width = 4, height = 1, label = "Direction"},
    { class = "dropdown", x = 0, y = 3, width = 4, height = 1, items= dropdown, value = d1, name = "d1", hint = ""},
    { class = "dropdown", x = 4, y = 3, width = 4, height = 1, items= dropdown, value = d2, name = "d2", hint = ""},
  }
  return g
end

--send to Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)