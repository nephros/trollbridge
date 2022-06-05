// +build go1.4

#include "textflag.h"

/*
TEXT ·Ref(SB),NOSPLIT,$4-4
	BL runtime·acquirem(SB)
	MOVW 4(R13), R0
	MOVW R0, ret+0(FP)
	MOVW R0, 4(R13)
	BL runtime·releasem(SB)
	RET
*/

TEXT ·Addrs(SB),NOSPLIT,$0-16
	MOVD	$runtime·main(SB), R0
	MOVD	R0, ret+0(FP)
	MOVD	$runtime·main_main(SB), R0
	MOVD	R0, ret+8(FP)
	RET
