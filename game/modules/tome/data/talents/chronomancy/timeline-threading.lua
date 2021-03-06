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
	name = "Gather the Threads",
	type = {"chronomancy/timeline-threading", 1},
	require = chrono_req_high1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 12,
	tactical = { BUFF = 2 },
	getThread = function(self, t) return self:combatTalentScale(t, 7, 30, 0.75) end,
	getReduction = function(self, t) return self:combatTalentScale(t, 3.6, 15, 0.75) end,
	action = function(self, t)
		self:setEffect(self.EFF_GATHER_THE_THREADS, 5, {power=t.getThread(self, t), reduction=t.getReduction(self, t)})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local primary = t.getThread(self, t)
		local reduction = t.getReduction(self, t)
		return ([[You begin to gather energy from other timelines. Your Spellpower will increase by %0.2f on the first turn and %0.2f more each additional turn.
		The effect ends either when you cast a spell, or after five turns.
		Eacn turn the effect is active, your Paradox will be reduced by %d.
		This spell will not break Spacetime Tuning, nor will it be broken by activating Spacetime Tuning.]]):format(primary + (primary/5), primary/5, reduction)
	end,
}

newTalent{
	name = "Rethread",
	type = {"chronomancy/timeline-threading", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 4,
	tactical = { ATTACK = {TEMPORAL = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200, getParadoxSpellpower(self)) end,
	getReduction = function(self, t) return self:combatTalentScale(t, 1.2, 5, 0.75) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y, t.paradox)
		self:project(tg, x, y, DamageType.RETHREAD, {dam=self:spellCrit(t.getDamage(self, t)), reduction = t.getReduction(self, t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "temporalbeam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local reduction = t.getReduction(self, t)
		return ([[Creates a wake of temporal energy that deals %0.2f damage in a beam, as you attempt to rethread the timeline.  Affected targets may be stunned, blinded, pinned, or confused for 3 turns.
		Each target you hit with Rethread will reduce your Paradox by %0.1f.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), reduction)
	end,
}

newTalent{
	name = "Temporal Clone",
	type = {"chronomancy/timeline-threading", 3},
	require = chrono_req_high3,
	points = 5,
	cooldown = 30,
	paradox = function (self, t) return getParadoxCost(self, t, 30) end,
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	range = 6,
	no_npc_use = true,
	getDuration = function(self, t) -- limit < cooldown (30)
		return math.floor(self:combatTalentLimit(self:getTalentLevel(t), t.cooldown, 4, 8))
	end,
	getSize = function(self, t) return 2 + math.ceil(self:getTalentLevelRaw(t) / 2 ) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty then return nil end
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local allowed = t.getSize(self, t)

		if target.rank >= 3.5 or -- No boss
			target:reactionToward(self) >= 0 or -- No friends
			target.size_category > allowed
			then
			game.logSeen(target, "%s resists!", target.name:capitalize())
			return true
		end

		local m = target:cloneFull{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			exp_worth = 0, -- bug fix
			summon_time = t.getDuration(self, t),
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		
		m.energy.value = 0
		m.life = m.life
		m.forceLevelup = function() end
		-- Handle special things
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "temporal_teleport")

		-- force target to attack double
		local a = game.level.map(tx, ty, Map.ACTOR)
		if a and self:reactionToward(a) < 0 then
			a:setTarget(m)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local allowed = t.getSize(self, t)
		local size = "gargantuan"
		if allowed < 4 then
			size = "medium"
		elseif allowed < 5 then
			size = "big"
		elseif allowed < 6 then
			size = "huge"
		end
		return ([[Pulls a %s size or smaller copy of the target from another timeline; the copy stays for %d turns. The copy and the target will be compelled to attack each other immediately.]]):
		format(size, duration)
	end,
}


