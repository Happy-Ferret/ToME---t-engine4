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

-- EDGE TODO: Icons, Particles, Timed Effect Particles

newTalent{
	name = "Time Skip",
	type = {"chronomancy/timetravel",1},
	require = chrono_req_high1,
	points = 5,
	cooldown = 4,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {TEMPORAL = 1}, DISABLE = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 250, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return 2 + math.ceil(self:combatTalentScale(self:getTalentLevel(t), 0.3, 2.3)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s is immune!", target.name:capitalize())
			return
		end

		local power = self:combatSpellpower() * (1 + self:callTalent(self.T_SPACETIME_MASTERY, "getPower"))
		local hit = self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s resists!", target.name:capitalize()) return true end
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		if target.dead or target.player then return true end
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		
		-- Replace the target with a temporal instability for a few turns
		local oe = game.level.map(target.x, target.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "temporal instability", image = oe.image, add_mos = {{image="object/temporal_instability.png"}},
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN, self.old_feat)
					game.nicer_tiles:updateAround(game.level, self.target.x, self.target.y)
					game.level:removeEntity(self)
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					self.target.forceLevelup = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		game.logSeen(target, "%s has moved forward in time!", target.name:capitalize())
		game.level:removeEntity(target, true)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage, if the target fails a spell save.  If your target survives, it will be removed from time for %d turns.
		The damage will scale with your Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
}

newTalent{
	name = "Temporal Reprieve",
	type = {"chronomancy/timetravel", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 36) end,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end, -- Limit >10
	no_npc_use = true,
	on_pre_use = function(self, t) return self:canBe("planechange") end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	fixed_cooldown = true,
	action = function(self, t)
		if game.zone.is_temporal_reprieve then
			game.logPlayer(self, "This talent cannot be used from within the reprieve.")
			return
		end
		if game.zone.no_planechange then
			game.logPlayer(self, "This talent cannot be used here.")
			return
		end
		if not (self.player and self.game_ender) then return nil end

		if not self:canBe("planechange") or self.summon_time or self.summon then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		game:onTickEnd(function()
			if self:attr("dead") then return end
			local oldzone = game.zone
			local oldlevel = game.level

			-- Remove them before making the new elvel, this way party memebrs are not removed from the old
			if oldlevel:hasEntity(self) then oldlevel:removeEntity(self) end

			oldlevel.no_remove_entities = true
			local zone = mod.class.Zone.new("temporal-reprieve-talent")
			local level = zone:getLevel(game, 1, 0)
			oldlevel.no_remove_entities = nil

			level:addEntity(self)

			level.source_zone = oldzone
			level.source_level = oldlevel
			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(4, 4, 20, true, {[Map.ACTOR]=true})
			if x1 then
				self:move(x1, y1, true)
				game.level.map:particleEmitter(x1, y1, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
			end

			self.temporal_reprieve_on_die = self.on_die
			self.on_die = function(self, ...)
				self:removeEffect(self.EFF_DREAMSCAPE)
				local args = {...}
				game:onTickEnd(function()
					if self.temporal_reprieve_on_die then self:temporal_reprieve_on_die(unpack(args)) end
					self.on_die, self.temporal_reprieve_on_die = self.temporal_reprieve_on_die, nil
				end)
			end

			game.logPlayer(game.player, "#STEEL_BLUE#You time travel to a quiet place.")
			game.nicer_tiles:postProcessLevelTiles(game.level)

		end)

		self:setEffect(self.EFF_TEMPORAL_REPRIEVE, t.getDuration(self, t), {x=self.x, y=self.y})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Transport yourself to a safe place for %d turns.]]):
		format(duration)
	end,
}

newTalent{
	name = "Echoes From The Past",
	type = {"chronomancy/timetravel", 3},
	require = chrono_req_high3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 10,
	tactical = { ATTACKAREA = {TEMPORAL = 2} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 18, 160, getParadoxSpellpower(self)) end,
	getPercent = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 1, 10, getParadoxSpellpower(self)), 0.5, .1, 0, 0.1575, 5.75) end, -- Limit to <50%
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		self:project(tg, self.x, self.y, DamageType.TEMPORAL_ECHO, t.getPercent(self, t))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_temporal", {radius=tg.radius})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[Creates a temporal echo in a nova around you, in a radius of %d.  Affected targets will take %0.2f temporal damage, as well as %d%% of the difference between their current life and max life as additional temporal damage.
		The percentage and damage scales with your Spellpower.]]):
		format(radius, damDesc(self, DamageType.TEMPORAL, damage), percent)
	end,
}

