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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

----------------------------------------------------------------
-- Weapon Properties
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="damage", points = 1, rarity = 10, level_range = {1, 50},
	special_combat = { dam = resolvers.randartmax(1, 20), },
}
newEntity{ theme={physical=true}, name="apr", points = 1, rarity = 10, level_range = {1, 50},
	special_combat = { apr = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true}, name="crit", points = 1, rarity = 10, level_range = {1, 50},
	special_combat = { physcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true, spell=true}, name="phasing", points = 1, rarity = 10, level_range = {1, 50},
	special_combat = { phasing = resolvers.randartmax(1, 50), },
}
----------------------------------------------------------------
-- Melee damage projection
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.PHYSICAL] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.MIND] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={acid=true}, name="acid melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.ACID] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.LIGHTNING] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={fire=true}, name="fire melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.FIRE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={cold=true}, name="cold melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.COLD] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={light=true}, name="light melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.LIGHT] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={dark=true}, name="dark melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.DARKNESS] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={blight=true, spell=true}, name="blight melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.BLIGHT] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={nature=true}, name="nature melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.NATURE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={arcane=true, spell=true}, name="arcane melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.ARCANE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={temporal=true}, name="temporal melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.TEMPORAL] = resolvers.randartmax(1, 20), }, },
}
----------------------------------------------------------------
-- Melee damage Projection (rare)
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical gravity melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.GRAVITY] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={acid=true}, name="acid blind melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.ACID_BLIND] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning daze melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.LIGHTNING_DAZE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={fire=true}, name="burn melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.FIREBURN] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={cold=true}, name="ice melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.ICE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={antimagic=true}, name="manaburn melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.MANA_BURN] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={nature=true, antimagic=true}, name="slime melee", points = 1, rarity = 18, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.SLIME] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={nature=true}, name="insidious poison melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.INSIDIOUS_POISON] = resolvers.randartmax(1, 50), }, },  -- this gets divided by 7 for damage
}
newEntity{ theme={temporal=true}, name="wasting melee", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { melee_project = {[DamageType.WASTING] = resolvers.randartmax(1, 20), }, },
}
----------------------------------------------------------------
-- Melee damage burst
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.PHYSICAL] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.MIND] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={acid=true}, name="acid burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.ACID] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.LIGHTNING] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={fire=true}, name="fire burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.FIRE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={cold=true}, name="cold burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.COLD] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={light=true}, name="light burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.LIGHT] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={dark=true}, name="dark burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.DARKNESS] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={blight=true}, name="blight burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.BLIGHT] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={nature=true}, name="nature burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.NATURE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={arcane=true}, name="arcane burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.ARCANE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={temporal=true}, name="temporal burst", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_hit = {[DamageType.TEMPORAL] = resolvers.randartmax(1, 20), }, },
}
----------------------------------------------------------------
-- Melee damage burst(crit)
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.PHYSICAL] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.MIND] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={acid=true}, name="acid burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.ACID] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={lightning=true}, name="lightning burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.LIGHTNING] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={fire=true}, name="fire burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.FIRE] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={cold=true}, name="cold burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.COLD] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={light=true}, name="light burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.LIGHT] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={dark=true}, name="dark burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.DARKNESS] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={blight=true}, name="blight burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.BLIGHT] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={nature=true}, name="nature burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.NATURE] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={arcane=true}, name="arcane burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.ARCANE] = resolvers.randartmax(1, 30), }, },
}
newEntity{ theme={temporal=true}, name="temporal burst (crit)", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { burst_on_crit = {[DamageType.TEMPORAL] = resolvers.randartmax(1, 30), }, },
}
----------------------------------------------------------------
-- Melee damage conversion
----------------------------------------------------------------
newEntity{ theme={mind=true, mental=true}, name="mind conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.MIND] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={acid=true}, name="acid conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.ACID] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={lightning=true}, name="lightning conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.LIGHTNING] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={fire=true}, name="fire conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.FIRE] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={cold=true}, name="cold conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.COLD] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={light=true}, name="light conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.LIGHT] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={dark=true}, name="dark conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.DARKNESS] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={blight=true}, name="blight conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.BLIGHT] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={nature=true}, name="nature conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.NATURE] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={arcane=true}, name="arcane conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.ARCANE] = resolvers.randartmax(1, 50), }, },
}
newEntity{ theme={temporal=true}, name="temporal conversion", points = 1, rarity = 20, level_range = {1, 50},
	special_combat = { convert_damage = {[DamageType.TEMPORAL] = resolvers.randartmax(1, 50), }, },
}
----------------------------------------------------------------
-- Slaying
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="slay humanoid", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {humanoid=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay undead", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {undead=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay demon", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {demon=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay dragon", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {dragon=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay animal", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {animal=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay giant", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {giant=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay elemental", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {elemental=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay horror", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {horror=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay vermin", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {vermin=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay insect", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {insect=resolvers.randartmax(1, 25),},},
}
newEntity{ theme={physical=true}, name="slay spiderkin", points = 1, rarity = 22, level_range = {1, 50},
	special_combat = { inc_damage_type = {spiderkin=resolvers.randartmax(1, 25),},},
}