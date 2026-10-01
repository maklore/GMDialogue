/// Simple dialogue system with typewriter effect.
/// @param {real} _write_speed Speed per gamespeed fps.
function GMDialogue(_write_speed) constructor {
	
	//Initialize variables.
	__queue_list = [];
	__string_current = "";
	__string_draw = "";
	__string_length = 0;
	__string_position = 0;
	__write_speed = _write_speed * (1 / gamespeed_fps); //Write speed * framespeed.
	__write_increment = 0;
	
	/**
	* Add string to the end of the queue list.
	* @param {string} _string String.
	*/
	add = function(_string) {
		//Add string to end of the array.
		array_push(__queue_list, _string);
	}
	
	/**
	* Send string from the start of the queue list to draw.
	*/
	next = function() {
		//Get the string from the start of the array and remove it from the array.
		__string_current = array_shift(__queue_list); //Returns undefined if empty.
		//Reset string draw, and position.
		__string_position = 0;
		__string_draw = "";
		//If the array is empty it will return undefined, then don't change string length.
		if !is_undefined(__string_current) {
			__string_length = string_length(__string_current)
		}
	}
	
	/**
	* Draw string sent from queue list.
	* @param {real} _x x coordinate.
	* @param {real} _y y coordinate.
	*/
	draw = function(_x, _y) {
		//Exit the method if current string is undefined.
		if is_undefined(__string_current) { exit; }
		//If the string position is less than length increase write increment by set speed.
		if __string_position < __string_length {
			__write_increment += __write_speed;
			//If the write incement is greater than one, increase position and
			//add next character from string current to string draw.
			//and reset write increment.
			if __write_increment >= 1 {
				__string_position++;
				__string_draw += string_char_at(__string_current, __string_position);
				__write_increment = 0;
			}
		}
		//Draw the string from string draw at set coordinates.
		draw_text(_x, _y, __string_draw);
	}

}