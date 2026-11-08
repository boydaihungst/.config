--[[TODO: 1. (+) option start offset & end offset, for example: (300,1000,fx) / (-1000,-500,fx)
          2. (+) for L<-R: if using multiple lines with \N, start from first -> last line instead of last -> first line
  ]] 

script_name="@TRAMBO: In N Out v2.2.1"
script_description="Create in and out effects"
script_author="TRAMBO"
script_version="2.2.1" --fixed bug in checking and generating required files

include("karaskel.lua")

xres = 1920; yres = 1080
a0 = "\\alpha&H00&"; aF = "\\alpha&HFF&"
ih = "{i;"; it = ";i}"
oh = "{o;"; ot = ";o}"
--X 
none = "None"; l = "L -> R"; lnofade = "L -> R no fade"; r = "L <- R"; rnofade = "L <- R no fade"; lr = "-> C <-"; rl = "<- C ->"; 
--Y
tml = "T -> M , L -> R"; tm = "T -> M"; bm = "B -> M"; tbm = "T -> M <- B"; mtm = "M -> T -> M"; mbm = "M -> B -> M"; sin = "SINE WAVE"; mt = "M -> T"; mb = "M -> B"; mtb = "T <- M -> B"; rand = "Random"; randnofade = "Random no fade"
--Z
outscr = "Out of Screen"; inscr = "Into Screen"
--buttons
char = "Character"
word = "Word"
reset = "Reset"
save = "Save"
update = "Update Preset"
cancel = "Cancel"
ok = "OK"
loadPr = "Load Preset"
manage = "Manage"
remove = "Remove"
rename = "Rename"

ctime1 = {none,rand,randnofade,l,lnofade,r,rnofade}
ctime2 = {lr,rl}
--vars
tin = 1000; tout = 1000
fin = 500; fout = 500
dirin = none; dirout = none
ydirin = none; ydirout = none
zdirin = none; zdirout = none
yin = 40; yout = 40 -- fsvp
zin = 30; zout = 30
xScalein = 0; xScaleout = 0
fscxin = false; fscxout = false
yScalein = 0; yScaleout = 0
fscyin = false; fscyout = false
scalein = 0; scaleout = 0
fscin = false; fscout = false
xRotin = 0; xRotout = 0
frxin = false; frxout = false
yRotin = 0; yRotout = 0
fryin = false; fryout = false
zRotin = 0; zRotout = 0
frzin = false; frzout = false
blurin = 0; blurout = 0
blin = false; blout = false
anFlag = false; an = "1"

trambo = aegisub.decode_path("?user") .. [[\Trambo]]
path_file = trambo .. [[\InNOut_preset_path.txt]]
preset_file = trambo .. [[\InNOut Preset.txt]]

function found_folder(folder_path) 
  local f = io.open(folder_path .. [[\trambo_test.txt]],"w")
  if f ~= nil then
    f:close()
    os.remove(folder_path .. [[\trambo_test.txt]],"w")
    return true
  else
    return false
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

function get_presetPath()
  local f = io.open(aegisub.decode_path("?user") .. "\\Trambo\\InNOut_preset_path.txt","r+")
  local l = f:read()
  if l == nil then
    f:write(aegisub.decode_path("?user") .. "\\Trambo\\InNOut Preset.txt")
    return aegisub.decode_path("?user") .. "\\Trambo\\InNOut Preset.txt"
  else
    return l
  end
  f:close()
end

function getPreset()
  local list = {}
  local f = io.open(presetPath,"r")
  for line in f:lines() do
    table.insert(list,line:match("preset=(.-);"))
  end
  f:close()
  return list
end

---------------------------------------------
function main(sub, sel, act)
  ADD = aegisub.dialog.display
  ADO = aegisub.debug.out
  if not found_folder(trambo) then
    os.execute("mkdir " .. trambo)
  end
  check_required_files({path_file,preset_file})
  presetPath = get_presetPath()
  presetList = getPreset()
  curPreset = presetList[1]
  sel = open_dialog(sub,sel)
  aegisub.set_undo_point(script_name)
  return sel
end
---------------------------------------------
function open_dialog(sub,sel)

  presetList = getPreset()
  local meta, styles = karaskel.collect_head(sub,false)
  GUI = updateGUI()

  GUI_save = 
  {
    { class = "label", x = 0, y = 0, width = 1, height = 1, label = "Preset name:"},
    { class = "edit", x = 1, y = 0, width = 2, height = 1, name = "presetName"}
  }

  --buttons
  buttons = {loadPr,save,update,manage,char,word,reset,cancel}
  buttons_save = {ok,cancel}
  buttons_manage = {remove,rename,"Preset File"}

  choice, res = ADD(GUI,buttons)

  while choice == save or choice == update or choice == loadPr or choice == manage do
    curPreset = res.preset
    if choice == save then
      local status = false
      local pass = true
      choice_save, res_save = ADD(GUI_save,buttons_save)
      if choice_save == ok then
        for i,v in ipairs(presetList) do 
          if v == res_save.presetName then
            local err = {{ class = "label", x = 0, y = 0, width = 1, height = 1, label = "This name already exists, please choose another name."}}
            ADD(err,{"Close"})
            pass = false
          end
        end
        if pass == true then
          savePreset(res_save.presetName,res)
          presetList = getPreset()
          curPreset = res_save.presetName
          status = true
        end
      end
    elseif choice == update then
      updatePreset(curPreset,res)
    elseif choice == loadPr then
      loadPreset(curPreset)
    elseif choice == manage then
      GUI_manage = 
      {
        { class = "label", x = 0, y = 0, width = 1, height = 1, label = "Presets"},
        { class = "dropdown", x = 1, y = 0, width = 2, height = 1, items = presetList, value = curPreset, name = "preset_manage"},
        { class = "label", x = 0, y = 1, width = 1, height = 1, label = "Rename"},
        { class = "edit", x = 1, y = 1, width = 2, height = 1, name = "newName"}
      }
      choice_manage, res_manage = ADD(GUI_manage,buttons_manage)
      if choice_manage == remove then
        removePreset(res_manage.preset_manage)
        presetList = getPreset()
        curPreset = presetList[1]
      elseif choice_manage == rename then
        renamePreset(res_manage.preset_manage,res_manage.newName)
        presetList = getPreset()
        curPreset = presetList[1]
      elseif choice_manage == "Preset File" then
        local p = aegisub.dialog.open("Choose your preset file","","","Text files (.txt)|*.txt", false, true)
        if p then
          presetPath = p
          presetList = getPreset()
          curPreset = presetList[1]
          local f = io.open(aegisub.decode_path("?user") .. "\\Trambo\\InNOut_preset_path.txt","w")
          f:write(p)
          f:close()
        end
      end
    end
    GUI = updateGUI()
    --GUI = updateGUI(tin,tout,fin,fout,dirin,dirout,ydirin,ydirout,yin,yout,zdirin,zdirout,zin,zout,fscxin,xScalein,fscxout,xScaleout,fscyin,yScalein,fscyout,yScaleout,fscin,scalein,fscout,scaleout,frxin,xRotin,frxout,xRotout,fryin,yRotin,fryout,yRotout,frzin,zRotin,frzout,zRotout,blin,blurin,blout,blurout,anFlag,an,presetList,curPreset)
    choice, res = ADD(GUI,buttons)
  end

  if choice == char or choice == word then
    local time = {res.inT, res.outT}
    local fade = {res.inF, res.outF}
    local dir = {res.inD, res.outD}
    local ydir = {res.inDy, res.outDy, res.inY, res.outY}
    local zdir = {res.inDz, res.outDz, res.inZ, res.outZ}
    local scale = {{res.inScaleX, res.inScaleX_val, res.outScaleX, res.outScaleX_val}, {res.inScaleY, res.inScaleY_val, res.outScaleY, res.outScaleY_val},{res.inScale,res.inScale_val,res.outScale,res.outScale_val}}
    local rot = {{res.inRotX, res.inRotX_val, res.outRotX, res.outRotX_val}, {res.inRotY, res.inRotY_val, res.outRotY, res.outRotY_val}, {res.inRotZ, res.inRotZ_val, res.outRotZ, res.outRotZ_val}}
    local blur = {res.inBlur, res.inBlur_val, res.outBlur, res.outBlur_val}
    local alignRes = {res.align, res.align_val} 
    if res.inScale then
      scalein = scale[3][2]
      scale[1][2] = scale[3][2]
      scale[2][2] = scale[3][2]
    end
    if res.outScale then
      scaleout = scale[3][4]
      scale[1][4] = scale[3][4]
      scale[2][4] = scale[3][4]
    end
    tin = time[1]; tout = time[2]
    fin = fade[1]; fout = fade[2]
    dirin = dir[1]; dirout = dir[2]
    ydirin = ydir[1]; ydirout = ydir[2]
    zdirin = zdir[1]; zdirout = zdir[2]
    xScalein = scale[1][2]; xScaleout = scale[1][4]
    yScalein = scale[2][2]; yScaleout = scale[2][4]
    fscxin = scale[1][1]; fscxout = scale[1][3]
    fscyin = scale[2][1]; fscyout = scale[2][3]
    fscin = scale[3][1]; fscout = scale[3][3]
    xRotin = rot[1][2]; xRotout = rot[1][4]
    yRotin = rot[2][2]; yRotout = rot[2][4]
    zRotin = rot[3][2]; zRotout = rot[3][4]
    frxin = rot[1][1]; frxout = rot[1][3]
    fryin = rot[2][1]; fryout = rot[2][3]
    frzin = rot[3][1]; frzout = rot[3][3]
    blurin = blur[2]; blurout = blur[4]
    blin = blur[1]; blout = blur[3]
    anFlag = alignRes[1]; an = alignRes[2]

    if fade[1] ~= 0 or fade[2] ~= 0 or (time[1] ~= 0 and dir[1] ~= none) or (time[2] ~= 0 and dir[2] ~= none) or alignRes[1] then
      apply_fx(sub, sel, time, fade, dir, ydir, zdir, scale, rot, blur, alignRes, choice)
    end
  elseif choice == reset then
    for si,li in ipairs(sel) do
      local line = sub[li]
      line.text = reset_ltext(line)
      sub[li] = line
    end
  end

  return sel
