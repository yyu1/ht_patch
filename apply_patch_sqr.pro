;Procedure for applying patching

;win_size is number of pixels in each direction from the center pixel: so win_size = 1 is 3x3

;This version needs to square the HV input values first to get correct sigma0 value

Pro apply_patch_sqr, in_ht_file, in_hv_file, out_ht_file, xdim, ydim, win_size

	COMMON setting, thresh   ;common block for values of settings

	thresh = 0.04  ; Use 0.04 for HV threshold	

	max_ht = 60

	in_ht_image = fltarr(xdim,win_size*2+1)
	in_hv_image = fltarr(xdim,win_size*2+1)

	openr, in_ht_lun, in_ht_file, /get_lun
	openr, in_hv_lun, in_hv_file, /get_lun
	openw, out_lun, out_ht_file, /get_lun

	out_line = fltarr(xdim)
	hv_line = fltarr(xdim)

	ht_win = fltarr(win_size*2+1,win_size*2+1)
	hv_win = fltarr(win_size*2+1,win_size*2+1)

	print, 'Patching...'
	;copy first win_size lines, we patch but the pixel may not be the center of window
	readu, in_ht_lun, in_ht_image
	readu, in_hv_lun, in_hv_image
	in_hv_image = in_hv_image * in_hv_image

	for j=0ULL, win_size-1 do begin
		out_line[*] = in_ht_image[*,j]
		hv_line[*] = in_hv_image[*,j]
		
		index = where((out_line eq 0) and (hv_line ge thresh), count)

		if(count gt 0) then begin
			for i=0, count-1 do begin
				i_ind = index[i]
				i_ind_min = ((i_ind-win_size > 0) < (xdim-win_size*2-1))
				i_ind_max = ((i_ind+win_size > win_size*2) < (xdim-1))
				ht_win[*] = in_ht_image[i_ind_min:i_ind_max,*]
				hv_win[*] = in_hv_image[i_ind_min:i_ind_max,*]

				out_line[i_ind] = patch(ht_win,hv_win,hv_win[win_size,win_size])
			endfor
		endif
		writeu, out_lun, out_line < max_ht
	endfor

	for j=ulong(win_size),ydim-win_size-1 do begin
		if (j mod 10000 eq 0) then print, j
		;set file pointer
		point_lun, in_ht_lun, (j-win_size)*xdim*4ULL
		point_lun, in_hv_lun, (j-win_size)*xdim*4ULL

		readu, in_ht_lun, in_ht_image
		readu, in_hv_lun, in_hv_image
		in_hv_image = in_hv_image * in_hv_image

		out_line[*] = in_ht_image[*,win_size]
		hv_line[*] = in_hv_image[*,win_size]
		
		index = where((out_line eq 0) and (hv_line ge thresh), count)

		if(count gt 0) then begin
			for i=0, count-1 do begin
				i_ind = index[i]
				i_ind_min = ((i_ind-win_size > 0) < (xdim-win_size*2-1))
				i_ind_max = ((i_ind+win_size > win_size*2) < (xdim-1))
				ht_win[*] = in_ht_image[i_ind_min:i_ind_max,*]
				hv_win[*] = in_hv_image[i_ind_min:i_ind_max,*]

				out_line[i_ind] = patch(ht_win,hv_win,hv_win[win_size,win_size])
			endfor
		endif

		writeu, out_lun, out_line < max_ht
	endfor
		
	;patch the last win_size lines, since we read the block in the last step of previous loop, we don't need to read input anymore
	for j=0ULL, win_size-1 do begin
		out_line[*] = in_ht_image[*,win_size+j+1]
		hv_line[*] = in_hv_image[*,win_size+j+1]

		index = where((out_line eq 0) and (hv_line ge thresh), count)

		if(count gt 0) then begin
			for i=0, count-1 do begin
				i_ind = index[i]
				i_ind_min = ((i_ind-win_size > 0) < (xdim-win_size*2-1))
				i_ind_max = ((i_ind+win_size > win_size*2) < (xdim-1))
				ht_win[*] = in_ht_image[i_ind_min:i_ind_max,*]
				hv_win[*] = in_hv_image[i_ind_min:i_ind_max,*]

				out_line[i_ind] = patch(ht_win,hv_win,hv_win[win_size,win_size])
			endfor
		endif

		writeu, out_lun, out_line < max_ht

	endfor

	free_lun, in_ht_lun, in_hv_lun, out_lun

End
