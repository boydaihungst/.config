script_name="@TRAMBO: Curved Text"
script_description="Curved Text"
script_author="TRAMBO"
script_version="1.0"

include("Trambo.Library.lua") --ver 1.4

function main(sub, sel, act)
  meta, styles = karaskel.collect_head(sub, false)
  log = aegisub.log
  for si,li in ipairs(sel) do
    tins = table.insert
    pos = {}
    points = {}
    line = sub[li];
    karaskel.preproc_line(sub, meta, styles, line)
    ltext = line.text
    clip = ltext:match("\\i?clip%((.-)%)");
    if clip:find("l") then
      log("Please use bezier curve only")
      return sel
    end
    
    lx = line.x
    ly = line.y
    if ltext:find("\\pos%b()") then
      lx,ly = ltext:match("\\pos%((%d+%.?%d*),(%d+%.?%d*)%)")
    end

    temptext = ""
    
    -- get points from \clip
    for v in clip:gmatch("%d+%.?%d*") do
      tins(points,tonumber(v))
    end

    px = {}
    py = {}
    for i=1,#points,1 do
      if i % 2 == 0 then
        tins(py,points[i])
      else
        tins(px,points[i])
      end
    end
    if ltext:find("\\frz%d+%.?%d*") then
      angle = tonumber(ltext:match("\\frz(-?%d+%.?%d*)"))
      for i=1,#px,1 do
        px[i],py[i] = rotatedPoint(px[i],py[i],lx,ly,angle)
      end
    end
    anchor_i = {}
    for i=1,#px,1 do
      if i % 3 == 1 then
        tins(anchor_i,i)
      end
    end
    clip_length = px[#px] - px[1]
    tmap_list = {} -- {(xt -> t),(xt -> t),...}
    for seg = 1,#anchor_i-1,1 do
      tmap = {} 
      k = anchor_i[seg]
      lseg = px[k+3] - px[k] 
      step = 1/lseg
      step = tonumber(string.format("%.4f", step)) -- lseg < 10000
      for t=0,1,step do
        x1 = px[k]
        x2 = px[k+1]
        x3 = px[k+2]
        x4 = px[k+3]
        xt = ((1-t)^3)*x1 + 3*((1-t)^2)*t*x2 + 3*(1-t)*(t^2)*x3 + (t^3)*x4 
        xt = math.floor(xt+0.5);
        tmap[xt] = t
      end
      tins(tmap_list,tmap)
    end


    tchar,tpos,bl = getToken(line.text,'c',true)
    --Beizier curve
    for i=1,#tchar,1 do
      y1,y2,y3,y4,yt = 0,0,0,0
      xper = (i-0.5)/#tchar
      xt = clip_length*xper + px[1]
      xt = math.floor(xt+0.5);
      for an = 2,#anchor_i,1 do
        j = anchor_i[an]
        k = anchor_i[an-1]
        if xt < px[j] and tchar[i] ~= " " then
          iseg = an-1
          if tmap_list[iseg][xt] == nil then
            found = false
            n = 1
            while not found do
              if tmap_list[iseg][xt+n] ~= nil then
                t = tmap_list[iseg][xt+n]
                found = true
              elseif tmap_list[iseg][xt-n] ~= nil then
                t = tmap_list[iseg][xt-n]
                found = true
              end
              n = n+1
            end
          else
            t = tmap_list[iseg][xt]
          end
          
          x1 = px[k]
          x2 = px[k+1]
          x3 = px[k+2]
          x4 = px[k+3]
          y1 = py[k]
          y2 = py[k+1]
          y3 = py[k+2]
          y4 = py[k+3]
          yt = ((1-t)^3)*y1 + 3*((1-t)^2)*t*y2 + 3*(1-t)*(t^2)*y3 + (t^3)*y4 ; --log("``yt: " .. yt .. "\n");
          
          fsvp = ly - yt
          tchar[i] = bl[i] .. string.format([[{\fsvp%.3f}]],fsvp) .. tchar[i];
          break
        end

      end

      temptext = temptext .. tchar[i]
    end


    line.text = temptext:gsub("}{",""):gsub("\\i?clip%b()","")
    sub[li] = line
  end
  return sel
end



--send to Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)