end

function apply_fx(sub, sel, time, fade, dir, ydir, zdir, scale, rot, blur, alignRes , choice)
  meta, styles = karaskel.collect_head(sub, false)
  xres = meta.res_x; yres = meta.res_y
  for si, li in ipairs(sel) do
    local line = sub[li]
    karaskel.preproc_line(sub, meta, styles, line)
    local lStyle = styles[line.style]
    local la1 = alpha_from_style(lStyle.color1)
    local la3 = alpha_from_style(lStyle.color3)
    local la4 = alpha_from_style(lStyle.color4)
    local styleAlpha = ""
    local hasAlpha_style = true
    styleAlpha = "\\1a" .. la1 .. "\\3a" .. la3 .. "\\4a" .. la4
    local orgline = ""
    orgline = get_org_ltext(line)
    line.text = orgline:match("{ol;(.-)}"):gsub("h;","{"):gsub("t;","}"):gsub("sl;","\\")

    time[1] = tin; time[2] = tout; fade[1] = fin; fade[2] = fout
    if time[1] > 0 and time[1] <= 1 then time[1] = line.duration * time[1] else time[1] = math.floor(time[1]+0.5) end
    if time[2] > 0 and time[2] <= 1 then time[2] = line.duration * time[2] else time[2] = math.floor(time[2]+0.5) end
    if fade[1] > 0 and fade[1] <= 1 then fade[1] = line.duration * fade[1] else fade[1] = math.floor(fade[1]+0.5) end
    if fade[2] > 0 and fade[2] <= 1 then fade[2] = line.duration * fade[2] else fade[2] = math.floor(fade[2]+0.5) end

    if choice == char or choice == word then
      if fade[1] ~= 0 or fade[2] ~= 0 then 
        if line.text:find("\\fade?%(") then
          line.text = line.text:gsub("\\fade?.-%)", "\\fad(" .. fade[1] .. "," .. fade[2] .. ")",1)
        else
          if line.text:find("^{.-}") then
            line.text = line.text:gsub("{","{" .. "\\fad(" .. fade[1] .. "," .. fade[2] .. ")",1)
          else
            line.text = "{" .. "\\fad(" .. fade[1] .. "," .. fade[2] .. ")}" .. line.text
          end
        end
      end
      if alignRes[1] then
        local orgAn = "" .. line.styleref.align
        if line.text:find("\\an%d") then
          orgAn = line.text:match("\\an(%d)")
          line.text = line.text:gsub("\\an%d", "\\an" .. an)
        else
          line.text = "{\\an" .. an .. "}" .. line.text
          line.text = line.text:gsub("{+{","{"):gsub("}+}","}"):gsub("}{","")
        end

        local pdefault = p_default(line)
        local orgX = "" .. pdefault[tonumber(orgAn)][1]; local orgY = "" .. pdefault[tonumber(orgAn)][2]
        if line.text:find("\\pos%(") then
          orgX = line.text:match("\\pos%((.-),")
          orgY = line.text:match("\\pos.-,(.-)%)")
        end
        orgX, orgY = get_pos_from_an(orgX,orgY,orgAn,an,line)
        line.text = line.text:gsub("\\pos.-%)","\\pos%(" .. orgX .. "," .. orgY .."%)")
      end
    end

    if (time[1] ~= 0 and dir[1] ~= none) or (time[2] ~= 0 and dir[2] ~= none) then
      local orgTag = "{" .. get_org_tag(line.text) .. "}"
      line.text = line.text:gsub("\\N","*N;")
      local temptext = ""

      if choice == char or choice == word then
        local t, p, bl = getToken(line.text,choice,true)
        -- count #char
        local n = 0
        local cn = 0
        for i,v in ipairs(p) do 
          if t[v] ~= " " and t[v] ~= "*N;" then
            cn = cn + 1
          end
        end

        local mid = math.ceil(cn/2) -- mid char
        local dur = line.duration
        local tout = dur - time[2]

        local fblock = 0
        for i = 1, #bl, 1 do
          if bl[i] ~= "" then 
            fblock = i
            break
          end
        end
        -- add org tag
        for i = 1,#p,1 do
          if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
            if bl[i] ~= "" then
              bl[i] = clean(bl[i])
              local head, tail = sort_tag(bl[i])
              orgTag = adjust_org_tag(orgTag,bl[i])

              if bl[i]:find("\\r") then
                bl[i] = r_to_tag(styles,line,bl[i])
                t[p[i]] = bl[i] .. t[p[i]]
              else
                t[p[i]] = orgTag .. tail .. t[p[i]]
              end
            end
          end
        end
        local orgColor = ""; 
        local orgAlpha = ""
        orgAlpha = styleAlpha
        local hasColor = false; local hasAlpha = false
        local orgScaleX = "\\fscx100"; local orgScaleY = "\\fscy100"
        local orgRotX = "\\frx0"; local orgRotY = "\\fry0"; local orgRotZ = "\\frz0"
        local orgBlur = "\\blur0"