newTalent{
	name = "Damage Smearing",
	type = {"chronomancy/timetravel", 4},
	mode = "sustained",
	require = chrono_req_high4,
	sustain_paradox = 84,
	cooldown = 24,
	tactical = { DEFEND = 2 },
	points = 5,
	-- called in damage_types to split the damage
	getPercent = function(self, t) return self:combatTalentLimit(t, 50, 10, 30)/100 end, -- Limit < 50%
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[You convert %d%% of all non-temporal damage you receive into temporal damage spread out over %d turns.
		]]):format(percent, duration)
	end,
}

--[=[
newTalent{
	name = "Door to the Past",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req_high4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 150,
	cooldown = 25,
	no_npc_use = true,
	getAnomalyCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	on_learn = function(self, t)
		if not self:knowTalent(self.T_REVISION) then
			self:learnTalent(self.T_REVISION, nil, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_REVISION)
		end
	end,
	do_anomalyCount = function(self, t)
		if self.dttp_anomaly_count == 0 then
			-- check for anomaly
			if not game.zone.no_anomalies and not self:attr("no_paradox_fail") and self:paradoxFailChance() then
				-- Random anomaly
				local ts = {}
				for id, t in pairs(self.talents_def) do
					if t.type[1] == "chronomancy/anomalies" then ts[#ts+1] = id end
				end
				if not silent then game.logPlayer(self, "Your Door to the Past has caused an anomaly!") end
				self:forceUseTalent(rng.table(ts), {ignore_energy=true})
			end
			-- reset count
			self.dttp_anomaly_count = t.getAnomalyCount(self, t)
		else
			self.dttp_anomaly_count = self.dttp_anomaly_count - 1
		end
	end,
	activate = function(self, t)
		if checkTimeline(self) == true then
			return
		end

		-- set the counter
		self.dttp_anomaly_count = t.getAnomalyCount(self, t)

		game:playSoundNear(self, "talents/arcane")
		return {
			game:onTickEnd(function()
				game:chronoClone("revision")
			end),
			particle = self:addParticles(Particles.new("temporal_aura", 1)),
		}
	end,
	deactivate = function(self, t, p)
		if game._chronoworlds then game._chronoworlds = nil end
		self.dttp_anomaly_count = nil
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local count = t.getAnomalyCount(self, t)
		return ([[This powerful spell allows you to mark a point in time that you can later return to by casting Revision (which you'll automatically learn upon learning this spell).  Maintaining such a doorway causes constant strain on the spacetime continuum and can possibly trigger an anomaly (using your current anomaly chance) once every %d turns.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.
		Additional talent points will increase the time between anomaly checks.]]):
		format(count)
	end,
}

newTalent{
	name = "Revision",
	type = {"chronomancy/other", 1},
	type_no_req = true,
	points = 1,
	message = "@Source@ revises history.",
	cooldown = 50,
	paradox = 25,
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:isTalentActive(self.T_DOOR_TO_THE_PAST) then if not silent then game.logPlayer(self, "Door to the Past must be active to use this talent.") end return false end return true end,
	no_unlearn_last = true,
	action = function(self, t)

		-- Prevent Revision After Death
		if game._chronoworlds == nil then
			game.logPlayer(game.player, "#LIGHT_RED#Your spell fizzles.")
			return
		end

		game:onTickEnd(function()
			if not game:chronoRestore("revision", true) then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the spacetime continuum to a previous state!")

			-- Manualy start the cooldown of the "old player"
			game.player:startTalentCooldown(t)
			game.player:incParadox(t.paradox * (1 + (game.player.paradox / 300)))
			game.player:forceUseTalent(game.player.T_DOOR_TO_THE_PAST, {ignore_energy=true})
			-- remove anomaly count
			if self.dttp_anomaly_count then self.dttp_anomaly_count = nil end
			if game._chronoworlds then game._chronoworlds = nil end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Casting Revision will return you to the point in time you created a temporal marker using Door to the Past.]])
		:format()
	end,
}]=]
