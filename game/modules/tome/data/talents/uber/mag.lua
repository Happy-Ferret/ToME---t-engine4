-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

uberTalent{
	name = "Spectral Shield",
	mode = "passive",
	require = { special={desc="Block talent, have mana and a block value over 200.", fct=function(self)
		return self:knowTalent(self.T_BLOCK) and self:getTalentFromId(self.T_BLOCK).getBlockValue(self) >= 200 and self:getMaxMana() >= 70
	end} },
	on_learn = function(self, t)
		self:attr("spectral_shield", 1)
		self:attr("max_mana", -70)
	end,
	on_unlearn = function(self, t)
		self:attr("spectral_shield", -1)
		self:attr("max_mana", 70)
	end,
	info = function(self, t)
		return ([[Infusing your shield with raw magic your Block can now block any damage type
		Your maximum mana will be premanently reduced by 70 to create the effect.]])
		:format()
	end,
}