--OUT EFFECTS          
        if time[2] ~= 0 and dir[2] ~= none then
          local ctime
          for i, v in ipairs(ctime1) do
            if dir[2] == v then 
              if v == lnofade or v == rnofade or v == randnofade then 
                ctime = math.floor(time[2] / (cn-1))
              else
                ctime = math.floor(time[2] / cn) 
              end

            end
          end
          for i, v in ipairs(ctime2) do
            if dir[2] == v then ctime = math.floor(time[2] / mid) end
          end

          local tfirst, tlast = ctime_first_last(dir[2],cn,mid)
          -- out RANDOM
          if dir[2] == rand then 
            local pOrder = {}
            for i = 1, #p, 1 do
              table.insert(pOrder,i)
            end
            shuffle(pOrder)
            n = 0
            for i = 1,#p,1 do
              local j = pOrder[i]
              if t[p[j]] ~= " " and t[p[j]] ~= "*N;" then
                n = n + 1 
                if i ~= #p then
                  t[p[j]] = "{\\t(" .. tostring(tout + ctime*(n-1)) .. "," .. tostring(tout + ctime*n) .. "," .. "\\alpha&HFF&)}" .. t[p[j]]
                else
                  t[p[j]] = "{\\t(" .. tostring(tout + ctime*(n-1)) .. "," .. tostring(dur) .. "," .. "\\alpha&HFF&)}" .. t[p[j]]
                end
              end
            end

            -- out RANDOM no fade
          elseif dir[2] == randnofade then 
            local pOrder = {}
            for i = 1, #p, 1 do
              table.insert(pOrder,i)
            end
            shuffle(pOrder)
            n = 0
            for i = 1,#p,1 do
              local j = pOrder[i]
              if t[p[j]] ~= " " and t[p[j]] ~= "*N;" then
                n = n + 1 
                if i==1 or n==1 then
                  t[p[j]] = "{\\t(" .. tostring(tout-1) .. "," .. tostring(tout) .. "," .. "\\alpha&HFF&)}" .. t[p[j]]
                elseif i ~= #p then
                  t[p[j]] = "{\\t(" .. tostring(tout + ctime*(n-1)-1) .. "," .. tostring(tout + ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[j]]
                else
                  t[p[j]] = "{\\t(" .. tostring(dur-1) .. "," .. tostring(dur) .. "," .. "\\alpha&HFF&)}" .. t[p[j]]
                end
              end
            end

            --out L -> R 
          elseif dir[2] == l then
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if i ~= #p then
                  t[p[i]] = "{\\t(" .. tostring(tout + ctime*(n-1)) .. "," .. tostring(tout + ctime*n) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\t(" .. tostring(tout + ctime*(n-1)) .. "," .. tostring(dur) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                end
              end
            end
            --out L -> R no fade
          elseif dir[2] == lnofade then
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if i == 1 then
                  t[p[i]] = "{\\t(" .. tostring(tout-1) .. "," .. tostring(tout) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                elseif i ~= #p then
                  t[p[i]] = "{\\t(" .. tostring(tout + ctime*(n-1)-1) .. "," .. tostring(tout + ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\t(" .. tostring(dur-1) .. "," .. tostring(dur) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                end
              end
            end
            --out L <- R 
          elseif dir[2] == r then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n == cn then
                  t[p[i]] = "{\\t(" .. tostring(tout) .. "," .. tostring(dur - ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\t(" .. tostring(dur - ctime*(n)) .. "," .. tostring(dur - ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                end
              end
            end
            --out L <- R no fade
          elseif dir[2] == rnofade then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n == cn then
                  t[p[i]] = "{\\t(" .. tostring(tout-1) .. "," .. tostring(tout) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\t(" .. tostring(dur - ctime*(n-1)-1) .. "," .. tostring(dur - ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                end
              end
            end
            --out -> C <-   
          elseif dir[2] == lr then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n < mid then
                  t[p[i]] = "{\\t(" .. tostring(tout + ctime*(n-1)) .. "," .. tostring(tout + ctime*n) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                elseif n == mid then
                  t[p[i]] = "{\\t(" .. tostring(tout + ctime*(n-1)) .. "," .. tostring(dur) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                else 
                  t[p[i]] = "{\\t(" .. tostring(tout + ctime*(cn-n)) .. "," .. tostring(tout + ctime*(cn-n+1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                end
              end
            end
            --out <- C ->  
          elseif dir[2] == rl then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n < mid then
                  t[p[i]] = "{\\t(" .. tostring(dur - ctime*n) .. "," .. tostring(dur - ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                elseif n == mid then
                  t[p[i]] = "{\\t(" .. tostring(tout) .. "," .. tostring(dur - ctime*(n-1)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                else 
                  t[p[i]] = "{\\t(" .. tostring(dur - ctime*(cn-n+1)) .. "," .. tostring(dur - ctime*(cn-n)) .. "," .. "\\alpha&HFF&)}" .. t[p[i]]
                end
              end
            end
          end
-- Y DIRECTION OUT
          if ydir[2] ~= none and (dir[2]==lnofade or dir[2]==rnofade or dir[2]==randnofade) then
            ADO("Note: Y-Direction effect is not applied. 'No fade' effects work with X-Direction only.\n")
          else
            yout = ydir[4]
            local yout2 = yout*2
            local yfirst = ""
            if ydir[1] == none or dir[1] == none or time[1] == 0 then
              yfirst = "\\fsvp0"
            end
            -- RANDOM
            if ydir[2] == rand then 
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp" .. math.random(-yout,yout))
                end
              end
              -- T -> M
            elseif ydir[2] == mt then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp" .. yout)
                end
              end
              -- M -> B  
            elseif ydir[2] == mb then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp-" .. yout)
                end
              end
              -- T <- M -> B  
            elseif ydir[2] == mtb then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  if n % 2 == 1 then
                    t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp" .. yout)
                  else
                    t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp-" .. yout)
                  end
                end
              end
              -- M -> T -> M  
            elseif ydir[2] == mtm then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp" .. yout2 .. ",\\fsvp0")

                  local isf = false; local isl = false
                  for j, v in ipairs(tfirst) do 
                    if n == v then 
                      isf = true
                      t[p[i]] = adjust_t(t[p[i]],0,ctime)
                    end
                  end
                  for j, v in ipairs(tlast) do
                    if n == v then  
                      isl = true
                      t[p[i]] = adjust_t(t[p[i]],-ctime,0) 
                    end
                  end
                  if not isf and not isl then
                    t[p[i]] = adjust_t(t[p[i]],-ctime,ctime)
                  end
                end
              end
              -- M -> B -> M  
            elseif ydir[2] == mbm then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp-" .. yout2 .. ",\\fsvp0")

                  local isf = false; local isl = false
                  for j, v in ipairs(tfirst) do 
                    if n == v then 
                      isf = true
                      t[p[i]] = adjust_t(t[p[i]],0,ctime)
                    end
                  end
                  for j, v in ipairs(tlast) do
                    if n == v then  
                      isl = true
                      t[p[i]] = adjust_t(t[p[i]],-ctime,0) 
                    end
                  end
                  if not isf and not isl then
                    t[p[i]] = adjust_t(t[p[i]],-ctime,ctime)
                  end
                end
              end
              -- SINE WAVE  
            elseif ydir[2] == sin then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  if n % 2 == 1 then
                    t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp" .. yout .. ",\\fsvp0")
                  else
                    t[p[i]] = add_to_t(t[p[i]],yfirst,"\\fsvp-" .. yout .. ",\\fsvp0")
                  end
                  local isf = false; local isl = false
                  for j, v in ipairs(tfirst) do 
                    if n == v then 
                      isf = true
                      t[p[i]] = adjust_t(t[p[i]],0,ctime)
                    end
                  end
                  for j, v in ipairs(tlast) do
                    if n == v then  
                      isl = true
                      t[p[i]] = adjust_t(t[p[i]],-ctime,0) 
                    end
                  end
                  if not isf and not isl then
                    t[p[i]] = adjust_t(t[p[i]],-ctime,ctime)
                  end
                end
              end  
            end
          end

--Z DIRECTION OUT
          if zdir[2] ~= none and (dir[2]==lnofade or dir[2]==rnofade or dir[2]==randnofade) then
            ADO("Note: Z-Direction effect is not applied. 'No fade' effects work with X-Direction only.\n")
          else
            zout = zdir[4]
            local zfirst = ""
            if zdir[1] == none or dir[1] == none or time[1] == 0 then
              zfirst = "\\z0"
            end 
            if zdir[2] == rand then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],zfirst,"\\z" .. math.random(-zout,zout))
                end
              end
            elseif zdir[2] == outscr then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],zfirst,"\\z-" .. zout)
                end
              end
            elseif zdir[2] == inscr then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],zfirst,"\\z" .. zout)
                end
              end
            end
          end
--COLOR OUT
          for i = 1,#p,1 do
            if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
              if bl[i] ~= "" then
                if bl[i]:find("\\%da&") then
                  for v in bl[i]:gmatch("\\%da&.-&") do 
                    orgAlpha = adjust_org_tag(orgAlpha,v)
                    orgAlpha = orgAlpha .. v
                    hasAlpha = true
                  end
                end
                if bl[i]:find("\\%dva%(") then
                  for v in bl[i]:gmatch("\\%dva.-%)") do
                    local j = v:match("\\(%d)va")
                    orgAlpha = adjust_org_tag(orgAlpha,v)
                    orgAlpha = orgAlpha:gsub("\\" .. j .. "a&.-&","")
                    orgAlpha = orgAlpha .. v
                    hasAlpha = true
                  end
                end
                if bl[i]:find("\\%d?c&") then
                  for v in bl[i]:gmatch("\\%d?c&.-&") do 
                    orgColor = adjust_org_tag(orgColor,v)
                    orgColor = orgColor .. v
                  end
                  if orgColor:find("\\c") and orgAlpha:find("1a&HFF&") then orgColor = orgColor:gsub("\\c&.-&", "") end
                  if orgColor:find("\\c") and not orgAlpha:find("1a") then orgAlpha = orgAlpha .. "\\1a&H00&" end
                  for j = 1,4,1 do
                    local k = tostring(j)
                    if orgColor:find(k .. "c") and orgAlpha:find(k .. "a&HFF&") then orgColor = orgColor:gsub("\\" .. k .. "c&.-&", "") end
                    if orgColor:find(k .. "c") and not orgAlpha:find(k .. "a") then orgAlpha = orgAlpha .. "\\" .. k .. "a&H00&" end
                  end
                  hasColor = true
                end
                if bl[i]:find("\\%dvc%(") then
                  for v in bl[i]:gmatch("\\%dvc.-%)") do 
                    orgColor = adjust_org_tag(orgColor,v)
                    orgColor = orgColor .. v
                  end
                  for j = 1,4,1 do
                    local k = tostring(j)  
                    if orgColor:find(k .. "vc") and not orgAlpha:find(k .. "va") then orgAlpha = orgAlpha .. "\\" .. k .. "a&H00&" end
                  end
                  hasColor = true
                end
              end
              if hasColor then
                if bl[i]:find("\\%dvc%(") then
                  t[p[i]] = t[p[i]]:gsub("\\%dvc.-%)","")
                end
                if bl[i]:find("\\%d?c&") then
                  t[p[i]] = t[p[i]]:gsub("\\%d?c&.-&","")
                end
              end
              if hasAlpha or hasAlpha_style then
                if bl[i]:find("\\%dva%(") then
                  t[p[i]] = t[p[i]]:gsub("\\%dva.-%)","")
                end
                if bl[i]:find("\\%da&") then 
                  t[p[i]] = t[p[i]]:gsub("\\%da&.-&","")
                end
              end
              if time[1] == 0 or dir[1] == none then 
                t[p[i]] = add_to_t(t[p[i]],orgColor .. orgAlpha,"")
              end
            end
          end          
--SCALE OUT

          if scale[1][3] or scale[3][3] then --outScaleX
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if bl[i] ~= "" then

                  if bl[i]:find("\\fsc%d+%.?%d*") then
                    orgScaleX = "\\fscx" .. bl[i]:match("\\fsc%d+%.?%d*"):gsub("\\fsc","")
                  else
                    if bl[i]:find("\\fscx%d+%.?%d*") then
                      orgScaleX = "\\fscx" .. bl[i]:match("\\fscx%d+%.?%d*"):gsub("\\fscx","")
                    end
                  end
                end
                t[p[i]] = t[p[i]]:gsub("\\fscx?%d+%.?%d*","")
                if (scale[1][1] == false and scale[3][1] == false) or dir[1] == none or time[1] == 0 then
                  t[p[i]] = add_to_t(t[p[i]],orgScaleX,"\\fscx" .. xScaleout)
                else
                  t[p[i]] = add_to_t(t[p[i]],"","\\fscx" .. xScaleout)
                end
              end
            end
          end

          if scale[2][3] or scale[3][3] then --scale y
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if bl[i] ~= "" then            
                  if bl[i]:find("\\fsc%d+%.?%d*") then
                    orgScaleY = "\\fscy" .. bl[i]:match("\\fsc%d+%.?%d*"):gsub("\\fsc","")
                  else  
                    if bl[i]:find("\\fscy%d+%.?%d*") then
                      orgScaleY = "\\fscy" .. bl[i]:match("\\fscy%d+%.?%d*"):gsub("\\fscy","")
                    end
                  end
                end
                t[p[i]] = t[p[i]]:gsub("\\fscy?%d+%.?%d*","")
                if (scale[2][1] == false and scale[3][1] == false) or dir[1] == none or time[1] == 0 then
                  t[p[i]] = add_to_t(t[p[i]],orgScaleY,"\\fscy" .. yScaleout)
                else
                  t[p[i]] = add_to_t(t[p[i]],"","\\fscy" .. yScaleout)
                end
              end
            end
          end
--ROTATION OUT

          if rot[1][3] then --outRotX
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if bl[i] ~= "" then
                  if bl[i]:find("\\frx%d+%.?%d*") then
                    orgRotX = "\\frx" .. bl[i]:match("\\frx(%d+%.?%d*)")
                  end
                end
                t[p[i]] = t[p[i]]:gsub("\\frx%d+%.?%d*","")
                if rot[1][1] == false or dir[1] == none or time[1] == 0 then
                  t[p[i]] = add_to_t(t[p[i]],orgRotX,"\\frx" .. xRotout)
                else
                  t[p[i]] = add_to_t(t[p[i]],"","\\frx" .. xRotout)
                end
              end
            end
          end

          if rot[2][3] then --outRotY
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if bl[i] ~= "" then
                  if bl[i]:find("\\fry%d+%.?%d*") then
                    orgRotY = "\\fry" .. bl[i]:match("\\fry(%d+%.?%d*)")
                  end
                end
                t[p[i]] = t[p[i]]:gsub("\\fry%d+%.?%d*","")
                if rot[2][1] == false or dir[1] == none or time[1] == 0 then
                  t[p[i]] = add_to_t(t[p[i]],orgRotY,"\\fry" .. yRotout)
                else
                  t[p[i]] = add_to_t(t[p[i]],"","\\fry" .. yRotout)
                end
              end
            end
          end

          if rot[3][3] then --outRotZ
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if bl[i] ~= "" then
                  if bl[i]:find("\\frz%d+%.?%d*") then
                    orgRotZ = "\\frz" .. bl[i]:match("\\frz(%d+%.?%d*)")
                  end
                end
                t[p[i]] = t[p[i]]:gsub("\\frz%d+%.?%d*","")
                if rot[3][1] == false or dir[1] == none or time[1] == 0 then
                  t[p[i]] = add_to_t(t[p[i]],orgRotZ,"\\frz" .. zRotout)
                else
                  t[p[i]] = add_to_t(t[p[i]],"","\\frz" .. zRotout)
                end
              end
            end
          end

--BLUR OUT

          if blur[3] then --outBlur
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if bl[i] ~= "" then
                  if bl[i]:find("\\blur%d+%.?%d*") then
                    orgBlur = "\\blur" .. bl[i]:match("\\blur(%d+%.?%d*)")
                  end
                end
                t[p[i]] = t[p[i]]:gsub("\\blur%d+%.?%d*","")
                if rot[1] == false or dir[1] == none or time[1] == 0 then
                  t[p[i]] = add_to_t(t[p[i]],orgBlur,"\\blur" .. blurout)
                else
                  t[p[i]] = add_to_t(t[p[i]],"","\\blur" .. blurout)
                end
              end
            end
          end
        end

--IN EFFECTS          
        if time[1] ~= 0 and dir[1] ~= none then
          local ctime
          for i, v in ipairs(ctime1) do
            if dir[1] == v then 
              if v == lnofade or v == rnofade or v == randnofade then 
                ctime = math.floor(time[1] / (cn-1))
              else
                ctime = math.floor(time[1] / cn) 
              end

            end
          end
          for i, v in ipairs(ctime2) do
            if dir[1] == v then ctime = math.floor(time[1] / mid) end
          end

          local tfirst, tlast = ctime_first_last(dir[1],cn,mid)
          -- RANDOM IN
          if dir[1] == rand then 
            local pOrder = {}
            for i = 1, #p, 1 do
              table.insert(pOrder,i)
            end
            shuffle(pOrder)
            n = 0
            for i = 1,#p,1 do
              local j = pOrder[i]
              if t[p[j]] ~= " " and t[p[j]] ~= "*N;" then
                n = n + 1 
                if i ~= #p then
                  t[p[j]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)) .. "," .. tostring(ctime*n) .. ",)}" .. t[p[j]]
                else
                  t[p[j]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)) .. "," .. tostring(time[1]) .. ",)}" .. t[p[j]]
                end
              end
            end

            -- RANDOM IN no fade
          elseif dir[1] == randnofade then 
            local pOrder = {}
            for i = 1, #p, 1 do
              table.insert(pOrder,i)
            end
            shuffle(pOrder)
            n = 0
            for i = 1,#p,1 do
              local j = pOrder[i]
              if t[p[j]] ~= " " and t[p[j]] ~= "*N;" then
                n = n + 1 
                if i==1 or n==1 then
                  t[p[j]] = "{\\alpha&HFF&\\t(" .. tostring(0) .. "," .. tostring(-1) .. ",)}" .. t[p[j]]
                elseif i ~= #p then
                  t[p[j]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)-1) .. "," .. tostring(ctime*(n-1)) .. ",)}" .. t[p[j]]
                else
                  t[p[j]] = "{\\alpha&HFF&\\t(" .. tostring(time[1]-1) .. "," .. tostring(time[1]) .. ",)}" .. t[p[j]]
                end
              end
            end

            -- L -> R
          elseif dir[1] == l then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if i ~= #p then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)) .. "," .. tostring(ctime*n) .. ",)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)) .. "," .. tostring(time[1]) .. ",)}" .. t[p[i]]
                end
              end
            end
            -- L -> R no fade
          elseif dir[1] == lnofade then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if i == 1 then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(0) .. "," .. tostring(-1) .. ",)}" .. t[p[i]]
                elseif i ~= #p then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)-1) .. "," .. tostring(ctime*(n-1)) .. ",)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(time[1]-1) .. "," .. tostring(time[1]) .. ",)}" .. t[p[i]]
                end
              end
            end
            -- L <- R
          elseif dir[1] == r then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n == cn then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(0) .. "," .. tostring(time[1] - ctime*(n-1)) .. ",)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(time[1] - ctime*(n)) .. "," .. tostring(time[1] - ctime*(n-1)) .. ",)}" .. t[p[i]]
                end
              end
            end
            -- L <- R no fade
          elseif dir[1] == rnofade then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n == cn then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(0) .. "," .. tostring(-1) .. ",)}" .. t[p[i]]
                else
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(time[1] - ctime*(n-1) - 1) .. "," .. tostring(time[1] - ctime*(n-1)) .. ",)}" .. t[p[i]]
                end
              end
            end
            -- -> C <-  
          elseif dir[1] == lr then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n < mid then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)) .. "," .. tostring(ctime*n) .. ",)}" .. t[p[i]]
                elseif n == mid then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(n-1)) .. "," .. tostring(time[1]) .. ",)}" .. t[p[i]]
                else 
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(ctime*(cn-n)) .. "," .. tostring(ctime*(cn-n+1)) .. ",)}" .. t[p[i]]
                end
              end
            end
            -- <- C ->  
          elseif dir[1] == rl then 
            n = 0
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                n = n + 1 
                if n < mid then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(time[1] - ctime*n) .. "," .. tostring(time[1] - ctime*(n-1)) .. ",)}" .. t[p[i]]
                elseif n == mid then
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(0) .. "," .. tostring(time[1] - ctime*(n-1)) .. ",)}" .. t[p[i]]
                else 
                  t[p[i]] = "{\\alpha&HFF&\\t(" .. tostring(time[1] - ctime*(cn-n+1)) .. "," .. tostring(time[1] - ctime*(cn-n)) .. ",)}" .. t[p[i]]
                end
              end
            end
          end

