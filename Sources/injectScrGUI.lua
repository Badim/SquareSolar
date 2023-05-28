module(..., package.seeall);
-- inject 2.00 added depth
-- inject 1.06 edited for "shipprovision": removed right click
-- inject 1.05 edited for "shipprovision"

function inject(localGroup, buttons)
	local keys = {};
	localGroup.keys = keys;
	
	local draging = nil;
	local pading = nil;
	local removeMe, mouseE, mouseX, mouseY;
	
	function localGroup:getDraging()
		return draging;
	end
	
	if(hintGroup==nil)then hintGroup="map"; end
	if(get_dd_ex==nil)then
		function _G.get_dd_ex(x1,y1,x2,y2)
			local dx=x2-x1;
			local dy=y2-y1;
			return dx*dx+dy*dy;
		end
	end
	if(hit_test_rec_ex==nil)then
		function _G.hit_test_rec_ex(mcx, mcy, w, h, tx, ty)
			if(tx>mcx-w/2 and tx<mcx+w/2)then
				if(ty>mcy-h/2 and ty<mcy+h/2)then
					return true
				end
			end
			return false
		end
	end
	if(addHint==nil)then
		function _G.addHint()
		end
		function _G.removeHint()
		end
	end
	
	local function getDeep(mc, l)
		if(mc.parent)then
			return getDeep(mc.parent, l+1)
		else
			return l;
		end
	end
	
	local function getDeepEx(mc, t)
		if(mc.parent)then
			for i=1,mc.parent.numChildren do
				if(mc.parent[i] == mc)then
					table.insert(t, 1, i);
					return getDeepEx(mc.parent, t)
				end
			end
			
		else
			return t;
		end
	end
	
	local function compareDeeps(d1, d2) -- d2 is deeper then d1
		for i=1,#d1 do
			local v1 = d1[i];
			local v2 = d2[i];
			if(v2==nil)then
				return false
			end
			
			if(v1>v2)then
				return true
			elseif(v1<v2)then
				return false
			end
		end

		return false;
	end
	
	local function getNearestButton(list, gx, gy)
		local tar = nil;
		local mindd = 99999999999;
		local deep2Max = nil;
		for i=#list,1,-1 do
			local mc = list[i];
			if(mc.removeSelf and mc.localToContent)then
				local tx, ty = mc.x, mc.y;
				tx, ty = mc:localToContent(0, 0);
				local dd = get_dd_ex(tx, ty, gx, gy);
				
				local disabled = not mc.isVisible;
				if(disabled==false)then
					if(mc.parent)then
						disabled = disabled or (not mc.parent.isVisible);
						if(disabled==false and mc.parent.parent)then
							disabled = disabled or (not mc.parent.parent.isVisible);
							if(disabled==false and mc.parent.parent.parent)then
								disabled = disabled or (not mc.parent.parent.parent.isVisible);
							end
						end
					end
				end
				if(mc.disabled)then
					if(mc.disabled==true or mc.disabled==false)then
						disabled = mc.disabled;
					else
						disabled = disabled or mc:disabled();
					end
				end

				if(disabled==false)then
					-- if(dd<mindd)then --  or deep>deepMax
						if(mc.r)then
							local rr = mc.r*mc.r;
							if(dd<rr)then
								tar = mc;
								mindd = dd;
								-- deepMax = deep;
							end
						else
							if(hit_test_rec_ex(tx, ty, mc.w, mc.h, gx, gy))then
								local deep2 = getDeepEx(mc, {});
								
								if(deep2Max == nil or compareDeeps(deep2, deep2Max))then
									tar = mc;
									mindd = dd;
									deep2Max = deep2;
								end
							end
						end
					-- end
				end
			else
				table.remove(list, i);
			end
		end
		return tar;
	end
	local onCurrentlyOverMC = nil;
	local function tryNearestButton(list, gx, gy)
		local tar = getNearestButton(list, gx, gy);
		if(tar)then
			if(tar._selected~=true)then
				tar._selected=true;
				if(tar.onOver)then
					tar:onOver();
					-- if(tar.onOverEx)then
						-- tar:onOverEx();
					-- end
				end
				-- if(tar.collapsed)then
					-- addHintEx(tar.collapsed, 'map', gx, gy);
				-- else -- field.collapsed
					addHint(tar.hint, 'map', gx, gy);
				-- end
			end
			
			-- if(tar.collapsed)then
				-- addHintEx(tar.collapsed, 'map', gx, gy);
			-- end
		end
		for i=1,#list do
			local mc = list[i];
			if(mc~=tar)then
				if(mc._selected)then
					mc._selected = false;
					if(mc.onOut)then
						mc:onOut();
					end
					-- onCurrentlyOverMC = nil;
				end
			end
		end
		if(tar==nil)then
			removeHint('map');
		end
		onCurrentlyOverMC = tar;
		return tar
	end
	
	local ground;
	function localGroup:setGround(mc)
		ground = mc;
	end
	
	local oldX, oldY = 0, 0;
	local sX, sY = 0, 0;
	local touchTar = nil;
	local touchTimer = nil;
	local function touchHandler(e)
		local phase = e.phase;
		local dx, dy = e.x-oldX, e.y-oldY;
		local gx, gy = e.x, e.y;
		oldX, oldY = e.x, e.y;

		if(phase=='began')then
			local tar = tryNearestButton(buttons, gx, gy);
			touchTar = tar;
			touchTimer = getTimer();
			if(tar)then
				if(tar.dragable)then
					draging = tar;
					tar.__draging = true;
					if(draging.onPick)then
						draging:onPick();
					end
				end
			end
			if(ground and tar==nil and localGroup:wndOn()==false)then
				draging = ground;
			end
			sX, sY = e.x, e.y;
			
			if(tar and tar.padCall)then
				tar:padCall(gx, gy);
				pading = tar;
			end
			if(tar == nil)then
				-- local natives = elite.getAllNativeTexts();
				-- if(#natives > 0)then
					-- for i=1,#natives do
						-- local mc = natives[i];
						-- if(mc.stay ~= true)then
							-- mc:removeMe();
						-- end
					-- end
				-- end
				-- local picker = _G.getPickerlink();
				-- if(picker and picker.removeSelf)then
					-- picker:removeSelf();
				-- end
			end
		elseif(phase=='moved')then
			mouseE = e;
			mouseX, mouseY = e.x, e.y;
		
			if(draging)then
				local ndx, ndy = dx, dy;
				if(draging.lockedX)then ndx = 0; end
				if(draging.lockedY)then ndy = 0; end
				if(draging.translate)then
					draging:translate(ndx, ndy);
				end
			else
				local tar = tryNearestButton(buttons, gx, gy);
				if(tar ~= touchTar)then
					touchTar = tar;
					touchTimer = getTimer();
				end
				if(tar and tar.padCall)then
					tar:padCall(gx, gy);
				end
				if(pading)then
					pading:padCall(gx, gy);
				end
			end
		else
			local sd = distanceEx(sX, sY, e.x, e.y);
			local r = nil;
			-- print("_e.x, e.y:", sd);
			if(sd<24)then
				local tar = tryNearestButton(buttons, gx, gy);
				if(tar)then
					if(keys.leftControl and tar.actCtrl)then
						r = tar:actCtrl(mouseX, mouseY);
						tar._selected = false;
						if(tar.onOut)then
							tar:onOut();
						end
						if(tar.actTut)then
							tar:actTut();
						end
					elseif(tar.act)then
						r = tar:act(mouseX, mouseY);
						tar._selected = false;
						if(tar.onOut)then
							tar:onOut();
						end
						if(tar.actTut)then
							tar:actTut();
						end
					end
				end
			end
			if(draging)then
				draging.__draging = nil;
				if(draging.onDrop)then
					draging:onDrop();
				end
			end
			draging = nil;
			pading = nil;
			touchTar = nil;
			touchTimer = nil;
			if(localGroup.__touchHoldMC)then
				transitionRemoveSelfHandler(localGroup.__touchHoldMC);
				localGroup.__touchHoldMC = nil;
			end
			return r;
		end
	end
	localGroup:addEventListener('touch', touchHandler);
	
	local function keyHandler(e)
		keys[e.keyName] = e.phase=="down";
		if(e.phase=="down")then
			if(e.keyName=="escape" or e.keyName=="deleteBack" or e.keyName=="back")then
				if(localGroup.actEscape)then
					localGroup:actEscape();
					return true;
				end
			end
			if(e.keyName=="space")then
				if(localGroup.actSpace)then
					localGroup:actSpace();
					return true;
				end
			end
		end
	end
	local function mouseHandler(e)
		if(localGroup.removeSelf==nil)then
			removeMe();
			return
		end
		mouseE = e;
		mouseX, mouseY = e.x, e.y;
		
		if(keys["mouseright"]~=true and e.isSecondaryButtonDown)then
			-- if(localGroup.actEscape)then
				-- localGroup:actEscape();
			-- end
		end
		keys["mouseright"] = e.isSecondaryButtonDown==true;
		
		-- print("_e:", e, e.scroll);
		-- for attr, val in pairs(e) do
			-- print(attr, val);
		-- end
		if(e.scrollY~=0)then
			if(onCurrentlyOverMC and onCurrentlyOverMC.onScroll and onCurrentlyOverMC.removeSelf)then
				onCurrentlyOverMC:onScroll(e.scrollY);
			elseif(localGroup.onScroll)then
				localGroup:onScroll(e.scrollY);
			end
			-- print("_onCurrentlyOverMC:", onCurrentlyOverMC);
		end
	end
	local function turnHolder(e)
		if(touchTar and touchTar.onHold)then
			local mseconds = getTimer() - touchTimer;
			local timerMax = 1500;
			local delayTime = 500;
			if(mseconds<delayTime)then
				return
			end
			if(localGroup.__touchHoldMC and localGroup.__touchHoldMC~=touchTar)then
				transitionRemoveSelfHandler(localGroup.__touchHoldMC);
				localGroup.__touchHoldMC = nil;
			end
			if(localGroup.__touchHoldMC == nil)then
				-- local mc = newGroup(localGroup);
				-- mc.tar = touchTar;
				-- localGroup.__touchHoldMC = mc;
				-- local bot = display.newCircle(mc, 0, 0, 12*scaleGraphics);
				-- bot.alpha = 1/3;
				-- bot:setStrokeColor(1, 1, 1, 1/3);
				-- bot.strokeWidth = scaleGraphics*2;
				-- local top = display.newCircle(mc, 0, 0, 12*scaleGraphics);
				-- top:setFillColor(1/2);
				-- top.alpha = 3/4;
				-- function mc:refresh(p)
					-- print('scale', p)
					-- top.xScale, top.yScale = p, p;
				-- end
				-- mc:refresh(0.001);
				local mc = elite.drawSector(localGroup, 11*scaleGraphics, 12*scaleGraphics);
				mc.tar = touchTar;
				localGroup.__touchHoldMC = mc;
				mc:refresh(0.001);
			end
			local mc = localGroup.__touchHoldMC;
			mc.x, mc.y = mouseX, mouseY;
			if(mseconds>timerMax)then
				touchTar:onHold(math.floor(mseconds/1000));
				mc:refresh(1);
			else
				mc:refresh((mseconds-delayTime)/(timerMax-delayTime));
			end
		end
	end
	local function turnHandler(e)
		if(localGroup.removeSelf==nil)then
			removeMe();
			return
		end
		
		if(mouseE)then
			if(draging)then
				if(draging.onMove)then
					draging:onMove();
				end
			else
				tryNearestButton(buttons, mouseX, mouseY);
			end
			mouseE = nil;
		end
		
		-- touchTar = tar;
		-- touchTimer = getSeconds();
		-- wndbg.onHold
		turnHolder(e);
	end
	removeMe = function()
		Runtime:removeEventListener("mouse", mouseHandler);
		Runtime:removeEventListener("enterFrame", turnHandler);
		Runtime:removeEventListener("key", keyHandler);
	end
	Runtime:addEventListener("mouse", mouseHandler);
	Runtime:addEventListener("enterFrame", turnHandler);
	Runtime:addEventListener("key", keyHandler);
end