#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "particles.h"
#include "script.h"
#include <math.h>
#include <SDL.h>
#include <SDL_ttf.h>

#define rng(x, y) (x + rand_div(1 + y - x))

static void getfield(lua_State *L, const char *key, int *min, int *max)
{
	lua_pushstring(L, key);
	lua_gettable(L, -2);

	lua_pushnumber(L, 1);
	lua_gettable(L, -2);
	*min = (int)lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushnumber(L, 2);
	lua_gettable(L, -2);
	*max = (int)lua_tonumber(L, -1);
	lua_pop(L, 1);

//	printf("%s :: %d %d\n", key, (int)*min, (int)*max);

	lua_pop(L, 1);
}

static int particles_new(lua_State *L)
{
	int nb = luaL_checknumber(L, 1);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 3);
	int t_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int p_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	particles_type *ps = (particles_type*)lua_newuserdata(L, sizeof(particles_type));
	auxiliar_setclass(L, "core{particles}", -1);

	ps->nb = nb;
	ps->texture = *t;
	ps->texture_ref = t_ref;

	ps->particles = calloc(nb, sizeof(particle_type));

//	printf("Making particle emitter with %d particles\n", ps->nb);

	// Grab all parameters
	lua_rawgeti(L, LUA_REGISTRYINDEX, p_ref);

	lua_pushstring(L, "base");
	lua_gettable(L, -2);
	ps->base = (float)lua_tonumber(L, -1);
	lua_pop(L, 1);

	getfield(L, "life", &(ps->life_min), &(ps->life_max));

	getfield(L, "angle", &(ps->angle_min), &(ps->angle_max));
	getfield(L, "anglev", &(ps->anglev_min), &(ps->anglev_max));
	getfield(L, "anglea", &(ps->anglea_min), &(ps->anglea_max));

	getfield(L, "size", &(ps->size_min), &(ps->size_max));
	getfield(L, "sizev", &(ps->sizev_min), &(ps->sizev_max));
	getfield(L, "sizea", &(ps->sizea_min), &(ps->sizea_max));

	getfield(L, "r", &(ps->r_min), &(ps->r_max));
	getfield(L, "rv", &(ps->rv_min), &(ps->rv_max));
	getfield(L, "ra", &(ps->ra_min), &(ps->ra_max));

	getfield(L, "g", &(ps->g_min), &(ps->g_max));
	getfield(L, "gv", &(ps->gv_min), &(ps->gv_max));
	getfield(L, "ga", &(ps->ga_min), &(ps->ga_max));

	getfield(L, "b", &(ps->b_min), &(ps->b_max));
	getfield(L, "bv", &(ps->bv_min), &(ps->bv_max));
	getfield(L, "ba", &(ps->ba_min), &(ps->ba_max));

	getfield(L, "a", &(ps->a_min), &(ps->a_max));
	getfield(L, "av", &(ps->av_min), &(ps->av_max));
	getfield(L, "aa", &(ps->aa_min), &(ps->aa_max));
	lua_pop(L, 1);

	luaL_unref(L, LUA_REGISTRYINDEX, p_ref);

	return 1;
}

static int particles_free(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);

	free(ps->particles);
	luaL_unref(L, LUA_REGISTRYINDEX, ps->texture_ref);

	lua_pushnumber(L, 1);
	return 1;
}

static int particles_emit(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	int nb = luaL_checknumber(L, 2);

	int i;
	for (i = 0; i < ps->nb; i++)
	{
		particle_type *p = &ps->particles[i];

		if (!p->life)
		{
			p->life = rng(ps->life_min, ps->life_max);
			p->size = rng(ps->size_min, ps->size_max);
			p->sizev = rng(ps->sizev_min, ps->sizev_max);
			p->sizea = rng(ps->sizea_min, ps->sizea_max);

			p->x = p->y = 0;

			float angle = rng(ps->angle_min, ps->angle_max) * M_PI / 180;
			float v = rng(ps->anglev_min, ps->anglev_max) / ps->base;
			float a = rng(ps->anglea_min, ps->anglea_max) / ps->base;
			p->xa = cos(angle) * a;
			p->ya = sin(angle) * a;
			p->xv = cos(angle) * v;
			p->yv = sin(angle) * v;
			p->r = rng(ps->r_min, ps->r_max) / 255.0f;
			p->g = rng(ps->g_min, ps->g_max) / 255.0f;
			p->b = rng(ps->b_min, ps->b_max) / 255.0f;
			p->a = rng(ps->a_min, ps->a_max) / 255.0f;

			p->rv = rng(ps->rv_min, ps->rv_max) / ps->base;
			p->gv = rng(ps->gv_min, ps->gv_max) / ps->base;
			p->bv = rng(ps->bv_min, ps->bv_max) / ps->base;
			p->av = rng(ps->av_min, ps->av_max) / ps->base;

			p->ra = rng(ps->ra_min, ps->ra_max) / ps->base;
			p->ga = rng(ps->ga_min, ps->ga_max) / ps->base;
			p->ba = rng(ps->ba_min, ps->ba_max) / ps->base;
			p->aa = rng(ps->aa_min, ps->aa_max) / ps->base;

			nb--;
			if (!nb) break;
		}
	}
	return 0;
}


static int particles_to_screen(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool show = lua_toboolean(L, 4);
	int i = 0;
	bool alive = FALSE;

	glBindTexture(GL_TEXTURE_2D, ps->texture);

	for (i = 0; i < ps->nb; i++)
	{
		particle_type *p = &ps->particles[i];

		if (p->life)
		{
			alive = TRUE;

			if (show)
			{
				glColor4f(p->r, p->g, p->b, p->a);
				glBegin(GL_QUADS);
				glTexCoord2f(0,0); glVertex3f(0 + x + p->x,	0 + y + p->y,		-97);
				glTexCoord2f(1,0); glVertex3f(p->size + x + p->x,	0 + y + p->y,		-97);
				glTexCoord2f(1,1); glVertex3f(p->size + x + p->x,	p->size + y + p->y,	-97);
				glTexCoord2f(0,1); glVertex3f(0 + x + p->x,	p->size + y + p->y,	-97);
				glEnd();
			}

			p->life--;

			p->x += p->xv;
			p->y += p->yv;
			p->r += p->rv;
			p->g += p->gv;
			p->b += p->bv;
			p->a += p->av;
			p->size += p->sizev;

			p->xv += p->xa;
			p->yv += p->ya;
			p->rv += p->ra;
			p->gv += p->ga;
			p->bv += p->ba;
			p->av += p->aa;
			p->sizev += p->sizea;
		}
	}

	// Restore normal display
	glColor4f(1, 1, 1, 1);

	lua_pushboolean(L, alive);
	return 1;
}

static const struct luaL_reg particleslib[] =
{
	{"newEmitter", particles_new},
	{NULL, NULL},
};

static const struct luaL_reg particles_reg[] =
{
	{"__gc", particles_free},
	{"close", particles_free},
	{"emit", particles_emit},
	{"toScreen", particles_to_screen},
	{NULL, NULL},
};

int luaopen_particles(lua_State *L)
{
	auxiliar_newclass(L, "core{particles}", particles_reg);
	luaL_openlib(L, "core.particles", particleslib, 0);
	return 1;
}
