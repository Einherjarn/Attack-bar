pont=0.000
pofft= 0.000
ont = 0.000
offt= 0.000
ons = 0.000
offs= 0.000
offh = 0
onh  = 0
epont=0.000
epofft= 0.000
eont = 0.000
eofft= 0.000
eons = 0.000
eoffs= 0.000
eoffh = 0
eonh  = 0
testvar = 0
Abar_MHTime = GetTime()
abar_aspd = 2.00
abar_firsthit = 1
abar_optime = 0

function round(num, decimals)
  local mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

function abar_swapweps()
	if not UnitIsDead("player") then
		--local Gcd,dur = GetSpellCooldown(abilitynum,"spell")
		--local res = UnitMana("player")
		local _,ohcheck = UnitAttackSpeed("player");

		if abar.swapping and not (ohcheck == nil) then --(((Gcd+dur)-GetTime()) <= 0) and 
				local MHhas,MHtime,MHcharges,OHhas,OHtime,OHcharges = GetWeaponEnchantInfo();
				if MHhas then
					if OHhas then
						if (MHtime >= OHtime) and (MHtime <= 10000) then
							PickupInventoryItem(16) PickupInventoryItem(17)
						end
					else
						PickupInventoryItem(16) PickupInventoryItem(17)
					end
				end
		else
			return
		end
	end
end

if not(abar) then abar={} end
-- cast spell by name hook
preabar_csbn = CastSpellByName
function abar_csbn(pass, onSelf)
	preabar_csbn(pass, onSelf)
	abar_spelldir(pass)
end
CastSpellByName = abar_csbn
--use action hook
preabar_useact = UseAction

function abar_useact(p1,p2,p3)
	preabar_useact(p1,p2,p3)
    local a,b = IsUsableAction(p1)
    if a then
    	if UnitCanAttack("player","target" )then
    		if IsActionInRange(p1) == 1 then
			Abar_Tooltip:ClearLines()
			Abar_Tooltip:SetAction(p1)
    	local spellname = Abar_TooltipTextLeft1:GetText()
    	if spellname then abar_spelldir(spellname) end
    	end
    	end
    end
end
UseAction = abar_useact
--castspell hook
preabar_cassple = CastSpell
function abar_casspl(p1,p2)
	preabar_cassple(p1,p2)
	local spell = GetSpellName(p1,p2)
		abar_spelldir(spell)
end
CastSpell = abar_casspl
function Abar_loaded()
	SlashCmdList["ATKBAR"] = Abar_chat;
	SLASH_ATKBAR1 = "/abar";
	SLASH_ATKBAR2 = "/atkbar";
	if abar.range == nil then
		abar.range=true
	end
	if abar.h2h == nil then
		abar.h2h=true
	end
	if abar.timer == nil then
		abar.timer=true
	end
	if abar.swapping == nil then
		abar.swapping=false
	end
	if abarop == nil then
		abarop=false
	end
	if abarbs == nil then
		abarbs=false
	end
	
	Abar_Mhr:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-13)
	Abar_Oh:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-35)
	Abar_MhrText:SetJustifyH("Left")
	Abar_OhText:SetJustifyH("Left")
	ebar_VL()
