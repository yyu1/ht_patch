;Procedure for applying patching

;win_size is number of pixels in each direction from the center pixel: so win_size = 1 is 3x3

Pro apply_patch, in_ht_file, in_hv_file, out_ht_file, xdim, ydim, win_size

	COMMON setting, thresh   ;common block for values of settings

	thresh = 0.051  ; Use 0.051 for HV threshold	

	in_ht_image = fltarr(xdim,win_size*2+1)
	in_hv_image = fltarr(xdim,win_size*2+1)

	openr, in_ht_lun, in_ht_file, /get_lun
	openr, in_hv_lun, in_hv_file, /get_lun
	openw, out_lun, out_ht_file, /get_lun

	out_line = fltarr(xdim)
	hv_line = fltarr(xdim)

	ht_win = fltarr(win_size*2+1,win_size*2+1)
	hv_win = fltarr(win_size*2+1,win_size*2+1)

	;copy first win_size lines, we are not going to patch this region
	for j=0ULL, win_size-1 do begin
		readu, in_ht_lun, out_line
		writeu, out_lun, out_line
	endfor

	print, 'Patching...'

	for j=win_size,ydim-win_size-1 do begin
		if (j mod 10000 eq 0) then print, j
		;set file pointer
		point_lun, in_ht_lun, (j-win_size)*xdim*4ULL
		point_lun, in_hv_lun, (j-win_size)*xdim*4ULL

		readu, in_ht_lun, in_ht_image
		readu, in_hv_lun, in_hv_image

		out_line[*] = in_ht_image[*,win_size]
		hv_line[*] = in_hv_image[*,win_size]
		
		index = where((out_line eq 0) and (hv_line ge thresh), count)

		if(count gt 0) then begin
			for i=0, count-1 do begin
				i_ind = index[i]
				ht_win[*] = in_ht_image[i_ind-win_size:i_ind+win_size,*]
				hv_win[*] = in_hv_image[i_ind-win_size:i_ind+win_size,*]

				out_line[i_ind] = patch(ht_win,hv_win,hv_win[win_size,win_size])
			endfor
		endif

		writeu, out_lun, out_line
	endfor
		
	;copy the last win_size lines
	point_lun, in_ht_lun, (ydim-win_size)*xdim*4ULL
	for j=0ULL, win_size-1 do begin
		readu, in_ht_lun, out_line
		writeu, out_lun, out_line
	endfor

	free_lun, in_ht_lun, in_hv_lun, out_lun

End
