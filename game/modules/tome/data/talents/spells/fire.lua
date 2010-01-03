newTalent{
	name = "Flame",
	type = {"spell/fire",1},
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, self:spellCrit(15 + self:combatSpellpower(0.4) * self:getTalentLevel(t)))
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self, t)
		return ([[Conjures up a bolt of fire setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(15 + self:combatSpellpower(0.4) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Globe of Light",
	type = {"spell/fire",2},
	points = 5,
	mana = 5,
	cooldown = 14,
	action = function(self, t)
		local tg = {type="ball", range=0, friendlyfire=false, radius=5 + self:getTalentLevel(t)}
		self:project(tg, self.x, self.y, DamageType.LIGHT, 1)
		if self:getTalentLevel(t) >= 3 then
			self:project(tg, self.x, self.y, DamageType.BLIND, 3 + self:getTalentLevel(t))
		end
		return true
	end,
	require = { stat = { mag=14 }, },
	info = function(self, t)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.
		The radius will increase with the Magic stat]]):format(5 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",3},
	points = 5,
	mana = 40,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 15,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevel(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(28 + self:combatSpellpower(0.4) * self:getTalentLevel(t)))
		return true
	end,
	require = { stat = { mag=20 } },
	info = function(self, t)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d.
		The damage will increase with the Magic stat]]):format(28 + self:combatSpellpower(0.4) * self:getTalentLevel(t), 1 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Inferno",
	type = {"spell/fire",4},
	points = 5,
	mana = 200,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 40,
	},
	range = 20,
	action = function(self, t)
		local duration = 5 + self:getTalentLevel(t)
		local radius = 5
		local dam = 15 + self:combatSpellpower(0.15) * self:getTalentLevel(t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = game.target:pointAtRange(self.x, self.y, x, y, 15)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.NETHERFLAME, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=180, color_bg=30, color_bb=60}
		)
		return true
	end,
	require = { stat = { mag=34 } },
	info = function(self, t)
		return ([[Raging flames burn foes and allies alike doing %0.2f netherflame damage in a radius of 5 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(15 + self:combatSpellpower(0.15) * self:getTalentLevel(t), 5 + self:getTalentLevel(t))
	end,
}
