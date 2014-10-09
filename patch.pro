;Patching of missing height values using ALOS HV

Function patch, in_ht, in_hv, in_my_hv
	;in_ht is an array of height values in the window we are looking at
	;in_hv is the corresponding array of hv values to in_ht
	;in_my_hv is a scalar value of hv of the missing pixel we would like to fill

	COMMON setting, thresh   ;threshold value in a common block so we don't have to pass it each time

	if (in_my_hv lt thresh) then return, 0   ; return zero if pixel does not meet threshold value

	index = where(in_ht gt 0, count)

	if (count gt 0) then begin
		return, mean(in_ht[index]) * ((in_my_hv / mean(in_hv[index]) - 1)*0.5+1) ; scale using variance of hv on mean of height
	endif

	return, 0  ; if we get to here, no height values to help with interpolation, so return 0

End
