-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org


newTalent{
	name = "Stunning Blow", short_name = "STUNNING_BLOW_ASSAULT", image = "talents/stunning_blow.png",
	type = {"technique/2hweapon-assault", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 8,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s resists the stunning blow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target is stunned for %d turns.
		The stun chance increases with your Physical Power.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1, 1.5), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Fearless Cleave",
	type = {"technique/2hweapon-assault", 2},
	require = techs_req2,
	points = 5,
	cooldown = 0,
	stamina = 16,
	no_energy = false,
	tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 0.5 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dir = util.getDir(x, y, self.x, self.y) or 6
		local moved = 0.75
		if self:canMove(x, y) then
			self:move(x, y)
			moved = 1
		end

		local fx, fy = util.coordAddDir(self.x, self.y, dir)
		local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
		local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
		local target, lt, rt = game.level.map(fx, fy, Map.ACTOR), game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		if target then self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.9, 2) * moved) end
		if lt then     self:attackTargetWith(lt, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.9, 2) * moved) end
		if rt then     self:attackTargetWith(rt, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.9, 2) * moved) end

		return true
	end,
	info = function(self, t)
		return ([[Take a step toward your foes using the momentum to cleave all creatures in a 3 wide arc in front of you for %d%% weapon damage.
		If you failed to move the damage is instead %d%%.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.9, 2), 100 * self:combatTalentWeaponDamage(t, 0.9, 2) * 0.75)
	end,
}

newTalent{
	name = "Death Dance", short_name = "DEATH_DANCE_ASSAULT", image = "talents/death_dance.png",
	type = {"technique/2hweapon-assault", 3},
	require = techs_req3,
	points = 5,
	cooldown = 10,
	stamina = 30,
	tactical = { ATTACKAREA = { weapon = 3 } },
	range = 0,
	radius = 1,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getBleed = function(self, t) return self:combatTalentScale(t, 0.5, 1.5) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Death Dance without a two-handed weapon!")
			return nil
		end

		local scale = nil
		if self:getTalentLevel(t) >= 3 then
			scale = t.getBleed(self, t)
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local oldlife = target.life
				self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.4, 2.1))
				local life_diff = oldlife - target.life
				if life_diff > 0 and target:canBe('cut') and scale then
					target:setEffect(target.EFF_CUT, 5, {power=life_diff * scale / 5, src=self, apply_power=self:combatPhysicalpower()})
				end
			end
		end)

		self:addParticles(Particles.new("meleestorm", 1, {}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around, extending your weapon and damaging all targets around you for %d%% weapon damage.
		At level 3 all damage done will also make the targets bleed for an additional %d%% damage over 5 turns]]):format(100 * self:combatTalentWeaponDamage(t, 1.4, 2.1), t.getBleed(self, t) * 100)
	end,
}

newTalent{
	name = "Execution",
	type = {"technique/2hweapon-assault", 4},
	require = techs_req4,
	points = 5,
	cooldown = 8,
	stamina = 25,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	getPower = function(self, t) return self:combatTalentScale(t, 1.6, 4.3) end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local perc = 1 - (target.life / target.max_life)
		local power = t.getPower()

		self.turn_procs.auto_phys_crit = true
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, power * perc * 100)
		self.turn_procs.auto_phys_crit = nil
		return true
	end,
	info = function(self, t)
		return ([[Tries to perform a killing blow. For each missing %% of life of your target you deal %0.2f%% more weapon damage (I.E: at 30%% remaining life you would deal %0.2f%% weapon damage).
		The blow is an automatic critical hit.]]):
		format(t.getPower(self, t), t.getPower(self, t) * 70)
	end,
}