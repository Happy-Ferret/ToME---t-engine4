-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Psychic Lobotomy",
	type = {"psionic/psychic-assault", 1},
	points = 5,
	cooldown = 6,
	range = 10,
	psi = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { MIND = 2 }, DISABLE = { confusion = 2 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 250) end,
	getCunningDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getDuration = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	no_npc = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		local ai = target.ai or nil		
		
		self:project(tg, x, y, DamageType.MIND, {dam=self:mindCrit(t.getDamage(self, t))})
		if target:canBe("confused") then
			target:setEffect(target.EFF_LOBOTOMIZED, t.getDuration(self, t), {src = self, ai=target.ai, power=t.getCunningDamage(self, t), apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s resists the lobotomy!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local cunning_damage = t.getCunningDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f mind damage and cripples the target's higher mental functions, reducing cunning by %d and preventing the target from making tactical decisions for %d turns.
		The damage and cunning penalty will scale with your Mindpower.]]):
		format(damDesc(self, DamageType.MIND, (damage)), cunning_damage, duration)
	end,
}


-- Idea, Brain Rupture