end
function Abar_chat(msg)
	msg = strlower(msg)
	if msg == "fix" then
		Abar_reset()
	elseif msg=="lock" then
		Abar_Frame:Hide()
		ebar_Frame:Hide()
	elseif msg=="unlock" then
		Abar_Frame:Show()
		ebar_Frame:Show()
	elseif msg=="range" then
		abar.range= not(abar.range)
		DEFAULT_CHAT_FRAME:AddMessage('range is'.. Abar_Boo(abar.range));
	elseif msg=="h2h" then
		abar.h2h = not(abar.h2h)
		DEFAULT_CHAT_FRAME:AddMessage('H2H is'.. Abar_Boo(abar.h2h));
	elseif msg=="timer" then
		abar.timer = not(abar.timer)
		DEFAULT_CHAT_FRAME:AddMessage('timer is'.. Abar_Boo(abar.timer));
	elseif msg=="enemy" then
		if not(abar.enemy) or (abar.enemy < 1) then
			abar.enemy = 1
			DEFAULT_CHAT_FRAME:AddMessage('target bar is ON');
		else
			abar.enemy = 0
			DEFAULT_CHAT_FRAME:AddMessage('target bar is OFF');
		end
	elseif msg=="swapping" then
		abar.swapping = not(abar.swapping)
		DEFAULT_CHAT_FRAME:AddMessage('windfury weaving is'.. Abar_Boo(abar.swapping));
	elseif msg=="op" then
		abarop = not(abarop)
		DEFAULT_CHAT_FRAME:AddMessage('Overpower highlight is'.. Abar_Boo(abarop));
		DEFAULT_CHAT_FRAME:AddMessage("this is a custom hacky implementation, and will not work without the appropriate setup");
	elseif msg=="bs" then
		abarbs = not(abarbs)
		DEFAULT_CHAT_FRAME:AddMessage('Battleshout highlight is'.. Abar_Boo(abarbs));
		DEFAULT_CHAT_FRAME:AddMessage("this is a custom hacky implementation, and will not work without the appropriate setup");
	else
		DEFAULT_CHAT_FRAME:AddMessage('use any of these to control Abar:');
		DEFAULT_CHAT_FRAME:AddMessage('Lock - to lock and hide the anchor');
		DEFAULT_CHAT_FRAME:AddMessage('unlock - to unlock and show the anchor');
		DEFAULT_CHAT_FRAME:AddMessage('fix - to reset the values should they go awry, wait 5 sec after attacking to use this command');
		DEFAULT_CHAT_FRAME:AddMessage('h2h - to turn on and off the melee bar(s)');
		DEFAULT_CHAT_FRAME:AddMessage('range - to turn on and off the ranged bar');
		DEFAULT_CHAT_FRAME:AddMessage('enemy - to turn on and off the enemy target bar(s)');
	end
end
function Abar_selfhit(arg1)

if string.find (arg1, "You fall (.+)") or string.find (arg1, "You suffer (.+)") then
	return
end

ons,offs=UnitAttackSpeed("player");
hd,ld,ohd,old = UnitDamage("player")
hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)

if old then
	ohd,old = ohd-math.mod(ohd,1),old-math.mod(old,1)
end	
if offs then
	ont,offt=GetTime(),GetTime()
	--if ((math.abs((ont-pont)-ons) <= math.abs((offt-pofft)-offs))and not(onh <= offs/ons)) or offh >= ons/offs then
	if not (Abar_Oh.left) then
		Abar_Oh.left = 0.00
	end
	if (abar_firsthit == 1 or (Abar_Mhr.left <= Abar_Oh.left)) then
		if pofft == 0 then pofft=offt end
		pont = ont
		tons = ons
		offh = 0
		onh = onh +1
		ons = ons - math.mod(ons,0.01) --+0.01
		Abar_Mhrs(tons,"["..ons.."s]("..hd.."-"..ld..")",0,0,1,"Main")
		abar_firsthit = 0
	else
		pofft = offt
		offh = offh+1
		onh = 0
		ohd,old = ohd-math.mod(ohd,1),old-math.mod(old,1)
		offs = offs - math.mod(offs,0.01) --+0.01
		Abar_Ohs(offs,"["..offs.."s]("..ohd.."-"..old..")",0,0,1,"Off")
	end
else
	ont=GetTime()
	tons = ons
	ons = ons - math.mod(ons,0.01) --+0.01
	Abar_Mhrs(tons,"["..ons.."s]("..hd.."-"..ld..")",0,0,1,"Main")
end

end

function Abar_reset()
	pont=0.000
	pofft= 0.000
	ont=0.000
	offt= 0.000
	onid=0
	offid=0
end

function Abar_leftcombat()
	if(abarbs) then
		ABG_RemoveOverlay(ABI_ButtonFromID(51))
	end
end

function Abar_op()
--hardcoded overpower highlight slot, todo: make it dynamic somehow.
--ABI_ButtonFromID was changed to not be local.. maybe a bad idea but im basicly just making a shitty hacked solution for myself.
ABG_AddOverlay(ABI_ButtonFromID(67))
abar_optime = GetTime();
end

