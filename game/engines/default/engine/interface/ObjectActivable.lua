-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

require "engine.class"

--- Handles activable objects, much more simple than actor's resource
-- It can define simple activations, complex ones that use power and it can also activate talent (ActorTalents interface must also be used on the Object class in this case)
module(..., package.seeall, class.make)

function _M:init(t)
	if t.max_power then
		self.power = t.max_power
		self.max_power = t.max_power
		self.power_regen = t.power_regen or 0
	end
end

--- Regen resources, shout be called in your actor's act() method
function _M:regenPower()
	if self.power_regen then self.power = util.bound(self.power + self.power_regen, 0, self.max_power) end
end

function _M:canUseObject()
	if self.use_simple or self.use_power or self.use_talent then
		return true
	end
end

function _M:getUseDesc()
	if self.use_power then
		return ("It can be used to %s, costing %d power out of %d/%d."):format(self.use_power.name, self.use_power.power, self.power, self.max_power)
	elseif self.use_simple then
		return ("It can be used to %s."):format(self.use_simple.name)
	elseif self.use_talent then
		if not self.use_talent.power then                                                                        print(self:getTalentFromId(self.use_talent.id),self.use_talent.id)
			return ("It can be used to activate talent: %s (level %d)."):format(self:getTalentFromId(self.use_talent.id).name, self.use_talent.level)
		else
			return ("It can be used to activate talent: %s (level %d), costing %d power out of %d/%d."):format(self:getTalentFromId(self.use_talent.id).name, self.use_talent.level, self.use_talent.power, self.power, self.max_power)
		end
	end
end

function _M:useObject(who)
	if self.use_power then
		if self.power >= self.use_power.power then
			local ret, no_power = self.use_power.use(self, who)
			if not no_power then self.power = self.power - self.use_power.power end
			return ret
		else
			if self.power_regen and self.power_regen ~= 0 then
				game.logPlayer(who, "%s is still recharging.", self:getName{no_count=true})
			else
				game.logPlayer(who, "%s can not be used anymore.", self:getName{no_count=true})
			end
		end
	elseif self.use_simple then
		local ret = self.use_simple.use(self, who)
		return ret
	elseif self.use_talent then
		if not self.use_talent.power or self.power >= self.use_talent.power then
			self.power = self.power - self.use_talent.power
			return self:useTalent(self.use_talent.id, who, self.use_talent.level)
		else
			if self.power_regen and self.power_regen ~= 0 then
				game.logPlayer(who, "%s is still recharging.", self:getName{no_count=true})
			else
				game.logPlayer(who, "%s can not be used anymore.", self:getName{no_count=true})
			end
		end
	end
end