-- Y DIRECTION IN
          if ydir[1] ~= none and ydir[2] == none and (dir[1]==lnofade or dir[1]==rnofade or dir[1]==randnofade) and not (ydir[2] ~= none and (dir[2]==lnofade or dir[2]==rnofade or dir[2]==randnofade)) then
            ADO("Note: Y-Direction effect is not applied. 'No fade' effects work with X-Direction only.\n")
          else
            yin = ydir[3]
            local yin2 = yin*2
            --RANDOM
            if ydir[1] == rand then 
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],"\\fsvp" .. math.random(-yin,yin),"\\fsvp0")
                end
              end
              -- T -> M
            elseif ydir[1] == tm then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],"\\fsvp" .. yin,"\\fsvp0")
                end
              end
              -- B -> M  
            elseif ydir[1] == bm then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],"\\fsvp-" .. yin,"\\fsvp0")
                end
              end
              -- T -> M <- B  
            elseif ydir[1] == tbm then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  if n % 2 == 1 then
                    t[p[i]] = add_to_t(t[p[i]],"\\fsvp" .. yin,"\\fsvp0")
                  else
                    t[p[i]] = add_to_t(t[p[i]],"\\fsvp-" .. yin,"\\fsvp0")
                  end
                end
              end
              -- M -> T -> M  
            elseif ydir[1] == mtm then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  t[p[i]] = add_to_t(t[p[i]],"\\fsvp0","\\fsvp" .. yin2 .. ",\\fsvp0")

                  local isf = false; local isl = false
                  for j, v in ipairs(tfirst) do 
                    if n == v then 
                      isf = true
                      t[p[i]] = adjust_t(t[p[i]],0,ctime)
                    end
                  end
                  for j, v in ipairs(tlast) do
                    if n == v then  
                      isl = true
                      t[p[i]] = adjust_t(t[p[i]],-ctime,0) 
                    end
                  end
                  if not isf and not isl then
                    t[p[i]] = adjust_t(t[p[i]],-ctime,ctime)
                  end
                end
              end
              -- M -> B -> M  
            elseif ydir[1] == mbm then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  t[p[i]] = add_to_t(t[p[i]],"\\fsvp0","\\fsvp-" .. yin2 .. ",\\fsvp0")

                  local isf = false; local isl = false
                  for j, v in ipairs(tfirst) do 
                    if n == v then 
                      isf = true
                      t[p[i]] = adjust_t(t[p[i]],0,ctime)
                    end
                  end
                  for j, v in ipairs(tlast) do
                    if n == v then  
                      isl = true
                      t[p[i]] = adjust_t(t[p[i]],-ctime,0) 
                    end
                  end
                  if not isf and not isl then
                    t[p[i]] = adjust_t(t[p[i]],-ctime,ctime)
                  end
                end
              end
              -- SINE WAVE  
            elseif ydir[1] == sin then
              n = 0
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  n = n + 1
                  if n % 2 == 1 then
                    t[p[i]] = add_to_t(t[p[i]],"\\fsvp0","\\fsvp" .. yin2 .. ",\\fsvp0")
                  else
                    t[p[i]] = add_to_t(t[p[i]],"\\fsvp0","\\fsvp-" .. yin2 .. ",\\fsvp0")
                  end
                  local isf = false; local isl = false
                  for j, v in ipairs(tfirst) do 
                    if n == v then 
                      isf = true
                      t[p[i]] = adjust_t(t[p[i]],0,ctime)
                    end
                  end
                  for j, v in ipairs(tlast) do
                    if n == v then  
                      isl = true
                      t[p[i]] = adjust_t(t[p[i]],-ctime,0) 
                    end
                  end
                  if not isf and not isl then
                    t[p[i]] = adjust_t(t[p[i]],-ctime,ctime)
                  end
                end
              end  
            end
          end

