require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Target = require "engine.Target"
local Talents = require "engine.interface.ActorTalents"

--- Interface to add ToME combat system
module(..., package.seeall, class.make)

--- Checks what to do with the target
-- Talk ? attack ? displace ?
function _M:bumpInto(target)
	local reaction = self:reactionToward(target)
	if reaction < 0 then
		return self:attackTarget(target)
	elseif reaction >= 0 then
		-- Talk ?
		if self.player and target.can_talk then
			-- TODO: implement !
		elseif target.player and self.can_talk then
			-- TODO: implement! request the player to talk
		elseif self.move_others then
			-- Displace
			game.level.map:remove(self.x, self.y, Map.ACTOR)
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			game.level.map(self.x, self.y, Map.ACTOR, target)
			game.level.map(target.x, target.y, Map.ACTOR, self)
			self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
		end
	end
end

--- Makes the death happen!
--[[
The ToME combat system has the following attributes:
- attack: increases chances to hit against high defence
- defence: increases chances to miss against high attack power
- armor: direct reduction of damage done
- armor penetration: reduction of target's armor
- damage: raw damage done
]]
function _M:attackTarget(target, damtype, mult, noenergy)
	local speed, hit = nil, false

	-- Cancel stealth early if we are noticed
	if self:isTalentActive(self.T_STEALTH) and target:canSee(self) then
		self:useTalent(self.T_STEALTH)
		self.changed = true
		game.logPlayer(self, "%s notices you at the last moment!", target.name:capitalize())
	end

	-- All weaponsin main hands
	if self:getInven(self.INVEN_MAINHAND) then
		for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
			if o.combat then
				local s, h = self:attackTargetWith(target, o.combat, damtype, mult)
				speed = math.max(speed or 0, s)
				hit = hit or h
			end
		end
	end
	-- All wpeaons in off hands
	-- Offhand atatcks are with a damage penality, taht can be reduced by talents
	if self:getInven(self.INVEN_OFFHAND) then
		local offmult = (mult or 1) / 2
		if self:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
			offmult = (mult or 1) / (2 - (self:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
		end
		for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
			if o.combat then
				local s, h = self:attackTargetWith(target, o.combat, damtype, offmult)
				speed = math.max(speed or 0, s)
				hit = hit or h
			end
		end
	end

	-- Barehanded ?
	if not speed then
		local s, h = self:attackTargetWith(target, self.combat, damtype, mult)
		speed = math.max(speed or 0, s)
		hit = hit or h
	end

	-- We use up our own energy
	if speed and not noenergy then
		self:useEnergy(game.energy_to_act * speed)
		self.did_energy = true
	end

	-- Cancel stealth!
	self:breakStealth()
	return hit
end

--- Computes a logarithmic chance to hit, opposing chance to hit to chance to miss
-- This will be used for melee attacks, physical and spell resistance
function _M:checkHit(atk, def, min, max, factor)
print("checkHit", atk, def)
	if atk == 0 then atk = 1 end
	local hit = nil
	factor = factor or 5
	if atk > def then
		local d = atk - def
		hit = math.log10(1 + 5 * d / 50) * 100 + 50
	else
		local d = def - atk
		hit = -math.log10(1 + 5 * d / 50) * 100 + 50
	end
	hit = util.bound(hit, min or 5, max or 95)
print("=> chance to hit", hit)
	return rng.percent(hit), hit
end

--- Attacks with one weapon
function _M:attackTargetWith(target, weapon, damtype, mult)
	damtype = damtype or DamageType.PHYSICAL
	mult = mult or 1

	-- Does the blow connect? yes .. complex :/
	local atk, def = self:combatAttack(weapon), target:combatDefense()
	local dam, apr, armor = self:combatDamage(weapon), self:combatAPR(weapon), target:combatArmor()
	print("[ATTACK] with", weapon.name, " to ", target.name, " :: ", dam, apr, armor, "::", mult)

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	if self:checkHit(atk, def) then
		local dam = math.max(0, dam - math.max(0, armor - apr))
		local damrange = self:combatDamageRange(weapon)
		dam = rng.range(dam, dam * damrange)
		print("[ATTACK] after range", dam)
		local crit
		dam = dam * mult
		dam, crit = self:physicalCrit(dam, weapon)
		print("[ATTACK] after crit", dam)
		if crit then game.logSeen(self, "%s performs a critical stike!", self.name:capitalize()) end
		DamageType:get(damtype).projector(self, target.x, target.y, damtype, math.max(0, dam))
		hitted = true
	else
		game.logSeen(target, "%s misses %s.", self.name:capitalize(), target.name)
	end

	-- Reactive target on hit damage
	if hitted then for typ, dam in pairs(target.on_melee_hit) do
		DamageType:get(typ).projector(target, self.x, self.y, typ, dam)
	end end

	-- Riposte!
	if not hitted and target:knowTalent(target.T_RIPOSTE) and rng.percent(util.bound(target:getTalentLevel(target.T_RIPOSTE) * target:getDex(50), 10, 80)) then
		game.logSeen(self, "%s ripostes!", target.name:capitalize())
		target:attackTarget(self, nil, nil, true)
	end

	return self:combatSpeed(weapon), hitted
end

local weapon_talents = {
	sword = Talents.T_SWORD_MASTERY,
	axe =   Talents.T_AXE_MASTERY,
	mace =  Talents.T_MACE_MASTERY,
	knife = Talents.T_KNIFE_MASTERY,
}

--- Checks weapon training
function _M:combatCheckTraining(weapon)
	if not weapon.talented then return 0 end
	if not weapon_talents[weapon.talented] then return 0 end
	return self:getTalentLevel(weapon_talents[weapon.talented])
end

--- Gets the defense
function _M:combatDefense()
	return self.combat_def + (self:getDex() - 10) * 0.35
end

--- Gets the armor
function _M:combatArmor()
	return self.combat_armor
end

--- Gets the attack
function _M:combatAttack(weapon)
	weapon = weapon or self.combat
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getStr(50) - 5) + (self:getDex(50) - 5)
end

--- Gets the attack using only strength
function _M:combatAttackStr(weapon)
	weapon = weapon or self.combat
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getStr(100) - 10)
end

