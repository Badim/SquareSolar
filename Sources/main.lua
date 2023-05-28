-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
_G.W = display.contentWidth;
_G.H = display.contentHeight;
-- Your code here

json = require "json";
require("eliteHelper");

_G.mainGroup = display.newGroup();
local buttons = {};

require("injectScrGUI").inject(mainGroup, buttons);

local parties = {};
table.insert(parties, {clr={0.7, 0, 0}, gid=1});
table.insert(parties, {clr={0, 0.7, 0}, gid=2});

local bgmc = display.newRect(mainGroup, W/2, H/2, W, H);
bgmc:setFillColor(0.1);

local splitmc = newGroup(mainGroup);
splitmc.x = W/2;
splitmc.alpha = 0.15;
do
	local rect = display.newRect(splitmc, -W, H/2, W*2, H);
	rect:setFillColor(1,0,0);
	local rect = display.newRect(splitmc, W, H/2, W*2, H);
	rect:setFillColor(0,1,0);
end

local highmc = newGroup(mainGroup);
local gamemc = newGroup(mainGroup);
local facemc = newGroup(mainGroup);

gamemc.ani = 0;
gamemc.squareFilledPer = 0;

local login = {};
login.bestscore = 0;

local saveFilename = "save3.json";
function saveGame()
	local data = json.encode(login);
	saveFile(saveFilename, data);
end

do -- loadGame
	local data = loadFile(saveFilename);
	if data then
		login = json.decode(data);
	end
end

local items = {};
local merges = {};