--Z DIRECTION IN
          if zdir[1] ~= none and (dir[1]==lnofade or dir[1]==rnofade or dir[1]==randnofade) and not (zdir[2] ~= none and (dir[2]==lnofade or dir[2]==rnofade or dir[2]==randnofade)) then
            ADO("Note: Z-Direction effect is not applied. 'No fade' effects work with X-Direction only.\n")
          else
            zin = zdir[3]
            if zdir[1] == rand then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],"\\z" .. math.random(-zin,zin),"\\z0")
                end
              end
            elseif zdir[1] == outscr then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],"\\z" .. zin,"\\z0")
                end
              end
            elseif zdir[1] == inscr then
              for i = 1,#p,1 do
                if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                  t[p[i]] = add_to_t(t[p[i]],"\\z-" .. zin,"\\z0")
                end
              end
            end
          end

--COLOR IN
          orgColor = ""
          orgAlpha = styleAlpha
          for i = 1,#p,1 do
            if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
              if bl[i] ~= "" then
                if bl[i]:find("\\%da&") then
                  for v in bl[i]:gmatch("\\%da&.-&") do 
                    orgAlpha = adjust_org_tag(orgAlpha,v)
                    orgAlpha = orgAlpha .. v
                    hasAlpha = true
                  end
                end
                if bl[i]:find("\\%dva%(") then
                  if not orgAlpha:find("\\1a") then orgAlpha = orgAlpha .. "\\1a&H00&" end
                  if not orgAlpha:find("\\3a") then orgAlpha = orgAlpha .. "\\3a&H00&" end
                  if not orgAlpha:find("\\4a") then orgAlpha = orgAlpha .. "\\4a&H00&" end
                  for v in bl[i]:gmatch("\\%dva.-%)") do
                    local j = v:match("\\(%d)va")
                    orgAlpha = adjust_org_tag(orgAlpha,v)
                    orgAlpha = orgAlpha:gsub("\\" .. j .. "a&.-&","")
                    orgAlpha = orgAlpha .. v
                    hasAlpha = true
                  end
                end
                if bl[i]:find("\\%d?c&") then
                  for v in bl[i]:gmatch("\\%d?c&.-&") do 
                    orgColor = adjust_org_tag(orgColor,v)
                    orgColor = orgColor .. v
                  end
                  if orgColor:find("\\c") and orgAlpha:find("1a&HFF&") then orgColor = orgColor:gsub("\\c&.-&", "") end
                  if orgColor:find("\\c") and not orgAlpha:find("1a") then orgAlpha = orgAlpha .. "\\1a&H00&" end
                  for j = 1,4,1 do
                    local k = tostring(j)
                    if orgColor:find(k .. "c") and orgAlpha:find(k .. "a&HFF&") then orgColor = orgColor:gsub("\\" .. k .. "c&.-&", "") end
                    if orgColor:find(k .. "c") and not orgAlpha:find(k .. "a") then orgAlpha = orgAlpha .. "\\" .. k .. "a&H00&" end
                  end
                  hasColor = true
                end
                if bl[i]:find("\\%dvc%(") then
                  for v in bl[i]:gmatch("\\%dvc.-%)") do 
                    orgColor = adjust_org_tag(orgColor,v)
                    orgColor = orgColor .. v
                  end
                  for j = 1,4,1 do
                    local k = tostring(j)  
                    if orgColor:find(k .. "vc") and not orgAlpha:find(k .. "va") then orgAlpha = orgAlpha .. "\\" .. k .. "a&H00&" end
                  end
                  hasColor = true
                end
              end
              if hasColor then
                if bl[i]:find("\\%dvc%(") then
                  t[p[i]] = t[p[i]]:gsub("\\%dvc.-%)","")
                end
                if bl[i]:find("\\%d?c&") then
                  t[p[i]] = t[p[i]]:gsub("\\%d?c&.-&","")
                end
              end
              if hasAlpha or hasAlpha_style then
                if bl[i]:find("\\%dva%(") then
                  t[p[i]] = t[p[i]]:gsub("\\%dva.-%)","")
                  --t[p[i]] = t[p[i]]:gsub("\\alpha&H00&","")
                end
                if bl[i]:find("\\%da&") then 
                  t[p[i]] = t[p[i]]:gsub("\\%da&.-&","")
                  --t[p[i]] = t[p[i]]:gsub("\\alpha&H00&","")
                end
              end

              t[p[i]] = add_to_t(t[p[i]],"",orgAlpha)
              t[p[i]] = add_to_t(t[p[i]],orgColor,"")

            end
          end

