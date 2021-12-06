#pragma once

#include <assert.h>
#include <stddef.h>
#include <stdint.h>

#include "arch/context.h"
#include "current_sandbox.h"
#include "ps_list.h"
#include "sandbox_request.h"
#include "sandbox_state_history.h"
#include "sandbox_types.h"

/**
 * Transitions a sandbox to the SANDBOX_INITIALIZED state.
 * The sandbox was already zeroed out during allocation
 * @param sandbox an uninitialized sandbox
 * @param sandbox_request the request we are initializing the sandbox from
 * @param allocation_timestamp timestamp of allocation
 */
static inline void
sandbox_set_as_initialized(struct sandbox *sandbox, struct sandbox_request *sandbox_request,
                           uint64_t allocation_timestamp)
{
	assert(sandbox);
	assert(sandbox->state == SANDBOX_ALLOCATED);
	assert(sandbox_request != NULL);
	assert(allocation_timestamp > 0);
	sandbox->state = SANDBOX_INITIALIZED;
	uint64_t now   = __getcycles();

	/* Copy State from Sandbox Request */
	sandbox->id                           = sandbox_request->id;
	sandbox->absolute_deadline            = sandbox_request->absolute_deadline;
	sandbox->admissions_estimate          = sandbox_request->admissions_estimate;
	sandbox->client_socket_descriptor     = sandbox_request->socket_descriptor;
	sandbox->timestamp_of.request_arrival = sandbox_request->request_arrival_timestamp;
	/* Copy the socket descriptor and address of the client invocation */
	memcpy(&sandbox->client_address, &sandbox_request->socket_address, sizeof(struct sockaddr));

	/* Initialize Parsec control structures */
	ps_list_init_d(sandbox);

	/* Allocations require the module to be set */
	sandbox->module = sandbox_request->module;
	module_acquire(sandbox->module);

	/* State Change Bookkeeping */
	sandbox->duration_of_state[SANDBOX_ALLOCATED] = now - allocation_timestamp;
	sandbox->timestamp_of.allocation              = allocation_timestamp;
	sandbox->timestamp_of.last_state_change       = allocation_timestamp;
	sandbox_state_history_append(sandbox, SANDBOX_INITIALIZED);
	runtime_sandbox_total_increment(SANDBOX_INITIALIZED);

#ifdef LOG_STATE_CHANGES
	sandbox->state_history_count                           = 0;
	sandbox->state_history[sandbox->state_history_count++] = SANDBOX_ALLOCATED;
	memset(&sandbox->state_history, 0, SANDBOX_STATE_HISTORY_CAPACITY * sizeof(sandbox_state_t));
#endif
}


static inline void
sandbox_init(struct sandbox *sandbox, struct sandbox_request *sandbox_request, uint64_t allocation_timestamp)
{
	sandbox_set_as_initialized(sandbox, sandbox_request, allocation_timestamp);
}