function gamemc:showFinalWnd()
	local wndmc = newGroup(facemc);
	wndmc.x, wndmc.y = W/2, H/2;
	local rect = display.newRect(wndmc, 0, 0, W, H);
	rect:setFillColor(0, 0, 0, 0.9);
	rect.w, rect.h = W, H;
	table.insert(buttons, rect);
	
	-- local item = newGroup(wndmc);
	-- item.alpha = 0.9;
	-- item.w, item.h = 140, 32;
	-- local body = display.newRect(item, 0, 0, item.w, item.h);
	-- body:setFillColor(1/3)
	-- elite.addOverOutBrightness(item);
	-- table.insert(buttons, item);
	-- item.x, item.y = 0, H/2 - 160;
	
	local y = 160;
	
	local dtxt = display.newText(wndmc, "scores", 0, 0, nil, 24);
	dtxt.x, dtxt.y = 0, H/2 - y - 40*7
	dtxt.text = "Best Score: ".. math.floor(login.bestscore*100)/100;
	
	
	
	local dtxt = display.newText(wndmc, "scores", 0, 0, nil, 24);
	dtxt.x, dtxt.y = 0, H/2 - y - 40*5
	dtxt.text = "Evil vs Good: " .. gamemc.counts[1] .. " vs " .. gamemc.counts[2];
	
	
	local dtxt = display.newText(wndmc, "scores", 0, 0, nil, 24);
	dtxt.x, dtxt.y = 0, H/2 - y - 40*4
	dtxt.text = "Equilibrium: " .. math.floor(100*login.equilibrium) .. "%";
	
	local dtxt = display.newText(wndmc, "scores", 0, 0, nil, 24);
	dtxt.x, dtxt.y = 0, H/2 - y - 40*3
	dtxt.text = "Field Filled: "..math.floor(gamemc.squareFilledPer*100) .. "%";
	
	local dtxt = display.newText(wndmc, "scores", 0, 0, nil, 24);
	dtxt.x, dtxt.y = 0, H/2 - y - 40*2
	dtxt.text = "Squares: "..#items;
	
	local dtxt = display.newText(wndmc, "scores", 0, 0, nil, 24);
	dtxt.x, dtxt.y = 0, H/2 - y - 40*1
	dtxt.text = "Score: ".. math.floor(gamemc.squareFilledPer * #items*100 * login.equilibrium)/100;
	-- item.act = function()
		-- wndmc:removeSelf();
	-- end
	
	-- local item = newGroup(wndmc);
	-- item.alpha = 0.9;
	-- item.w, item.h = 140, 32;
	-- local body = display.newRect(item, 0, 0, item.w, item.h);
	-- body:setFillColor(1/3)
	-- elite.addOverOutBrightness(item);
	-- table.insert(buttons, item);
	-- item.x, item.y = 0, H/2 - 120 - 40;
	-- local dtxt = display.newText(item, "submit", 0, 0, nil, 24);
	-- item.act = function()
		-- wndmc:removeSelf();
	-- end
	
	local item = newGroup(wndmc);
	item.alpha = 0.9;
	item.w, item.h = 140, 32;
	local body = display.newRect(item, 0, 0, item.w, item.h);
	body:setFillColor(1/3)
	elite.addOverOutBrightness(item);
	table.insert(buttons, item);
	item.x, item.y = 0, H/2 - 120;
	local dtxt = display.newText(item, "restart", 0, 0, nil, 24);
	item.act = function()
		while #items>0 do
			local mc = table.remove(items, 1);
			display.remove(mc);
		end
		gamemc:refill();
		wndmc:removeSelf();
	end
	
	local item = newGroup(wndmc);
	item.alpha = 0.9;
	item.w, item.h = 140, 32;
	local body = display.newRect(item, 0, 0, item.w, item.h);
	body:setFillColor(1/3)
	elite.addOverOutBrightness(item);
	table.insert(buttons, item);
	item.x, item.y = 0, H/2 - 80;
	local dtxt = display.newText(item, "close", 0, 0, nil, 24);
	item.act = function()
		wndmc:removeSelf();
	end
end

do
	local item = newGroup(facemc);
	item.alpha = 0.9;
	item.w, item.h = 60, 40;
	local body = display.newRect(item, 0, 0, item.w, item.h);
	body:setFillColor(1/3)
	elite.addOverOutBrightness(item);
	table.insert(buttons, item);
	item.x, item.y = W/2, H - 30;
	local dtxt = display.newText(item, "➕", 0, 0, nil, 24);
	item.act = function()
		gamemc:refill();
	end
end

do
	local item = newGroup(facemc);
	item.alpha = 0.9;
	item.w, item.h = 100, 32;
	local body = display.newRect(item, 0, 0, item.w, item.h);
	body:setFillColor(1/3)
	elite.addOverOutBrightness(item);
	table.insert(buttons, item);
	item.x, item.y = W/2, 50;
	local dtxt = display.newText(item, "🏁🏁🏁", 0, 0, nil, 24);
	item.act = function()
		gamemc:showFinalWnd()
	end
end

local scoretxt = display.newText(facemc, "0%", 0, 0, nil, 16);
scoretxt.x, scoretxt.y = W/2, 20;
-- scoretxt.x, infotxt.y = W/2, H/2;
scoretxt.alpha = 1;

local infotxt = display.newText(facemc, "0%", 0, 0, nil, 200);
-- infotxt.x, infotxt.y = W/2, 30;
infotxt.x, infotxt.y = W/2, H/2;
infotxt.alpha = 0.4;

local function turnHandler(e)
	if gamemc.ani<1 then
		for i=#merges,1,-1 do
			local list = merges[i];
			local item = list[1];
			local nitem = table.remove(list, #list);
			if item.gid == nitem.gid then
				gamemc:merge(item, nitem, 1);
			else
				gamemc:merge(item, nitem, -1);
			end
			if #list>1 then
				table.sort(list, function(a, b)
					return a.size>b.size;
				end);
			else
				table.remove(merges, i);
			end
		end
	end
	
	-- if gamemc.ani<1 then
		-- if #items<2 then
			-- gamemc:refill();
		-- end
	-- end
	
	-- pricetxt.text = #items;
	local score = gamemc.squareFilledPer * #items * login.equilibrium;
	if score>login.bestscore/1 then
		login.bestscore = score;
		saveGame();
	end
	local floor = math.floor;
	scoretxt.text = #items .. " x " .. floor(gamemc.squareFilledPer*100) .. "% x "  .. floor(login.equilibrium*100) .."% = " .. floor(score*100)/100;
end
Runtime:addEventListener('enterFrame', turnHandler);


function gamemc:recalc()
	local pixels = W*H;
	local count = 0;
	local list = {};
	list[1] = 0;
	list[2] = 0;
	
	local counts = {}
	counts[1] = 0;
	counts[2] = 0;
	
	for i=1,#items do
		local item = items[i];
		local area = item.w * item.h;
		list[item.gid] = list[item.gid] + area;
		counts[item.gid] = counts[item.gid] + 1;
		count = count + area;
	end
	
	infotxt.text = math.floor(100*count/pixels) .. "%";
	gamemc.squareFilledPer = count/pixels;
	
	if counts[2]~=0 then
		splitmc.x = W * (1-counts[2]/(counts[2]+counts[1]));
	end
	
	gamemc.counts = counts;
	local equilibrium = math.min(counts[1], counts[2]) / math.max(counts[1], counts[2]);
	login.equilibrium = equilibrium;
	
	
	print(counts[1], counts[2], counts[1]/counts[2])
end
	
function gamemc:addItem(sx, sy)
	local item = newGroup(gamemc);
	item.size = rnd(64, 256);
	
	
	local party = table.random(parties);
	item.party = party;
	item.gid = party.gid;

	item.w, item.h = item.size, item.size;
	elite.addOverOutBrightness(item);
	table.insert(buttons, item);
	table.insert(items, item);
	item.dragable = true;
	item.x, item.y = sx, sy;
	
	local body;
	function item:refresh()
		item.w, item.h = 10+math.pow(item.size, 3/4), 10+math.pow(item.size, 3/4);
		display.remove(body);
		body = display.newRect(item, 0, 0, item.w, item.h);
		body:setFillColor(unpack(party.clr));
	end
	function item:resize(_size)
		item.size = _size;
		item:refresh();
	end
	item:refresh();
	
	function item:aresize(_size)
		if item.dead then
			return
		end
		item.size = _size;
		item.w, item.h = 10+math.pow(item.size, 3/4), 10+math.pow(item.size, 3/4);
		
		local nx = item.x;
		nx = math.max(nx, item.w/2);
		nx = math.min(nx, W-item.w/2);
		local ny = item.y;
		ny = math.max(ny, item.h/2);
		ny = math.min(ny, H-item.h/2);
		-- transition.to(item2, {time=300, transition=easing.outQuad, xScale=0.1, yScale=0.1, onComplete=function()
			-- display.remove(item1);
			-- gamemc.ani = gamemc.ani-1;
			
			-- item2:tryMerge();
		-- end});
		-- gamemc.ani = gamemc.ani-1;
		local obj = {time=1000, width=item.w, height=item.h, transition=easing.outElastic, onComplete=function()
			-- gamemc.ani = gamemc.ani+1;
		end};
		transition.to(body, obj);
		
		transition.to(item, {time=1000, x=nx, y=ny, transition=easing.outElastic});
		gamemc:recalc();
	end
	
	local high;
	function item:highlight(clr)
		display.remove(high);
		high = display.newRoundedRect(highmc, 0, 0, item.w+4, item.h+4, 5);
		high:setFillColor(unpack(clr));
		high:translate(item.x, item.y);
	end
	function item:lowlight()
		display.remove(high);
	end
	
	local clean = false;
	function item:onMove()
		item:toFront();
		clean = true;
		item.target = nil;
		for i=1,#items do
			local nitem = items[i];
			if nitem.dead~=true and nitem ~= item then
				local d = getRD(item, nitem);
				local r = item.w/2 + nitem.w/2;
				if d<r then
					local clr = party.clr;
					if item.gid~=nitem.gid then
						clr = {1, 0, 1};
					end
					nitem:highlight(clr);
					item:highlight(clr);
					
					item.target = nitem;
					clean = false;
				end
			end
		end
		
		if clean then
			highmc:clean();
		end
		
		item.x = math.max(item.x, item.w/2);
		item.x = math.min(item.x, W-item.w/2);
		item.y = math.max(item.y, item.h/2);
		item.y = math.min(item.y, H-item.h/2);
	end
	
	function item:tryMerge()
		local list = {item};
		for i=#items,1,-1 do
			local nitem = items[i];
			if nitem.dead~=true and nitem ~= item and item.x~=nil and nitem.x~=nil then
				local d = getRD(item, nitem);
				local r = item.w/2 + nitem.w/2;
				if d<r then
					-- if item.gid == nitem.gid then
						-- gamemc:merge(item, nitem, 1);
					-- else
						-- gamemc:merge(item, nitem, -1);
					-- end
					table.insert(list, nitem);
				end
			end
		end
		
		if #list>1 then
			table.sort(list, function(a, b)
				return a.size>b.size;
			end);
			table.insert(merges, list);
		end
	end
	
	function item:onDrop()
		highmc:clean();
		item:tryMerge();
	end
	
	item:tryMerge();
	gamemc:recalc();
end

function highmc:clean()
	-- for i=1,#items do
		-- local nitem = items[i];
		-- nitem:lowlight();
	-- end
	cleanGroup(highmc);
end

function gamemc:merge(item1, item2, sign)
	if item1.size > item2.size then
		local nitem = item1;
		item1 = item2;
		item2 = nitem;
	end
	
	if item1.toFront==nil then
		return
	end

	table.removeByRef(buttons, item1);
	table.removeByRef(items, item1);
	item1.dead = true;
	
	local size = item2.size + item1.size*sign;
	-- print("_size1:", size);

	gamemc.ani = gamemc.ani+1;
	item1:toFront();
	transition.to(item1, {time=300, transition=easing.outQuad, x=item2.x, y=item2.y, onComplete=function()
		item2:aresize(size);

		transition.to(item1, {time=300, transition=easing.outQuad, xScale=0.1, yScale=0.1, onComplete=function()
			display.remove(item1);
			gamemc.ani = gamemc.ani-1;
			
			item2:tryMerge();
		end});
	end});
	
	-- local l = display.newLine(gamemc, item1.x, item1.y, item2.x, item2.y);
	-- l.strokeWidth = 4;
end

function gamemc:refill()
	local iMax = 8;
	for i=1,iMax do
		local r = 140;
		local a = 2*math.pi/iMax;
		gamemc:addItem(W/2 + r*math.cos(a*i), H/2 + r*math.sin(a*i));
	end
	gamemc:addItem(W/2, H/2);
end
gamemc:refill();

-- generation if off - if there is no balance
-- goal - to fill most screen with maximum amount of elements