--SCALE IN
          if scale[1][1] or scale[3][1] then --inScaleX
            --orgScaleX = "\\fscx100"
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if scale[1][3] == false and scale[3][3] == false then
                  if bl[i] ~= "" then
                    if bl[i]:find("\\fsc%d+%.?%d*") then
                      orgScaleX = "\\fscx" .. bl[i]:match("\\fsc%d+%.?%d*"):gsub("\\fsc","")
                    else
                      if bl[i]:find("\\fscx%d+%.?%d*") then
                        orgScaleX = "\\fscx" .. bl[i]:match("\\fscx%d+%.?%d*"):gsub("\\fscx","")
                      end
                    end
                  end
                  t[p[i]] = t[p[i]]:gsub("\\fscx?%d+%.?%d*","")
                end
                t[p[i]] = add_to_t(t[p[i]],"\\fscx" .. xScalein,orgScaleX)
              end
            end
          end

          if scale[2][1] or scale[3][1] then --inScaleY 
            --orgScaleY = "\\fscy100"
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if scale[2][3] == false and scale[3][3] == false then

                  if bl[i] ~= "" then
                    if bl[i]:find("\\fsc%d+%.?%d*") then
                      orgScaleY = "\\fscy" .. bl[i]:match("\\fsc%d+%.?%d*"):gsub("\\fsc","")
                    else
                      if bl[i]:find("\\fscy%d+%.?%d*") then
                        orgScaleY = "\\fscy" .. bl[i]:match("\\fscy%d+%.?%d*"):gsub("\\fscy","")
                      end
                    end
                  end
                  t[p[i]] = t[p[i]]:gsub("\\fscy?%d+%.?%d*","")
                end
                t[p[i]] = add_to_t(t[p[i]],"\\fscy" .. yScalein,orgScaleY)
              end
            end
          end

--ROTATION IN
          if rot[1][1] then --inRotX
            --orgRotX = "\\frx0"
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if rot[1][3] == false then 
                  if bl[i] ~= "" then
                    if bl[i]:find("\\frx%d+%.?%d*") then
                      orgRotX = "\\frx" .. bl[i]:match("\\frx(%d+%.?%d*)")
                    end
                  end
                  t[p[i]] = t[p[i]]:gsub("\\frx%d+%.?%d*","")
                end
                t[p[i]] = add_to_t(t[p[i]],"\\frx" .. xRotin,orgRotX)
              end
            end
          end

          if rot[2][1] then --inRotY
            --orgRotY = "\\fry0"
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if rot[2][3] == false then
                  if bl[i] ~= "" then
                    if bl[i]:find("\\fry%d+%.?%d*") then
                      orgRotY = "\\fry" .. bl[i]:match("\\fry(%d+%.?%d*)")
                    end
                  end
                  t[p[i]] = t[p[i]]:gsub("\\fry%d+%.?%d*","")
                end
                t[p[i]] = add_to_t(t[p[i]],"\\fry" .. yRotin,orgRotY)
              end
            end
          end

          if rot[3][1] then --inRotZ
            --orgRotZ = "\\frz0"
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if rot[3][3] == false then
                  if bl[i] ~= "" then
                    if bl[i]:find("\\frz%d+%.?%d*") then
                      orgRotZ = "\\frz" .. bl[i]:match("\\frz(%d+%.?%d*)")
                    end
                  end
                  t[p[i]] = t[p[i]]:gsub("\\frz%d+%.?%d*","")
                end
                t[p[i]] = add_to_t(t[p[i]],"\\frz" .. zRotin,orgRotZ)
              end
            end
          end

--BLUR IN
          if blur[1] then --inBlur
            for i = 1,#p,1 do
              if t[p[i]] ~= " " and t[p[i]] ~= "*N;" then
                if blur[3] == false then
                  --orgBlur = "\\blur0"
                  if bl[i] ~= "" then
                    if bl[i]:find("\\blur%d+%.?%d*") then
                      orgBlur = "\\blur" .. bl[i]:match("\\blur(%d+%.?%d*)")
                    end
                  end
                  t[p[i]] = t[p[i]]:gsub("\\blur%d+%.?%d*","")
                end
                t[p[i]] = add_to_t(t[p[i]],"\\blur" .. blurin,orgBlur)
              end
            end
          end
        end

        for i, v in ipairs(bl) do
          if v ~= "" then
            local head, tail = sort_tag(v)
            t[p[i]] = head .. t[p[i]]
            t[p[i]] = clean(t[p[i]])
          end
        end

        for i, v in ipairs(t) do
          temptext = temptext .. v
        end
      end --char or word
      line.text = temptext:gsub("*N;","\\N")
    end
    line.text = line.text:gsub("{+{","{"):gsub("}+}","}"):gsub("}{","")
    line.text = line.text .. orgline
    sub[li] = line
  end    

end

function get_org_tag(text) --get flexible tag
  local org = ""
  if text:find("^{.-}") then
    org = text:match("{(.-)}"):gsub("\\pos.-%)",""):gsub("\\move.-%)",""):gsub("\\i?clip.-%)",""):gsub("\\org.-%)",""):gsub("\\fade?.-%)",""):gsub("\\an?%d",""):gsub("\\p(bo)?-?%d+",""):gsub("\\%dvc?a?.-%)",""):gsub("\\%dimg.-%)","")
  end
  return org
end

function add_to_t(str, before, after) --fisrt \t in string
  local t = str:match("\\t.-%)")
  t = t:gsub("\\t", before .. "\\t",1):gsub("%)", after .. "%)",1)
  str = str:gsub("\\t.-%)",t,1)
  return str
end

function adjust_t(str, a1, a2)
  local t = str:match("\\t.-%)")
  local t1; local t2
  local table = {t1, t2}
  local i = 1
  t1 = tonumber(t:match("%d+"))
  t2 = tonumber(t:match(",%d+,"):match("%d+"))
  t1 = t1 + a1
  t2 = t2 + a2
  t = t:gsub("t%(%d+,%d+","t%(" .. t1 .. "," .. t2,1)
  str = str:gsub("\\t.-%)",t,1)
  return str
end

function ctime_first_last(xdirection,cn,mid)
  local first = {}; local last = {}
  if xdirection == l then 
    first = {1}
    last = {cn}
  elseif xdirection == r then
    first = {cn}
    last = {1}
  elseif xdirection == lr then
    first = {1,cn}
    last = {mid,mid+1}
  elseif xdirection == rl then
    first = {mid, mid+1}
    last = {1,cn}
  end
  return first, last
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
function adjust_org_tag(org, new)
  local tag = {"\\c&.-&","\\1c&.-&","\\2c&.-&","\\3c&.-&","\\4c&.-&", "\\alpha%w+","\\1a&.-&","\\2a&.-&","\\3a&.-&", "\\4a&.-&","\\1vc.-%)","\\2vc.-%)","\\3vc.-%)","\\4vc.-%)","\\1va.-%)","\\2va.-%)","\\3va.-%)","\\4va.-%)","\\fscx%d+%.?%d*", "\\fscy%d+%.?%d*","\\fsc%d+%.?%d*", "\\fs%d+%.?%d*", "\\fsp%d+%.?%d*", "\\i%d", "\\b%d+%.?%d*", "\\u%d", "\\s%d", "\\bord%d+%.?%d*", "\\xbord%d+%.?%d*", "\\ybord%d+%.?%d*", "\\shad%d+%.?%d*", "\\xshad-?%d+%.?%d*", "\\yshad-?%d+%.?%d*", "\\be%d+%.?%d*", "\\blur%d+%.?%d*", "\\fn%w", "\\fr-?%d+%.?%d*", "\\frx-?%d+%.?%d*", "\\fry-?%d+%.?%d*", "\\frz-?%d+%.?%d*", "\\fa-?%d+%.?%d*", "\\fax-?%d+%.?%d*", "\\fay-?%d+%.?%d*"}

  for i = 1, #tag, 1 do
    local s = tag[i]
    if org:find(s) and new:find(s) then
      org = org:gsub(s, "", 1)
    end
  end
  return org
