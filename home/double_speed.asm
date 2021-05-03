; The CGB hardware introduces Double Speed Mode.
; While active, the clock speed is doubled.

; The hardware can switch between normal speed
; and double speed at any time, but LCD output
; collapses during the switch.

DoubleSpeed::
	farcall DoubleSpeed_far
	ret

NormalSpeed::
	farcall NormalSpeed_far
    ret

SwitchSpeed::
	farcall SwitchSpeed_far
	ret