function Abar_event(event)
	if (event=="CHAT_MSG_COMBAT_SELF_MISSES" or event=="CHAT_MSG_COMBAT_SELF_HITS") and abar.h2h == true then Abar_selfhit(arg1) end
	if event=="PLAYER_LEAVE_COMBAT" then Abar_reset() end
	if event=="PLAYER_REGEN_ENABLED" then Abar_leftcombat() end
	if event == "VARIABLES_LOADED" then Abar_loaded() end
	if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then Abar_spellhit(arg1) end
	if (event == "UNIT_INVENTORY_CHANGED" and (not UnitAffectingCombat("player"))) then abar_swapweps() end
	
	if abarop then --only worry about this shit if its turned on
		if (event == "CHAT_MSG_COMBAT_SELF_MISSES") then
			local a,b,str = string.find(arg1, "You attack. (.+) dodges.")
			if a then
				Abar_op()
			end
		elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE" or  event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF") then
			local a,b,c,str = string.find(arg1, "Your (.+) was dodged by (.+).")
			if a then
				Abar_op()
			else
				a,b,str = string.find(arg1, "Your (.+) hits")
				if not str then a,b,str = string.find(arg1, "Your (.+) crits") end
				if not str then a,b,str = string.find(arg1, "Your (.+) is parried") end
				if not str then a,b,str = string.find(arg1, "Your (.+) missed") end
				if str == "Overpower" then
					ABG_RemoveOverlay(ABI_ButtonFromID(67))
					abar_optime = 0
				end
			end
		end
	end
	--if event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then Abar_testhostilespell(arg1) end
	--if event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER" then Abar_CheckSpell(arg1) end
	--if event == "SPELLCAST_STOP" then Abar_SpellStop() end
	--if event == "PLAYER_TARGET_CHANGED" then Abar_targetchange() end
	-- if event == "CHAT_MSG_SPELL_SELF_BUFF" then
		-- Abar_spellhit(arg1)
		-- DEFAULT_CHAT_FRAME:AddMessage("deb cmssb: "..arg1.." "..arg2.." "..arg3.." "..arg4.." "..arg5.." "..arg6.." "..arg7.." "..arg8.." "..arg9)
	-- end
	-- if event == "COMBAT_TEXT_UPDATE" then
		-- if(arg3) then
			-- DEFAULT_CHAT_FRAME:AddMessage("deb ctu: "..arg1.." "..arg2.." "..arg3)
		-- elseif(arg2) then
			-- DEFAULT_CHAT_FRAME:AddMessage("deb ctu: "..arg1.." "..arg2)
		-- elseif(arg1) then
			-- DEFAULT_CHAT_FRAME:AddMessage("deb ctu: "..arg1)
		-- end
	-- end
end

function Abar_spellhit(arg1)
	a,b,spell=""
	a,b,spell=string.find (arg1, "Your (.+) hits")
	if not spell then 	a,b,spell=string.find (arg1, "Your (.+) crits") end
	if not spell then 	a,b,spell=string.find (arg1, "Your (.+) is") end
	if not spell then	a,b,spell=string.find (arg1, "Your (.+) misses") end
	if not spell then	a,b,spell=string.find (arg1, "Your (.+) missed") end
	if not spell then	a,b,spell=string.find (arg1, "Your (.+) was") end		
	
	rs,rhd,rld =UnitRangedDamage("player");
	rhd,rld= rhd-math.mod(rhd,1),rld-math.mod(rld,1)
	if spell == "Auto Shot" and abar.range == true then
		Abar_Mhrs(rs,"["..round(rs,2).."s]("..rhd.."-"..rld..")",0,1,0,"AShot")
	elseif spell == "Shoot" and abar.range==true then
		Abar_Mhrs(rs,"["..round(rs,2).."s]("..rhd.."-"..rld..")",.7,.1,1,"Wand")
	elseif (spell == "Raptor Strike" or spell == "Heroic Strike" or
	spell == "Maul" or spell == "Cleave") and abar.h2h==true then
		hd,ld,ohd,lhd = UnitDamage("player")
		hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)
		if pofft == 0 then pofft=offt end
		ont=GetTime()
		pont = ont
		tons = ons
		offh = 0
		onh = onh +1
		ons = ons - math.mod(ons,0.01) +0.01
		Abar_Mhrs(tons,"["..round(ons,2).."s]("..hd.."-"..ld..")",0,0,1,"Main")
	elseif (spell == "Slam") and abar.h2h==true then
		hd,ld,ohd,lhd = UnitDamage("player")
		hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)
		if pofft == 0 then pofft=offt end
		ont=GetTime()
		pont = ont
		tons = ons
		offh = 0
		onh = onh +1
		ons = ons - math.mod(ons,0.01) +0.01
		Abar_Mhrs(tons,"["..round(ons,2).."s]("..hd.."-"..ld..")",0,0,1,"Main")
	elseif abar.swapping and (spell == "Hamstring") or (spell == "Execute") or (spell == "Bloodthirst") or (spell == "Whirlwind") or (spell == "Overpower") or (spell == "Sinister Strike") or (spell == "Eviscerate") or (spell == "Hemorrhage") or (spell == "Backstab") then
		abar_swapweps()
	end
