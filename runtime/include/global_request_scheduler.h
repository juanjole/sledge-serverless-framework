#pragma once

#include "sandbox_request.h"

/* Returns pointer back if successful, null otherwise */
typedef struct sandbox_request *(*global_request_scheduler_add_fn_t)(void *);
typedef int (*global_request_scheduler_remove_fn_t)(struct sandbox_request **);
typedef uint64_t (*global_request_scheduler_peek_fn_t)(void);

struct global_request_scheduler_config {
	global_request_scheduler_add_fn_t    add_fn;
	global_request_scheduler_remove_fn_t remove_fn;
	global_request_scheduler_peek_fn_t   peek_fn;
};


void global_request_scheduler_initialize(struct global_request_scheduler_config *config);

#define GLOBAL_REQUEST_SCHEDULER_REMOVE_OK     0
#define GLOBAL_REQUEST_SCHEDULER_REMOVE_EMPTY  -1
#define GLOBAL_REQUEST_SCHEDULER_REMOVE_NOLOCK -2

struct sandbox_request *global_request_scheduler_add(struct sandbox_request *);
int                     global_request_scheduler_remove(struct sandbox_request **);
uint64_t                global_request_scheduler_peek();