end

function r_to_tag(styles, line, block)
  local s = styles[line.style]
  local temp = ""
  temp = "\\fs" .. s.fontsize .. "\\c" .. s.color1 .. "\\3c" .. s.color3 .. "\\4c" .. s.color4 .. "\\fscx" .. s.scale_x .. "\\fscy" .. s.scale_y .. "\\fr" .. s.angle .. "\\bord" .. s.outline .. "\\shad" .. s.shadow
  temp = adjust_org_tag(temp, block)
  block = block:gsub("\\r", temp)
  return block
end

function get_pos_from_an(curX,curY,curAn,newAn,line)
  if curAn ~= newAn then
    curX = tonumber(curX); curY = tonumber(curY)
    local w2 = line.width; local w = w2/2; local h2 = line.height; local h = h2/2
    local x1; local y1
    curAn = tonumber(curAn)
    if curAn == 1 then 
      x1 = curX; y1 = curY
    elseif curAn == 2 then
      x1 = curX - w; y1 = curY
    elseif curAn == 3 then
      x1 = curX - w2; y1 = curY
    elseif curAn == 4 then 
      x1 = curX; y1 = curY + h
    elseif curAn == 5 then 
      x1 = curX - w; y1 = curY + h
    elseif curAn == 6 then 
      x1 = curX - w2; y1 = curY + h  
    elseif curAn == 7 then 
      x1 = curX; y1 = curY + h2
    elseif curAn == 8 then 
      x1 = curX - w; y1 = curY + h2
    elseif curAn == 9 then 
      x1 = curX - w2; y1 = curY + h2
    end
    local pan = {{x1,y1},{x1+w,y1},{x1+w2,y1},{x1,y1-h},{x1+w,y1-h},{x1+w2,y1-h},{x1,y1-h2},{x1+w,y1-h2},{x1+w2,y1-h2}}
    return pan[tonumber(newAn)][1], pan[tonumber(newAn)][2]
  end
  return curX, curY
end

function p_default(line)
  local marl = line.margin_l
  local marr = line.margin_r
  local mart = line.margin_t
  local marb = line.margin_b
  local p = {{marl,yres-marb},{xres/2,yres-marb},{xres-marr,yres-marb},{marl,yres/2},{xres/2,yres/2},{xres-marr,yres/2},{marl,mart},{xres/2,mart},{xres-marr,mart}}
  return p
end


function sort_tag(block)
  local headTag = {"\\pos.-%)","\\move.-%)","\\clip.-%)","\\iclip.-%)","\\org.-%)","\\fad.-%)","\\fade.-%)","\\a%d","\\an%d","\\p%d+","\\pbo-?%d+","\\1vc.-%)","\\2vc.-%)","\\3vc.-%)","\\4vc.-%)","\\1va.-%)","\\2va.-%)","\\3va.-%)","\\4va.-%)","\\1img.-%)","\\2img.-%)","\\3img.-%)","\\4img.-%)"}
  local head = ""
  local tail = ""
  for i = 1,#headTag,1 do
    if block:find(headTag[i]) then
      head = head .. block:match(headTag[i])
    end
  end
  head = "{" .. head .. "}"
  tail = "{" .. get_org_tag(block) .. "}"
  return head, tail
end


function shuffle(table)
  math.randomseed(os.time())
  for i = #table, 2, -1 do
    local j = math.random(i)
    table[i], table[j] = table[j], table[i]
  end
end

function clean(text)
  if text:find("\\1img") then
    text = text:gsub("\\1vc.-%)",""):gsub("\\1?c&.-&","")
  elseif text:find("\\1vc") then 
    text = text:gsub("\\1?c&.-&","")
  end
  if text:find("\\1va") then 
    text = text:gsub("\\1a&.-&","")
  end 
  for i = 2,4,1 do 
    if text:find("\\" .. i .. "img") then
      text = text:gsub("\\" .. i .. "vc.-%)",""):gsub("\\" .. i .. "c&.-&","")
    elseif text:find("\\" .. i .. "vc") then 
      text = text:gsub("\\" .. i .. "c&.-&","")
    end
    if text:find("\\" .. i .. "va") then 
      text = text:gsub("\\" .. i .. "a&.-&","")
    end 
  end
  return text
end


function savePreset(name,res)

  local var_res = {res.inT,res.outT,res.inF,res.outF,res.inD,res.outD,res.inDy,res.outDy,res.inY,res.outY,res.inDz,res.outDz,res.inZ,res.outZ,res.inScaleX,res.inScaleX_val,res.outScaleX,res.outScaleX_val,res.inScaleY,res.inScaleY_val,res.outScaleY,res.outScaleY_val,res.inScale,res.inScale_val,res.outScale,res.outScale_val,res.inRotX,res.inRotX_val,res.outRotX,res.outRotX_val,res.inRotY,res.inRotY_val,res.outRotY,res.outRotY_val,res.inRotZ,res.inRotZ_val,res.outRotZ,res.outRotZ_val,res.inBlur,res.inBlur_val,res.outBlur,res.outBlur_val,res.align,res.align_val}

  local var = {"tin","tout","fin","fout","dirin","dirout","ydirin","ydirout","yin","yout","zdirin","zdirout","zin","zout","fscxin","xScalein","fscxout","xScaleout","fscyin","yScalein","fscyout","yScaleout","fscin","scalein","fscout","scaleout","frxin","xRotin","frxout","xRotout","fryin","yRotin","fryout","yRotout","frzin","zRotin","frzout","zRotout","blin","blurin","blout","blurout","anFlag","an"}

  local f = io.open(presetPath,"a")
  f:write("preset=" .. name .. ";")
  for i = 1,#var,1 do
    if type(var_res[i]) == "string" then 
      f:write(var[i] .. "=\'" .. tostring(var_res[i]) .. "\';")
    else
      f:write(var[i] .. "=" .. tostring(var_res[i]) .. ";")
    end
  end
  f:write("\n")
  f:close()
end

function loadPreset(p)
  local f = io.open(presetPath,"r")
  for line in f:lines() do
    if line:match("preset=(.-);") == p then
      local temp = line:gsub("preset=.-;","",1)
      for v in temp:gmatch("(.-);") do
        local code = loadstring(v)
        code()
      end
      break
    end
  end
  f:close()
end

function removePreset(p)
  local f = io.open(presetPath,"r")
  local list = {}
  for line in f:lines() do
    if line:match("preset=(.-);") ~= p then
      table.insert(list,line)
    end
  end
  f:close()
  f = io.open(presetPath,"w")
  for i=1,#list,1 do
    f:write(list[i] .. "\n")
  end
  f:close()
end

function renamePreset(cur,new)
  local f = io.open(presetPath,"r")
  local list={}
  for line in f:lines() do
    if line:match("preset=(.-);") == cur then
      line = line:gsub("preset=.-;","preset=" .. new .. ";",1)
    end
    table.insert(list,line)
  end
  f:close()
  f = io.open(presetPath,"w")
  for i=1,#list,1 do
    f:write(list[i] .. "\n")
  end
  f:close()
end

function updatePreset(p,res)
  msg = [[Are you sure you want to update Preset "]] .. p .. [[" with current values?]]
  local updatePreset_GUI = {
    { class = "label", x=0, y=0, width=2, height=1, label=msg}
  }
  local updatePreset_buttons = {"YES","NO"}
  updatePreset_choice,updatePreset_res = ADD(updatePreset_GUI,updatePreset_buttons)
  if updatePreset_choice == "YES" then
    removePreset(p)
    savePreset(p,res)
    loadPreset(p)
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