end
function abar_spelldir(spellname)
	if abar.range then
	local a,b,sparse = string.find (spellname, "(.+)%(")
	if sparse then spellname = sparse end
	rs,rhd,rld =UnitRangedDamage("player");
	rhd,rld= rhd-math.mod(rhd,1),rld-math.mod(rld,1)
	if spellname == "Throw" then
		Abar_Mhrs(rs-1,"["..round(rs,2).."s]("..rhd.."-"..rld..")",1,.5,0,"Throw")
	elseif spellname == "Shoot" then
		Abar_Mhrs(rs-1,"["..round(rs,2).."s]("..rhd.."-"..rld..")",.5,0,1,"Wand")
	elseif spellname == "Shoot Bow" then
		Abar_Mhrs(rs-1,"["..round(rs,2).."s]("..rhd.."-"..rld..")",1,.5,0,"Bow")
	elseif spellname == "Shoot Gun" then
		Abar_Mhrs(rs-1,"["..round(rs,2).."s]("..rhd.."-"..rld..")",1,.5,0,"Gun")
	elseif spellname == "Shoot Crossbow" then
		Abar_Mhrs(rs-1,"["..round(rs,2).."s]("..rhd.."-"..rld..")",1,.5,0,"XBow")
	--elseif spellname == "Aimed Shot" then
	--	trs=rs
	--	rs = rs-math.mod(rs,0.01)
	--	Abar_Mhrs(trs-1,"["..(3).."s]",1,.1,.1,"Aimed") 
	end
	end
	end

function Abar_UpdateAlways()
	if(abarop) then
		if(abar_optime > 0) then
			if((GetTime() - abar_optime) > 4)then
				ABG_RemoveOverlay(ABI_ButtonFromID(67))
				abar_optime = 0
			end
		end
	end
	if(abarbs and UnitAffectingCombat("player")) then
		rbcworkaround = GameTooltip
		rbcworkaround:SetOwner(WorldFrame)
		rbcworkaroundtext = GameTooltipTextLeft1
		local bsfound = false;
		for i=1,32 do
			rbcworkaround:SetUnitBuff("player",i)
			if rbcworkaroundtext:GetText() then 
				buff = trim(rbcworkaroundtext:GetText())
				if(buff == "Battle Shout") then
					bsfound = true;
					ABG_RemoveOverlay(ABI_ButtonFromID(51))
				end
				rbcworkaround:ClearLines()
			end
		end
		rbcworkaround:Hide()
		if(bsfound == false) then
			ABG_AddOverlay(ABI_ButtonFromID(51))
		end
	end
end

function trim(s) -- apparently some blizzard tooltip names for buffs have trailing spaces
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
	
function Abar_Update()
	if this.type=="Target" then
		asp = UnitAttackSpeed("target")
		hd,ld = UnitDamage("target")
		hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)
		abar_weapon = "mob"
	elseif this.type==("Main") then
		asp,offs = UnitAttackSpeed("player")
		hd,ld = UnitDamage("player")
		hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)
		if GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot")) then
			_,_,abar_weapon = string.find((GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))),"(item:%d+)")
		else
			asp = 2
			abar_weapon = "unarmed"
		end
	elseif this.type==("Off") then
		ons,asp = UnitAttackSpeed("player")
		_,_,hd,ld = UnitDamage("player")
		hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)
		if GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot")) then
			_,_,abar_weapon = string.find((GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))),"(item:%d+)")
		else
			asp = this.oldaspd
			abar_weapon = Abar_Oh.wep
		end
	else
		asp,hd,ld =UnitRangedDamage("player")
		hd,ld= hd-math.mod(hd,1),ld-math.mod(ld,1)
	end

	if (abar_weapon == this.wep) then
		abar_aspd = asp-- - math.mod(asp,0.01)
	else
		abar_aspd = this.oldaspd
	end

	local derptime = this.st+abar_aspd
	local ttime = GetTime()
	--local left = 0.00
	tSpark=getglobal(this:GetName().. "Spark")
	tText=getglobal(this:GetName().. "Tmr")
	tInfo=getglobal(this:GetName().."Text")

	if abar.timer==true then
		--left = (derptime-GetTime()) - (math.mod((derptime-GetTime()),.01))
		this.left = ((derptime-GetTime()) - ((derptime-GetTime())*this.attpercent)) - (math.mod(((derptime-GetTime()) - ((derptime-GetTime())*this.attpercent)),.01))
		if (not (this.oldaspd == abar_aspd)) and (abar_weapon == this.wep) then
			this.attpercent = 1-(this.left/abar_aspd)
		end
	--	tText:SetText(this.txt.. "{"..left.."}")
		tText:SetText("{"..this.left.."}")
		tText:Show()
	else
			tText:Hide()
	end

	this:SetValue(ttime)
	this:SetMinMaxValues(this.st,derptime)

	if this.type == "Target" then
		tInfo:SetText(this.type.."["..round(abar_aspd,2).."s]")
	else
		tInfo:SetText(this.type.."["..round(abar_aspd,2).."s]("..hd.."-"..ld..")")
	end
	tSpark:SetPoint("CENTER", this, "LEFT", (ttime-this.st)/(derptime-this.st)*195, 2);
	this.oldaspd = abar_aspd
	if ttime>=derptime then 
	this:Hide() 
	tSpark:SetPoint("CENTER", this, "LEFT",195, 2);
	end

