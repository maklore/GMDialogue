/// Simple dialogue system with typewriter effect.
/// @param {Asset.GMFont} _font Asset font.
/// @param {real} _write_speed Speed per gamespeed fps.
/// @param {real} _width Maximum width in pixels before adding newline character.
function GMDialogue(_font, _write_speed, _wrap = 0) constructor {
	
	//Initialize variables.
	__asset_font        = _font;
	__queue_list        = [];
	__queue_index       = -1;
	__queue_reset       = false;
	__string_current    = "";
	__string_draw       = "";
	__string_length     = 0;
	__string_position   = 0;
	__string_wrap       = _wrap;
	__string_x          = 0;
	__write_speed       = _write_speed * (1 / game_get_speed(gamespeed_fps)); //Write speed * framespeed.
	__write_increment   = 0;
	__write_complete    = true;
	
	/**
	* Add string to the end of the queue list.
	* @param {string} _string String.
	*/
	add = function(_string) {
		
		var _string_push = _string;
		
		draw_set_font(__asset_font);
		
		//Wrap if greater than 0;
		if __string_wrap > 0 { _string_push = __string_wrapped(_string, __string_wrap);	}
		
		//Add string to end of the array.
		array_push(__queue_list, _string_push);
	}
	
	/**
	* Send string from the start of the queue list to draw.
	*/
	next = function() {
				
		//If triggered when writing, complete drawing the string.
		if !__write_complete {
			__string_position = __string_length;
			__string_draw = __string_current;
			__write_complete = true;
			exit;
		}
		
		//Increase the queue index
		__queue_index += __queue_index < array_length(__queue_list);
		
		//If the index equals the array length, reset and exit.
		if __queue_index == array_length(__queue_list) { 
			__queue_index = -1;
			exit;
		}
		
		//Get the string and backgrounds from the start of the array and remove it from the array.
		__string_current = __queue_list[__queue_index];
				
		//Reset variables before drawing next string.
		__queue_reset = false;
		__write_complete = false;
		__string_position = 0;
		__string_draw = "";
		__string_length = string_length(__string_current);
		__string_x = 0;
		
	}
	
	/**
	* Reset dialogue.
	*/
	reset = function() {
		
		//Exit if already reset.
		if __queue_reset { exit; }
		
		//Reset values.
		__queue_index = -1;
		__queue_reset = true;
		__write_complete = true;

	}
	
	/**
	* Draw string sent from queue list.
	* @param {real} _x x coordinate.
	* @param {real} _y y coordinate.
	*/
	draw = function(_x, _y) {
				
		//Exit draw if index less than 0.
		if __queue_index < 0 { exit; }
		
		//Draw setting.
		draw_set_font(__asset_font);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
				
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
			//When string position is the same as string length, set as complete.
			if __string_position == __string_length {
				__write_complete = true;
			}
		}
		
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
		var _string_length    = string_length(_string);
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