function updateGUI()
  local g = 
  {
    -- position labels
    { class = "label", x = 1, y = 0, width = 1, height = 1, label = "In"},
    { class = "label", x = 2, y = 0, width = 1, height = 1, label = "Out"},

    { class = "label", x = 0, y = 1, width = 1, height = 1, label = "Time (ms)"},
    { class = "floatedit", x = 1, y = 1, width = 1, height = 1, min = 0, max  = 10000000, value = tin, name = "inT", hint = "You can choose values between 0 and 1 to make time relative to line duration (for example: 0.2)"},
    { class = "floatedit", x = 2, y = 1, width = 1, height = 1, min = 0, max  = 10000000, value = tout, name = "outT", hint = "You can choose values between 0 and 1 to make time relative to line duration (for example: 0.2)"},

    { class = "label", x = 0, y = 2, width = 1, height = 1, label = "Fade (ms)"},
    { class = "floatedit", x = 1, y = 2, width = 1, height = 1, min = 0, max  = 10000000, value = fin, name = "inF", hint = "You can choose values between 0 and 1 to make time relative to line duration (for example: 0.2)"},
    { class = "floatedit", x = 2, y = 2, width = 1, height = 1, min = 0, max  = 10000000, value = fout, name = "outF", hint = "You can choose values between 0 and 1 to make time relative to line duration (for example: 0.2)"},

    { class = "label", x = 0, y = 3, width = 1, height = 1, label = "X Direction"},
    { class = "dropdown", x = 1, y = 3, width = 1, height = 1, items = {"None", "Random", "Random no fade", "L -> R","L -> R no fade", "L <- R", "L <- R no fade","-> C <-","<- C ->"}, value = dirin, name = "inD", hint = "L = Left, R = Right, C = Center"},
    { class = "dropdown", x = 2, y = 3, width = 1, height = 1, items = {"None", "Random", "Random no fade", "L -> R","L -> R no fade", "L <- R", "L <- R no fade","-> C <-","<- C ->"}, value = dirout, name = "outD", hint = "L = Left, R = Right, C = Center"},

    { class = "label", x = 0, y = 4, width = 1, height = 1, label = "Y Direction"},
    { class = "dropdown", x = 1, y = 4, width = 1, height = 1, items = {"None", "Random", "T -> M", "B -> M", "T -> M <- B", "M -> T -> M", "M -> B -> M", "SINE WAVE"}, value = ydirin, name = "inDy", hint = "T = Top, M = Middle, B = Bottom"},
    { class = "dropdown", x = 2, y = 4, width = 1, height = 1, items = {"None", "Random", "M -> T", "M -> B", "T <- M -> B", "M -> T -> M", "M -> B -> M", "SINE WAVE"}, value = ydirout, name = "outDy", hint = "T = Top, M = Middle, B = Bottom"},
    { class = "label", x = 0, y = 5, width = 1, height = 1, label = "Y Value"},
    { class = "floatedit", x = 1, y = 5, width = 1, height = 1, min = 0, max  = 10000000, value = yin, name = "inY", hint = "Value for \\fsvp"},
    { class = "floatedit", x = 2, y = 5, width = 1, height = 1, min = 0, max  = 10000000, value = yout, name = "outY", hint = "Value for \\fsvp"},

    { class = "label", x = 0, y = 6, width = 1, height = 1, label = "Z Direction"},
    { class = "dropdown", x = 1, y = 6, width = 1, height = 1, items = {"None", "Random", "Out of Screen", "Into Screen"}, value = zdirin, name = "inDz"},
    { class = "dropdown", x = 2, y = 6, width = 1, height = 1, items = {"None", "Random", "Out of Screen", "Into Screen"}, value = zdirout, name = "outDz"},
    { class = "label", x = 0, y = 7, width = 1, height = 1, label = "Z Value"},
    { class = "floatedit", x = 1, y = 7, width = 1, height = 1, min = 0, max  = 10000000, value = zin, name = "inZ", hint = "Value for \\z"},
    { class = "floatedit", x = 2, y = 7, width = 1, height = 1, min = 0, max  = 10000000, value = zout, name = "outZ", hint = "Value for \\z"},
--ADDITIONAL EFFECTS
    { class = "label", x = 4, y = 0, width = 1, height = 1, label = "In"},
    { class = "label", x = 6, y = 0, width = 1, height = 1, label = "Out"},

    { class = "checkbox", x = 3, y = 1, width = 1, height = 1, value = fscxin, label = "fscx", name = "inScaleX"},
    { class = "floatedit", x = 4, y = 1, width = 1, height = 1, min = 0, max  = 10000000, value = xScalein, name = "inScaleX_val"},
    { class = "checkbox", x = 5, y = 1, width = 1, height = 1, value = fscxout, label = "fscx", name = "outScaleX"},
    { class = "floatedit", x = 6, y = 1, width = 1, height = 1, min = 0, max  = 10000000, value = xScaleout, name = "outScaleX_val"},

    { class = "checkbox", x = 3, y = 2, width = 1, height = 1, value = fscyin, label = "fscy", name = "inScaleY"},
    { class = "floatedit", x = 4, y = 2, width = 1, height = 1, min = 0, max  = 10000000, value = yScalein, name = "inScaleY_val"},
    { class = "checkbox", x = 5, y = 2, width = 1, height = 1, value = fscyout, label = "fscy", name = "outScaleY"},
    { class = "floatedit", x = 6, y = 2, width = 1, height = 1, min = 0, max  = 10000000, value = yScaleout, name = "outScaleY_val"},

    { class = "checkbox", x = 3, y = 3, width = 1, height = 1, value = fscin, label = "fsc", name = "inScale"},
    { class = "floatedit", x = 4, y = 3, width = 1, height = 1, min = 0, max  = 10000000, value = scalein, name = "inScale_val"},
    { class = "checkbox", x = 5, y = 3, width = 1, height = 1, value = fscout, label = "fsc", name = "outScale"},
    { class = "floatedit", x = 6, y = 3, width = 1, height = 1, min = 0, max  = 10000000, value = scaleout, name = "outScale_val"},

    { class = "checkbox", x = 3, y = 4, width = 1, height = 1, value = frxin, label = "frx", name = "inRotX"},
    { class = "floatedit", x = 4, y = 4, width = 1, height = 1, min = -10000000, max  = 10000000, value = xRotin, name = "inRotX_val"},
    { class = "checkbox", x = 5, y = 4, width = 1, height = 1, value = frxout, label = "frx", name = "outRotX"},
    { class = "floatedit", x = 6, y = 4, width = 1, height = 1, min = -10000000, max  = 10000000, value = xRotout, name = "outRotX_val"},

    { class = "checkbox", x = 3, y = 5, width = 1, height = 1, value = fryin, label = "fry", name = "inRotY"},
    { class = "floatedit", x = 4, y = 5, width = 1, height = 1, min = -10000000, max  = 10000000, value = yRotin, name = "inRotY_val"},
    { class = "checkbox", x = 5, y = 5, width = 1, height = 1, value = fryout, label = "fry", name = "outRotY"},
    { class = "floatedit", x = 6, y = 5, width = 1, height = 1, min = -10000000, max  = 10000000, value = yRotout, name = "outRotY_val"},

    { class = "checkbox", x = 3, y = 6, width = 1, height = 1, value = frzin, label = "frz", name = "inRotZ"},
    { class = "floatedit", x = 4, y = 6, width = 1, height = 1, min = -10000000, max  = 10000000, value = zRotin, name = "inRotZ_val"},
    { class = "checkbox", x = 5, y = 6, width = 1, height = 1, value = frzout, label = "frz", name = "outRotZ"},
    { class = "floatedit", x = 6, y = 6, width = 1, height = 1, min = -10000000, max  = 10000000, value = zRotout, name = "outRotZ_val"},

    { class = "checkbox", x = 3, y = 7, width = 1, height = 1, value = blin, label = "blur", name = "inBlur"},
    { class = "floatedit", x = 4, y = 7, width = 1, height = 1, min = 0, max  = 10000000, value = blurin, name = "inBlur_val"},
    { class = "checkbox", x = 5, y = 7, width = 1, height = 1, value = blout, label = "blur", name = "outBlur"},
    { class = "floatedit", x = 6, y = 7, width = 1, height = 1, min = 0, max  = 10000000, value = blurout, name = "outBlur_val"},

    { class = "checkbox", x = 5, y = 8, width = 1, height = 1, value = anFlag, label = "an", name = "align"},
    { class = "dropdown", x = 6, y = 8, width = 1, height = 1, items = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}, value = an, name = "align_val"},
    { class = "label", x = 0, y = 8, width = 1, height = 1, label = "Presets"},
    { class = "dropdown", x = 1, y = 8, width = 4, height = 1, items = presetList, value = curPreset, name = "preset"}
  }
  return g
end

--send to Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)