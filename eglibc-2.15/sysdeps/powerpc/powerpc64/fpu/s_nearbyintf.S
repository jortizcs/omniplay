/* Round to int floating-point values.  PowerPC64 version.
   Copyright (C) 2011 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Adhemerval Zanella <azanella@br.ibm.com>, 2011

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/* This has been coded in assembler because GCC makes such a mess of it
   when it's coded in C.  */

#include <sysdep.h>


/* float [fp1] nearbyintf(float [fp1]) */

	.section	".toc","aw"
.LC0:	/* 2**23 */
	.tc FD_4b000000_0[TC],0x4b00000000000000
	.section	".text"

EALIGN (__nearbyintf, 4, 0)
	CALL_MCOUNT 0
	fabs	fp0,fp1
	lfs	fp13,.LC0@toc(2)
	fcmpu	cr7,fp0,fp13	/* if (fabs(x) > TWO52)  */
	bgelr	cr7
	fsubs	fp12,fp13,fp13	/* generate 0.0 */
	fcmpu	cr7,fp1,fp12	/* if (x > 0.0)  */
	ble	cr7, L(lessthanzero)
	mtfsb0	4*cr7+lt	/* Disable FE_INEXACT exception */
	fadds	fp1,fp1,fp13	/* x += TWO23 */
	fsubs	fp1,fp1,fp13	/* x -= TWO23 */
	fabs	fp1,fp1		/* if (x == 0.0) */
	mtfsb0	4*cr1+eq	/* Clear pending FE_INEXACT exception */
	blr			/* x = 0.0; */
L(lessthanzero):
	bgelr	cr7		/* if (x < 0.0) */
	mtfsb0	4*cr7+lt	/* Disable FE_INEXACT exception */
	fsubs	fp1,fp1,fp13	/* x -= TWO23 */
	fadds	fp1,fp1,fp13	/* x += TWO23 */
	fnabs	fp1,fp1		/* if (x == 0.0) */
	mtfsb0	4*cr1+eq	/* Clear pending FE_INEXACT exception */
	blr			/* x = -0.0; */
END (__nearbyintf)

weak_alias (__nearbyintf, nearbyintf)
