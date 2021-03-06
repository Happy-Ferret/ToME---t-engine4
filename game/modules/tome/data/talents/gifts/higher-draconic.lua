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
	name = "Prismatic Slash",
	type = {"wild-gift/higher-draconic", 1},
	require = gifts_req_high1,
	points = 5,
	random_ego = "attack",
	equilibrium = 20,
	cooldown = 16,
	range = 1,
	tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1 } },
	requires_target = true,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.0) end,
	getBurstDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 230) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
	on_learn = function(self, t) 
		self.combat_physresist = self.combat_physresist + 1
		self.combat_spellresist = self.combat_spellresist + 1
		self.combat_mentalresist = self.combat_mentalresist + 1
	end,
	on_unlearn = function(self, t) 
		self.combat_physresist = self.combat_physresist - 1
		self.combat_spellresist = self.combat_spellresist - 1
		self.combat_mentalresist = self.combat_mentalresist - 1
	end,
	action = function(self, t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local elem = rng.table{"phys", "cold", "fire", "lightning", "acid",}

			if elem == "phys" then
				self:attackTarget(target, DamageType.PHYSICAL, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.SAND, {dur=3, dam=self:mindCrit(t.getBurstDamage(self, t))})
				game.level.map:particleEmitter(x, y, tg.radius, "ball_matter", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "cold" then
				self:attackTarget(target, DamageType.ICE, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.ICE, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_ice", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "fire" then
				self:attackTarget(target, DamageType.FIREBURN, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.FIREBURN, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_fire", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "lightning" then
				self:attackTarget(target, DamageType.LIGHTNING_DAZE, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.LIGHTNING_DAZE, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_lightning", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "acid" then
				self:attackTarget(target, DamageType.ACID_DISARM, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.ACID_DISARM, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_acid", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			end
		return true
	end,
	info = function(self, t)
		local burstdamage = t.getBurstDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Unleash raw, chaotic elemental damage upon your enemy.
		You strike your enemy for %d%% weapon damage in one of blinding sand, disarming acid, freezing ice, stunning lightning or burning flames, with equal odds.
		Additionally, you will cause a burst that deals %0.2f of that damage to enemies in radius %d, regardless of if you hit with the blow.
		Each point in Prismatic Slash increase your Physical, Spell and Mind Saves by 1.]]):format(100 * self:combatTalentWeaponDamage(t, 1.2, 2.0), burstdamage, radius)
	end,
}

newTalent{
	name = "Venomous Breath",
	type = {"wild-gift/higher-draconic", 2},
	require = gifts_req_high2,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes venom!",
	tactical = { ATTACKAREA = { poison = 2 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 60, 650) end,
	getEffect = function(self, t) return self:combatTalentLimit(t, 100, 18, 50) end, -- Limit < 100%
	on_learn = function(self, t) self.resists[DamageType.NATURE] = (self.resists[DamageType.NATURE] or 0) + 2 end,
	on_unlearn = function(self, t) self.resists[DamageType.NATURE] = (self.resists[DamageType.NATURE] or 0) - 2 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.INSIDIOUS_POISON, {dam=self:mindCrit(t.getDamage(self,t)), dur=6, heal_factor=t.getEffect(self,t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_slime", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		
		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="poisonwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		local effect = t.getEffect(self, t)
		return ([[You breathe insidious poison in a frontal cone of radius %d. Any target caught in the area will take %0.2f nature damage each turn for 6 turns.
		The poison also reduces the healing of enemies poisoned by %d%% while it is in effect.
		The damage will increase with your Strength, and the critical chance is based on your Mental crit rate.
		Each point in Venomous Breath also increases your nature resistance by 2%%.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, t.getDamage(self,t)/6), effect)
	end,
}

newTalent{
	name = "Wyrmic Guile",
	type = {"wild-gift/higher-draconic", 3},
	require = gifts_req_high3,
	points = 5,
	mode = "passive",
	resistKnockback = function(self, t) return self:combatTalentLimit(t, 1, .17, .5) end, -- Limit < 100%
	resistBlindStun = function(self, t) return self:combatTalentLimit(t, 1, .07, .25) end, -- Limit < 100%
	on_learn = function(self, t)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 2
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 2
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "knockback_immune", t.resistKnockback(self, t))
		self:talentTemporaryValue(p, "stun_immune", t.resistBlindStun(self, t))
		self:talentTemporaryValue(p, "blind_immune", t.resistBlindStun(self, t))
	end,
	info = function(self, t)
		return ([[You have the mental prowess of a Wyrm.
		Your Cunning is increased by %d.
		You gain %d%% knockback resistance, and your blindness and stun resistances are increased by %d%%.]]):format(2*self:getTalentLevelRaw(t), 100*t.resistKnockback(self, t), 100*t.resistBlindStun(self, t))
	end,
}

newTalent{
	name = "Chromatic Fury",
	type = {"wild-gift/higher-draconic", 4},
	require = gifts_req_high4,
	points = 5,
	mode = "passive",
	resistPen = function(tl)
		if tl <=0 then return 0 end
		return math.floor(mod.class.interface.Combat.combatTalentLimit({}, tl, 100, 4, 20))
	end, -- Limit < 100%
	on_learn = function(self, t)
		self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 0.5
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 0.5
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 0.5
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 0.5

		local rpchange = t.resistPen(self:getTalentLevelRaw(t)) - t.resistPen(self:getTalentLevelRaw(t)-1)
		self.resists_pen[DamageType.PHYSICAL] = (self.resists_pen[DamageType.PHYSICAL] or 0) + rpchange 
		self.resists_pen[DamageType.COLD] = (self.resists_pen[DamageType.COLD] or 0) + rpchange 
		self.resists_pen[DamageType.FIRE] = (self.resists_pen[DamageType.FIRE] or 0) + rpchange
		self.resists_pen[DamageType.LIGHTNING] = (self.resists_pen[DamageType.LIGHTNING] or 0) + rpchange
		self.resists_pen[DamageType.ACID] = (self.resists_pen[DamageType.ACID] or 0) + rpchange 

		self.inc_damage[DamageType.PHYSICAL] = (self.inc_damage[DamageType.PHYSICAL] or 0) + 2
		self.inc_damage[DamageType.COLD] = (self.inc_damage[DamageType.COLD] or 0) + 2
		self.inc_damage[DamageType.FIRE] = (self.inc_damage[DamageType.FIRE] or 0) + 2
		self.inc_damage[DamageType.LIGHTNING] = (self.inc_damage[DamageType.LIGHTNING] or 0) + 2
		self.inc_damage[DamageType.ACID] = (self.inc_damage[DamageType.ACID] or 0) + 2
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 0.5
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 0.5
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 0.5
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 0.5

		local rpchange = t.resistPen(self:getTalentLevelRaw(t)) - t.resistPen(self:getTalentLevelRaw(t)+1)
		self.resists_pen[DamageType.PHYSICAL] = (self.resists_pen[DamageType.PHYSICAL] or 0) + rpchange
		self.resists_pen[DamageType.COLD] = (self.resists_pen[DamageType.COLD] or 0) + rpchange
		self.resists_pen[DamageType.FIRE] = (self.resists_pen[DamageType.FIRE] or 0) + rpchange
		self.resists_pen[DamageType.LIGHTNING] = (self.resists_pen[DamageType.LIGHTNING] or 0) + rpchange
		self.resists_pen[DamageType.ACID] = (self.resists_pen[DamageType.ACID] or 0) + rpchange

		self.inc_damage[DamageType.PHYSICAL] = (self.inc_damage[DamageType.PHYSICAL] or 0) - 2
		self.inc_damage[DamageType.COLD] = (self.inc_damage[DamageType.COLD] or 0) - 2
		self.inc_damage[DamageType.FIRE] = (self.inc_damage[DamageType.FIRE] or 0) - 2
		self.inc_damage[DamageType.LIGHTNING] = (self.inc_damage[DamageType.LIGHTNING] or 0) - 2
		self.inc_damage[DamageType.ACID] = (self.inc_damage[DamageType.ACID] or 0) - 2
	end,
	info = function(self, t)
		return ([[You have gained the full power of the multihued dragon, and your mastery over the elements is complete.
		Increases physical, fire, cold, lightning and acid damage by %d%%, and your resistance penetration in those elements by %d%%.
		Each point in Chromatic Fury also increases your resistances to physical, fire, cold, lightning and acid by 0.5%%.]])
		:format(2*self:getTalentLevelRaw(t), t.resistPen(self:getTalentLevelRaw(t)))
	end,
}
