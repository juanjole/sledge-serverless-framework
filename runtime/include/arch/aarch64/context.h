#ifndef ARCH_AARCH64_CONTEXT_H
#define ARCH_AARCH64_CONTEXT_H

#include <unistd.h>
#include <ucontext.h>

#define ARCH_NREGS 31

/**
 * ARM64 code. Currently Unimplemented
 **/

typedef uint64_t reg_t;

struct arch_context {
	reg_t      regs[ARCH_NREGS];
	mcontext_t mctx;
};

typedef struct arch_context arch_context_t;

extern void __attribute__((noreturn)) worker_thread_sandbox_switch_preempt(void);
extern __thread arch_context_t worker_thread_base_context;

static inline void
arch_context_init(arch_context_t *actx, reg_t ip, reg_t sp)
{
	memset(&actx->mctx, 0, sizeof(mcontext_t));
	memset((void *)actx->regs, 0, sizeof(reg_t) * ARCH_NREGS);
}

static inline int
arch_context_switch(arch_context_t *ca, arch_context_t *na)
{
	return 0;
}

#endif /* ARCH_AARCH64_CONTEXT_H */