end
function Abar_Mhrs(bartime,text,r,g,b,bartype)
Abar_Mhr.attpercent = 0.000
Abar_MHTime = GetTime() --for hooking into with a macro to time attacks
if GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot")) then
	_,_,Abar_Mhr.wep = string.find((GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))),"(item:%d+)")
else
	Abar_Mhr.wep = "Unarmed"
end
if not(bartype == "Main") then
	Abar_Mhr.oldaspd = UnitRangedDamage("player")
else
	Abar_Mhr.oldaspd = UnitAttackSpeed("player")-- - math.mod(UnitAttackSpeed("player"),0.01)
end
Abar_Mhr.chtd = GetWeaponEnchantInfo()
Abar_Mhr.left = Abar_Mhr.oldaspd
Abar_Mhr:Hide()
Abar_Mhr.type = bartype
Abar_Mhr.txt = text
Abar_Mhr.st = GetTime()
Abar_Mhr.et = GetTime() + bartime
Abar_Mhr:SetStatusBarColor(r,g,b)
Abar_MhrText:SetText(bartype..text)
Abar_Mhr:SetMinMaxValues(Abar_Mhr.st,Abar_Mhr.et)
Abar_Mhr:SetValue(Abar_Mhr.st)
Abar_Mhr:Show()

local _,ohsp = UnitAttackSpeed("player")
local _,_,ohd,old = UnitDamage("player")

if not Abar_Oh.left then
	Abar_Oh.left = 0
end
if not Abar_Oh.st then
	Abar_Oh.st = GetTime()
end

if (abar_firsthit == 1 and ohsp) or (ohsp and (Abar_Oh.left <= 0 and (GetTime()-Abar_Oh.st > ohsp))) then
	Abar_Ohs(ohsp,"["..ohsp.."s]("..ohd.."-"..old..")",0,0,1,"Off")
end

end
function Abar_Ohs(bartime,text,r,g,b,bartype)
Abar_Oh.attpercent = 0.000
_,_,Abar_Oh.wep = string.find((GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))),"(item:%d+)")
_,_,_,Abar_Oh.chtd = GetWeaponEnchantInfo()
Abar_Oh.oldaspd = _,UnitAttackSpeed("player")-- - math.mod(_,UnitAttackSpeed("player"),0.01)
Abar_Oh.left = Abar_Oh.oldaspd
Abar_Oh:Hide()
Abar_Oh.type = bartype
Abar_Oh.txt = text..bartype
Abar_Oh.st = GetTime()
Abar_Oh.et = GetTime() + bartime
Abar_Oh:SetStatusBarColor(r,g,b)
Abar_OhText:SetText(bartype..text)
Abar_Oh:SetMinMaxValues(Abar_Oh.st,Abar_Oh.et)
Abar_Oh:SetValue(Abar_Oh.st)
Abar_Oh:Show()
end
function Abar_Boo(inpt)
if inpt == true then return " ON" else return " OFF" end
end
-----------------------------------------------------------------------------------------------------------------------
-- ENEMY BAR CODE --
-----------------------------------------------------------------------------------------------------------------------

function ebar_VL()
	if not abar.enemy then abar.enemy = 1 end
	ebar_mh:SetPoint("LEFT",ebar_Frame,"TOPLEFT",6,-13)
	ebar_oh:SetPoint("LEFT",ebar_Frame,"TOPLEFT",6,-35)
	ebar_mhText:SetJustifyH("Left")
	ebar_ohText:SetJustifyH("Left")
