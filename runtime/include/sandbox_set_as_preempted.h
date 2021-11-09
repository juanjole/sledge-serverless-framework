#pragma once

#include <assert.h>
#include <stdint.h>

#include "arch/getcycles.h"
#include "local_runqueue.h"
#include "panic.h"
#include "sandbox_types.h"

/**
 * Transitions a sandbox to the SANDBOX_PREEMPTED state.
 *
 * This occurs in the following scenarios:
 * - A sandbox in the SANDBOX_INITIALIZED state completes initialization and is ready to be run
 * - A sandbox in the SANDBOX_BLOCKED state completes what was blocking it and is ready to be run
 *
 * @param sandbox
 * @param last_state the state the sandbox is transitioning from. This is expressed as a constant to
 * enable the compiler to perform constant propagation optimizations.
 */
static inline void
sandbox_set_as_preempted(struct sandbox *sandbox, sandbox_state_t last_state)
{
	assert(sandbox);

	/* Preemption occurs indirectly via the SANDBOX_RUNNING_KERNEL state, so preemptable is set
	 * to false during the process of preemption.
	 */
	assert(sandbox->ctxt.preemptable == false);

	uint64_t now                    = __getcycles();
	uint64_t duration_of_last_state = now - sandbox->timestamp_of.last_state_change;

	sandbox->state = SANDBOX_SET_AS_PREEMPTED;
	sandbox_state_history_append(sandbox, SANDBOX_SET_AS_PREEMPTED);

	switch (last_state) {
	case SANDBOX_RUNNING_KERNEL: {
		sandbox->duration_of_state.preempted += duration_of_last_state;
		current_sandbox_set(NULL);
		break;
	}
	default: {
		panic("Sandbox %lu | Illegal transition from %s to Preempted\n", sandbox->id,
		      sandbox_state_stringify(last_state));
	}
	}

	sandbox->timestamp_of.last_state_change = now;
	sandbox->state                          = SANDBOX_PREEMPTED;

	/* State Change Bookkeeping */
	sandbox_state_history_append(sandbox, SANDBOX_PREEMPTED);
	runtime_sandbox_total_increment(SANDBOX_PREEMPTED);
	runtime_sandbox_total_decrement(last_state);
}
