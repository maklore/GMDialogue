if keyboard_check_released(vk_space) {
	dlg.next();
	if is_undefined(dlg.__string_current) {
		readd();	
	}
	
	dlg2.next();	
	if is_undefined(dlg2.__string_current) {
		readd2();	
	}
	

	
}