--- Gets the attack using only dexterity
function _M:combatAttackDex(weapon)
	weapon = weapon or self.combat
	return self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + (self:getDex(100) - 10)
end

--- Gets the armor penetration
function _M:combatAPR(weapon)
	weapon = weapon or self.combat
	return self.combat_apr + (weapon.apr or 0)
end

--- Gets the weapon speed
function _M:combatSpeed(weapon)
	weapon = weapon or self.combat
	return self.combat_physspeed + (weapon.physspeed or 1)
end

--- Gets the crit rate
function _M:combatCrit(weapon)
	weapon = weapon or self.combat
	local addcrit = 0
	if weapon.talented and weapon.talented == "knife" and self:knowTalent(Talents.T_LETHALITY) then
		addcrit = 1 + self:getTalentLevel(Talents.T_LETHALITY) * 1.3
	end
	return self.combat_physcrit + (self:getCun() - 10) * 0.3 + (weapon.physcrit or 1) + addcrit
end

--- Gets the damage range
function _M:combatDamageRange(weapon)
	weapon = weapon or self.combat
	return (self.combat_damrange or 0) + (weapon.damrange or 1.1)
end

--- Gets the damage
function _M:combatDamage(weapon)
	weapon = weapon or self.combat

	local sub_con_to_str = false
	if weapon.talented and weapon.talented == "knife" and self:knowTalent(Talents.T_LETHALITY) then sub_con_to_str = true end

	local add = 0
	if weapon.dammod then
		for stat, mod in pairs(weapon.dammod) do
			if sub_con_to_str and stat == "str" then stat = "cun" end
			add = add + (self:getStat(stat) - 10) * mod
		end
	end
	local talented_mod = self:combatCheckTraining(weapon)
	return self.combat_dam + (weapon.dam or 1) * (1 + talented_mod / 4) + add
end

--- Gets spellpower
function _M:combatSpellpower(mod)
	mod = mod or 1
	return (self.combat_spellpower + self:getMag()) * mod
end

--- Gets spellcrit
function _M:combatSpellCrit()
	return self.combat_spellcrit + (self:getCun() - 10) * 0.3 + 1
end

--- Gets spellspeed
function _M:combatSpellSpeed()
	return self.combat_spellspeed + 1
end

--- Computes physical crit for a damage
function _M:physicalCrit(dam, weapon)
	if self:isTalentActive(self.T_STEALTH) and self:knowTalent(self.T_SHADOWSTRIKE) then
		return dam * (2 + self:getTalentLevel(self.T_SHADOWSTRIKE) / 5), true
	end

	local chance = self:combatCrit(weapon)
	local crit = false
	if rng.percent(chance) then
		dam = dam * 2
		crit = true
	end
	return dam, crit
end

--- Computes spell crit for a damage
function _M:spellCrit(dam)
	if self:isTalentActive(self.T_STEALTH) and self:knowTalent(self.T_SHADOWSTRIKE) then
		return dam * (2 + self:getTalentLevel(self.T_SHADOWSTRIKE) / 5), true
	end

	local chance = self:combatSpellCrit()
	local crit = false
	if rng.percent(chance) then
		dam = dam * 2
		crit = true
	end
	return dam, crit
end

--- Computes physical resistance
function _M:combatPhysicalResist()
	return self.combat_physresist + (self:getCon() + self:getStr()) * 0.25
end

--- Computes spell resistance
function _M:combatSpellResist()
	return self.combat_spellresist + (self:getMag() + self:getWil()) * 0.25
end

--- Computes mental resistance
function _M:combatMentalResist()
	return self.combat_mentalresist + (self:getCun() + self:getWil()) * 0.25
end


--- Check if the actor has a two handed weapon
function _M:hasTwoHandedWeapon()
	local weapon = self:getInven("MAINHAND")[1]
	if not weapon or not weapon.twohanded then
		return nil
	end
	return weapon
end

--- Check if the actor has a shield
function _M:hasShield()
	local shield = self:getInven("OFFHAND")[1]
	if not shield or not shield.special_combat then
		return nil
	end
	return shield
end