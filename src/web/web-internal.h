/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

#ifndef __TE4WEB_INTERNAL_H__
#define __TE4WEB_INTERNAL_H__

#include <cef_app.h>
#include <cef_client.h>
#include <cef_display_handler.h>
#include <cef_render_handler.h>
#include <cef_request_handler.h>
#include <cef_render_process_handler.h>
#include <cef_v8.h>

extern void te4_web_init_utils();

extern void push_order(WebEvent *event);
extern WebEvent *pop_order();
extern void push_event(WebEvent *event);
extern WebEvent *pop_event();

#endif