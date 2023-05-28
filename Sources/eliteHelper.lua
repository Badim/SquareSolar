module(..., package.seeall);

if(_G.scaleGraphics==nil)then _G.scaleGraphics=2; end
if(_G.options_txt_offset==nil)then _G.options_txt_offset=0; end
if _G.elite==nil then _G.elite={}; end
-------------------------------
_G.rnd = math.random;
-------------------------------
function _G.loadFile(fname, directory)
	if not directory then directory = system.DocumentsDirectory; end
	local path =  system.pathForFile(fname, directory);
	if(path)then
		local file = io.open( path, "r" );
		if (file) then
			local contents = file:read( "*a" );
			io.close(file);
			if(contents and #contents>0)then
				return contents;
			end
		end
	end
	return nil
end
function _G.saveFile(fname, save_str)
	local path = system.pathForFile( fname, system.DocumentsDirectory);
	local file = io.open(path, "w+b");
	if file then
		--local save_str = Json.Encode(login_obj);
		file:write(save_str);          
		io.close( file )
		print("Saving("..fname.."): ok!")
	else
		print("Saving("..fname.."): fail!")
	end
end
-----------------------------
table.length = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
table.count = function(source, val)
	local i=0;
	for j=1,#source do
		if(source[j]==val)then
			i=i+1;
		end
	end
	return i;
end
table.keys = function(source)
  local result = {}
  for k,v in pairs(source) do
    table.insert(result, k);
  end
  return result
end
function table.shuffle(t)
  local n = #t
  while n > 2 do
    local k = math.random(n);
    t[n], t[k] = t[k], t[n];
    n = n - 1;
  end
  return t
end
table.random = function(source)
  return source[math.random(1, #source)]
end
table.clone = function(t)
	local n={};
	for i=1,#t do
		n[i]=t[i];
	end
	return n;
end
table.cloneEx = function(t,f)
	local n={};
	for i=1,#t do
		n[i]=f(t[i]);
	end
	return n;
end

table.getIdByRef = function(t, _obj)
	for i=#t,1,-1 do
		local obj = t[i];
		if(_obj==obj)then
			return i;
		end
	end
	for attr,obj in pairs(t) do
		if(_obj==obj)then
			return attr;
		end
	end
	return nil;
end
table.removeByRef = function(t, _obj)
	for i=#t,1,-1 do
		local obj = t[i];
		if(_obj==obj)then
			table.remove(t, i);
			return true;
		end
	end
	for attr,obj in pairs(t) do
		if(_obj==obj)then
			t[attr] = nil;
			return true;
		end
	end
	return false;
end
	
	_G.getTimer = system.getTimer;
	
	function _G.newGroup(parent)
		local mc = display.newGroup();
		parent:insert(mc);
		return mc
	end
	function _G.cleanGroup(mc)
		while(mc.numChildren>0)do
			mc[1]:removeSelf();
		end
	end
	
function _G.booleanToSwitch(bol)
	if(bol)then
		return 'on';
	else
		return 'off';
	end
end
function _G.booleanToNumber(bol)
	if(bol)then
		return 1;
	else
		return 0;
	end
end
	
	function _G.getDD(p1,p2)
		local dx=p2.x-p1.x;
		local dy=p2.y-p1.y;
		return dx*dx+dy*dy, dx, dy;
	end

	function _G.getRD(p1,p2)
		local dx=p2.x-p1.x;
		local dy=p2.y-p1.y;
		return math.max(math.abs(dx), math.abs(dy));
	end
	
	function _G.sign(x)
	  return (x<0 and -1) or 1;
	end
	function _G.dAngleRadian(a1, a2)
		local da = a1-a2;
		if (da>math.pi) then
			da = -math.pi*2+da;
		elseif(da<-math.pi)then
			da = math.pi*2+da;
		end
		return da;
	end
	function _G.get_dd(p1, p2)
		local dx=p2.x-p1.x;
		local dy=p2.y-p1.y;
		return dx*dx+dy*dy;
	end
	function _G.get_dd_ex(x1,y1,x2,y2)
		local dx=x2-x1;
		local dy=y2-y1;
		return dx*dx+dy*dy;
	end
	function _G.distance(p1, p2)
		local dx=p2.x-p1.x;
		local dy=p2.y-p1.y;
		local dd=dx*dx+dy*dy;
		return math.sqrt(dd), dx, dy
	end
	function _G.distanceEx(x1,y1,x2,y2)
		local dx=x2-x1;
		local dy=y2-y1;
		local dd=dx*dx+dy*dy;
		return math.sqrt(dd), dx, dy
	end
	
	function _G.hit_test(mc, rr, tx, ty)
		if(mc.x and mc.y)then
			local dx, dy = mc.x - tx, mc.y - ty;
			local dd = dx*dx+dy*dy;
			if(dd<rr)then
				return true
			end
		end
		return false
	end
	function _G.hit_test_rec(mc,w,h,tx,ty)
		if(mc.x and mc.y)then
			if(tx>mc.x-w/2 and tx<mc.x+w/2)then
				if(ty>mc.y-h/2 and ty<mc.y+h/2)then
					return true
				end
			end
		end
		return false
	end
	function _G.hit_test_rec_ex(mcx, mcy, w, h, tx, ty)
		if(tx>mcx-w/2 and tx<mcx+w/2)then
			if(ty>mcy-h/2 and ty<mcy+h/2)then
				return true
			end
		end
		return false
	end
	
	local function setBrightness(body, val)
		if(body.numChildren)then
			for i=1,body.numChildren do
				if(body[i].fill)then
					body[i].fill.effect = "filter.brightness";
					body[i].fill.effect.intensity = val;
				elseif(body[i].numChildren)then
					setBrightness(body[i], val)
				end
			end
		end
	end
	
	elite.addOverOutBrightness = function(mc, body)
		if(body==nil)then body = mc; end
		function mc:onOver()
			if(body.fill)then
				body.fill.effect = "filter.brightness";
				body.fill.effect.intensity = 0.1;
			elseif(body.numChildren)then
				setBrightness(body, 0.1);
			end
		end
		function mc:onOut()
			if(body.fill)then
				body.fill.effect = nil;
			elseif(body.numChildren)then
				setBrightness(body, nil);
			end
		end
	end

	function _G.transitionBlink(img)
		img.fill.effect = "filter.brightness";
		transition.to(img.fill.effect, {time=100, intensity=0.5, transition=easing.inQuad, onComplete=function(obj)
			if(img.fill)then
				img.fill.effect = nil;
			end
		end});
	end
	function _G.transitionBlinkEx(img)
		-- body.fill.effect = "filter.custom.eliteMulti";
		-- body.fill.effect.brightness.intensity = 0.5;
		if(img.fill.effect==nil)then img.fill.effect = "filter.custom.eliteMulti"; end
		transition.to(img.fill.effect.brightness, {time=100, intensity=0.5, transition=easing.inQuad, onComplete=function(obj)
			if(img.fill)then
				img.fill.effect.brightness.intensity = 0;
			end
		end});
	end
	
	_G.easing_arr = {easing.inExpo , easing.outExpo , easing.inOutExpo , easing.outInExpo, easing.inQuad , easing.outQuad , easing.inOutQuad , easing.outInQuad, easing.inBack , easing.outBack , easing.inOutBack , easing.outInBack};
	
	function _G.fitTextFildByW(dtxt, w, ds)
		if(ds)then dtxt.size=ds; end
		while(dtxt.contentWidth>w and dtxt.size>5)do 
			dtxt.size = dtxt.size-1; 
		end
	end
	function _G.fitTextFildByH(dtxt, h, ds)
		if(ds)then dtxt.size=ds; end
		while(dtxt.contentHeight>h and dtxt.size>5)do 
			dtxt.size = dtxt.size-1; 
		end
	end

	function _G.string_split(str, pat)
		--table.concat(untranslated_words, "\r")
	   local t = {};  -- NOTE: use {n = 0} in Lua-5.0
	   local fpat = "(.-)" .. pat;
	   local last_end = 1
	   local s, e, cap = str:find(fpat, 1)
	   while s do
		  if s ~= 1 or cap ~= "" then
		 table.insert(t,cap)
		  end
		  last_end = e+1
		  s, e, cap = str:find(fpat, last_end)
	   end
	   if last_end <= #str then
		  cap = str:sub(last_end)
		  table.insert(t, cap)
	   end
	   return t
	end

	function _G.transitionRemoveSelfHandler(obj)
		if(obj)then
			if(obj.removeSelf)then
				obj:removeSelf();
			end
		end
	end
	function  _G.anirotation(obj)
		transition.to(obj, { time=1000, rotation=obj.rotation+obj.rot_speed, onComplete=anirotation});
	end
	function  _G.anirotationEx(obj, sp)
		obj.rot_speed = sp;
		anirotation(obj)
	end
	function  _G.aniblink(obj, time, delay)
		transition.to(obj, { delay=delay, time=time, alpha=0, onComplete=function(obj)
			obj.alpha=1;
			aniblink(obj, time, delay);
		end});
	end
	function  _G.fadeOut(obj, time)
		if(time==nil)then time=200; end
		transition.to(obj, {time=time, alpha=0, transition=easing.inQuad, onComplete=transitionRemoveSelfHandler});
	end

	function _G.add_bar(fname, tw)
		--print("__tw:", tw);
		local mc =  display.newGroup();
		local ys = scaleGraphics/2;
		if(tw<0.01)then
			mc.w = 2;
			mc.h = 2;
			return mc;
		end
		local b_l=display.newImage(mc, "image/"..fname.."_l.png");
		local b_r=display.newImage(mc, "image/"..fname.."_r.png");
		--print("___tw:", tw, b_l.width);
		if(tw<b_l.width)then
			b_r.width=tw/2;
			b_l.width=tw/2;
		end
		local tw_new = tw;
		if(tw>0)then
			tw_new = tw - b_r.width - b_l.width;
			local b_m=display.newImage(mc, "image/"..fname.."_m.png");
			b_m.width = tw_new;
			--b_m.x, b_m.y = 0,0;
			b_m.yScale = ys;
		end
		b_r.x, b_r.y = tw_new/2+b_r.width/2,0;
		b_l.x, b_l.y = -tw_new/2-b_l.width/2,0;
		
		b_l.yScale = ys;
		b_r.yScale = ys;
		
		mc.w = tw;
		mc.h = b_l.height*ys;
		return mc;
	end

	function _G.add_title(txt, sscale)
		if(sscale==nil)then sscale = 4; end
		local mc = display.newGroup();
		local b_c=display.newImage(mc, "image/gui/bar_title_m.png");
		b_c.xScale, b_c.yScale = scaleGraphics*sscale/2, scaleGraphics/2;
		b_c.x,b_c.y = 0,0;

		local b_l=display.newImage(mc, "image/gui/bar_title_l.png");
		b_l.xScale, b_l.yScale = scaleGraphics/2, scaleGraphics/2;
		b_l.x,b_l.y = -(b_c.width*b_c.xScale + b_l.width*b_l.xScale)/2,0;
		local b_r=display.newImage(mc, "image/gui/bar_title_l.png");
		b_r.xScale, b_r.yScale = -scaleGraphics/2, scaleGraphics/2;
		b_r.x,b_r.y = (b_c.width*b_c.xScale - b_r.width*b_r.xScale)/2,0;
		
		local dtxt=display.newText(mc, txt,0, 0, fontMain, math.floor(11*scaleGraphics));
		dtxt.x,dtxt.y = 0,1*scaleGraphics;
		mc.dtxt = dtxt;
		return mc
	end

	function _G.add_bg(utype, tw, th, fill)
			tw = math.floor(tw);
			th = math.floor(th);
			local mc =  display.newGroup();
			mc.w, mc.h = tw,th;
			mc.x = tw/2;
			mc.y = th/2;

			local top = display.newImage("image/gui/"..utype.."_m.png");
			mc.bw = top.height;
			mc.bh = top.height;
			
			tw = tw - top.height*2;
			th = th - top.height*2;
			top:removeSelf();

			local parts = math.floor(tw/32);
			parts = math.max(1, parts);
			
			
			
			if(tw>0)then
				for i=1,parts do
					local top = display.newImage("image/gui/"..utype.."_m.png");
					top.x, top.y = (i-0.5-parts/2)*(tw)/(parts), -th/2-top.height/2;
					top.xScale, top.yScale = tw/(top.width*parts),1;
					mc:insert(top);
				end
				for i=1,parts do
					local bot = display.newImage("image/gui/"..utype.."_m.png");
					bot.x, bot.y = (i-0.5-parts/2)*(tw)/(parts), th/2+bot.height/2;
					bot.xScale, bot.yScale = tw/(bot.width*parts),-1;
					mc:insert(bot);
				end
			end
			
			local parts = math.floor(th/32);
			parts = math.max(1, parts);
			if(th>0)then
				for i=1,parts do
					local left = display.newImage("image/gui/"..utype.."_m.png");
					left.x, left.y = -tw/2-left.height/2, (i-0.5-parts/2)*(th)/(parts);
					left.xScale, left.yScale =  th/(left.width*parts), 1;
					left.rotation = -90;
					mc:insert(left);
				end
				for i=1,parts do
					local right = display.newImage("image/gui/"..utype.."_m.png");
					right.x, right.y = tw/2+right.height/2, (i-0.5-parts/2)*(th)/(parts);
					right.xScale, right.yScale =  th/(right.width*parts), 1;
					right.rotation = 90;
					mc:insert(right);
				end
			end
			
			local tl = display.newImage("image/gui/"..utype.."_c.png");
			tl.x = -(tw/2+tl.width/2);
			tl.y = -(th/2+tl.height/2);
			mc:insert(tl);
			local tr = display.newImage("image/gui/"..utype.."_c.png");
			tr.xScale = -1;
			tr.x = (tw/2+tr.width/2);
			tr.y = -(th/2+tr.height/2);
			mc:insert(tr);
			
			local bl = display.newImage("image/gui/"..utype.."_c.png");
			bl.yScale = -1;
			bl.x = -(tw/2+bl.width/2);
			bl.y = (th/2+bl.height/2);
			mc:insert(bl);
			local br = display.newImage("image/gui/"..utype.."_c.png");
			br.xScale = -1;
			br.yScale = -1;
			br.x = (tw/2+br.width/2);
			br.y = (th/2+br.height/2);
			mc:insert(br);
			
		if(fill)then
			local bg_fill = display.newRect(mc, 0, 0, tw-mc.bw*0, th-mc.bh*0);
			bg_fill:setFillColor(0, 0, 0);
			bg_fill.x,bg_fill.y = 0,0;
		end
			
		return mc;
	end
	function _G.add_bg_title(utype, tw, th, txt, sscale)
		local mc = add_bg(utype, tw, th)

		local bg_fill = display.newRect(mc, 0, 0, tw-mc.bw, th-mc.bh);
		bg_fill:setFillColor(0, 0, 0);
		bg_fill.x,bg_fill.y = 0,0;

		if(txt~=nil and txt~='')then
			local title = add_title(txt, sscale);
			title.x, title.y = 0, -mc.h/2-1.5*scaleGraphics + options_txt_offset;
			mc.dtxt = title.dtxt;
			mc:insert(title);
		end
		return mc;
	end
	function _G.add_price_bar(tw)
		local bar_mc = display.newGroup();
		local bar1 = add_bar("bar_money1", tw);
		bar1.alpha = 0.5;
		local bar2 = add_bar("bar_money2", tw);
		bar_mc:insert(bar1);
		bar_mc:insert(bar2);
		return bar_mc;
	end
	
	function _G.newOutlinedText(group, txt, tx, ty, font, size, color_in, color_out, txt_outline)
		local mc = display.newGroup();
		mc.text = txt;
		mc.x, mc.y = tx, ty;
		group:insert(mc);
		local txt1 = display.newText(mc, txt, txt_outline, 0, font, size);
		local txt2 = display.newText(mc, txt, -txt_outline, 0, font, size);
		local txt3 = display.newText(mc, txt, 0, txt_outline, font, size);
		local txt4 = display.newText(mc, txt, 0, -txt_outline, font, size);
		local txt5 = display.newText(mc, txt, 0, 0, font, size);
		txt1:setTextColor(color_out);
		txt2:setTextColor(color_out);
		txt3:setTextColor(color_out);
		txt4:setTextColor(color_out);
		txt5:setTextColor(color_in);
		function mc:setText(txt)
			txt1.text = txt;
			txt2.text = txt;
			txt3.text = txt;
			txt4.text = txt;
			txt5.text = txt;
			mc.text = txt;
		end
		function mc:setTextColor(c1,c2,c3)
			txt5:setTextColor(c1,c2,c3);
		end
		function mc:getSize()
			return txt1.size;
		end
		function mc:setSize(val)
			txt1.size = val;
			txt2.size = val;
			txt3.size = val;
			txt4.size = val;
			txt5.size = val;
		end
		
		return mc
	end
	