end
function ebar_event(event)
	if event=="VARIABLES_LOADED" then
	ebar_VL()
	end
	if (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES") and abar.enemy == 1 then
	ebar_start(arg1, 1)
	elseif (event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS" or event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES") and abar.enemy == 1 then
	ebar_start(arg1, 2)
--	message(arg1)
	elseif (event=="CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or event=="CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES") and abar.enemy == 1 then
	ebar_start(arg1, 1)
	end
	--message("ya")
end
function ebar_start(arg1, event)
	local hitter = nil
	local target = nil
	if(event == 1) then
		a,b, hitter = string.find (arg1, "(.+) hits you")
		if not hitter then a,b, hitter = string.find (arg1, "(.+) crits you") end
		if not hitter then a,b, hitter = string.find (arg1, "(.+) misses you")end
		if not hitter then a,b, hitter = string.find (arg1, "(.+) attacks. You ")end
		if hitter == UnitName("target") then ebar_set(hitter) end
	elseif(event == 2) then
		_,_,hitter,target = string.find (arg1, "(.+) hits (.+) for")
		if not hitter then _,_,hitter,target = string.find (arg1, "(.+) crits (.+)") end
		if not hitter then _,_,hitter,target = string.find (arg1, "(.+) misses (.+).")end
		if not hitter then _,_,hitter,target = string.find (arg1, "(.+) attacks. (.+) ")end
		--DEFAULT_CHAT_FRAME:AddMessage(target);
		if (hitter == UnitName("target") and (target == UnitName("targettarget"))) then ebar_set(hitter) end
	end
end
function ebar_set(targ)
 --[[eons = nil
 eoffs = nil]]
	eons,eoffs = UnitAttackSpeed("target")
--[[	
	useless mob dw code, mobs dont return an offhand speed (do they use MH speed for both maybe?)
	
	if eoffs then 		
			eont,eofft=GetTime(),GetTime()
	if ((math.abs((eont-epont)-eons) <= math.abs((eofft-epofft)-eoffs))and not(eonh <= eoffs/eons)) or eoffh >= eons/eoffs then
		if epofft == 0 then epofft=eofft end
		epont = eont
		etons = eons
		eoffh = 0
		eonh = eonh +1
		eons = eons - math.mod(eons,0.01)
		ebar_mhs(eons,"Target Main["..eons.."s]",1,.1,.1)
	else
		epofft = eofft
		eoffh = eoffh+1
		eonh = 0
		eohd,eold = ohd-math.mod(eohd,1),old-math.mod(eold,1)
		eoffs = eoffs - math.mod(eoffs,0.01)
		ebar_ohs(eoffs,"["..eoffs.."s]",1,.1,.1,"Target Off")
	end
	else ]]
	ebar_mhs(eons,"["..round(eons,2).."s]",1,.1,.1,"Target")
	--message("work")
end
--end
function ebar_mhs(bartime,text,r,g,b,bartype)
ebar_mh.attpercent = 0.000
ebar_mh.oldaspd = UnitAttackSpeed("target")-- - math.mod(UnitAttackSpeed("target"),0.01)
ebar_mh.wep = "mob"
ebar_mh:Hide()
ebar_mh.type = bartype
ebar_mh.txt = text
ebar_mh.st = GetTime()
ebar_mh.et = GetTime() + bartime
ebar_mh:SetStatusBarColor(r,g,b)
ebar_mhText:SetText(bartype..text)
ebar_mh:SetMinMaxValues(ebar_mh.st,ebar_mh.et)
ebar_mh:SetValue(ebar_mh.st)
ebar_mh:Show()
end
function ebar_ohs(bartime,text,r,g,b,bartype)
ebat_oh.attpercent = 0.000
ebar_oh.oldaspd = UnitAttackSpeed("target")-- - math.mod(UnitAttackSpeed("target"),0.01)
ebar_oh.wep = "mob"
ebar_oh:Hide()
ebar_oh.type = bartype
ebar_oh.txt = text
ebar_oh.st = GetTime()
ebar_oh.et = GetTime() + bartime
ebar_oh:SetStatusBarColor(r,g,b)
ebar_ohText:SetText(bartype..text)
ebar_oh:SetMinMaxValues(ebar_oh.st,ebar_oh.et)
ebar_oh:SetValue(ebar_oh.st)
ebar_oh:Show()
end

