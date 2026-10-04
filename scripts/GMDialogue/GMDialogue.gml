/// Simple dialogue system with typewriter effect.
/// @param {real} _font Asset font.
/// @param {real} _write_speed Speed per gamespeed fps.
/// @param {real} _width Maximum width in pixels before adding newline character.
function GMDialogue(_font, _write_speed, _wrap = undefined) constructor {
	
	//Initialize variables.
	__queue_list = [];
	__asset_font = _font;
	__string_current = "";
	__string_draw = "";
	__string_length = 0;
	__string_position = 0;
	__string_wrap = _wrap;
	__write_speed = _write_speed * (1 / gamespeed_fps); //Write speed * framespeed.
	__write_increment = 0;
	
	/**
	* Add string to the end of the queue list.
	* @param {string} _string String.
	*/
	add = function(_string) {
		var _string_push = _string;
		//If not undefined then wrap string.
		if !is_undefined(__string_wrap) {
			draw_set_font(__asset_font);
			_string_push = __string_wrapped(_string, __string_wrap);	
		}
		//Add string to end of the array.
		array_push(__queue_list, _string_push);
	}
	
	/**
	* Send string from the start of the queue list to draw.
	*/
	next = function() {
		//Get the string from the start of the array and remove it from the array.
		__string_current = array_shift(__queue_list); //Returns undefined if empty.
		//Reset string position, and draw.
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
		
		draw_set_font(__asset_font);
		
		//Draw the string from string draw at set coordinates.
		draw_text(_x, _y, __string_draw);
	}
	
	/// @ignore
	__string_wrapped = function(_string, _width) {
		
		//Initialize nonchanging variables.
		static __char_space   = chr(32);
		static __char_newline = chr(13);
		
		//Initialize temporary variables.
		var _string_wrapped   = "";
		var _string_width     = 0;
		var _string_length   = string_length(_string);
		var _char_width       = 0;
		var _char_get         = "";
		
		//Get every char and it's width from the string.
		for (var i = 1; i <= _string_length; ++i) {
			_char_get   = string_char_at(_string, i);
			_char_width = string_width(_char_get);
			
			//Add char width to the _string_width variable.
			_string_width += _char_width;
			
			//If the value of the _string_width is greater or equal to the max width.
			//Search backwards for the first space char and insert newline char.
		    if _string_width >= _width {
				var _new_width     = 0;
				var _char_previous = "";
				for (var j = i; j > 0; --j) {
				    _char_previous = string_char_at(_string_wrapped, j);
					if _char_previous == __char_space {
						//Insert newline char after space char index.
						_string_wrapped = string_insert(__char_newline, _string_wrapped, j + 1);
						break;
					}
					//Add char width for each char found before space char.
					_new_width += string_width(_char_previous);
				}
				//Set the _string_width variable to _new_width.
				_string_width = _new_width;
			}
			//Add next char from string to the 
			_string_wrapped += _char_get;
			_char_width = string_width(_char_get);
		}
		//Return the wrapped string.
		return _string_wrapped;
	}

}