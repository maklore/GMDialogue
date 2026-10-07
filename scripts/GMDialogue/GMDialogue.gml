/// Simple dialogue system with typewriter effect.
/// @param {Asset.GMFont} _font Asset font.
/// @param {real} _write_speed Speed per gamespeed fps.
/// @param {real} _width Maximum width in pixels before adding newline character.
function GMDialogue(_font, _write_speed, _wrap = 0) constructor {
	
	//Initialize variables.
	__queue_list        = [];
	__dimensions_list   = [];
	__asset_font        = _font;
	__string_current    = undefined;
	__string_draw       = "";
	__string_length     = 0;
	__string_position   = 0;
	__string_wrap       = _wrap;
	__dimension_current = undefined;
	__dimension_padding = GMDIALOGUE_BACKGROUND_PADDING;
	__dimension_halign  = 0;
	__dimension_x       = undefined;
	__dimension_y       = undefined;
	__dimension_width   = 0;
	__dimension_height  = 0;
	__dimension_speed   = 0;
	__write_speed       = _write_speed * (game_get_speed(gamespeed_fps) * 0.5 / game_get_speed(gamespeed_fps)); //Write speed * framespeed.
	__write_increment   = 0;
	__write_complete    = true;
	
	/**
	* Add string to the end of the queue list.
	* @param {string} _string String.
	*/
	add = function(_string) {
		var _string_push = _string;
		//If not undefined then wrap string.
		if __string_wrap > 0 {
			draw_set_font(__asset_font);
			_string_push = __string_wrapped(_string, __string_wrap);	
		}
		//Add string to end of the array.
		array_push(__queue_list, _string_push);
		array_push(__dimensions_list, {
			width  : string_width(_string_push),
			height : string_height(_string_push)
		});
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
		
		//Get the string and dimensions from the start of the array and remove it from the array.
		__string_current = array_shift(__queue_list);         //Returns undefined if empty.
		__dimension_current = array_shift(__dimensions_list); //Returns undefined if empty.
		
		//Exit the method if current string is undefined.
		if is_undefined(__string_current) { exit; }
		
		//Reset string position, and draw.
		__string_position = 0;
		__string_draw = "";
		
		//If the array is empty, don't change string length.
		if !is_undefined(__string_current) {
			__string_length = string_length(__string_current)
		}
		
		__write_complete = false;
		__dimension_speed = 0;
	}
	
	/**
	* Draw string sent from queue list.
	* @param {real} _x x coordinate.
	* @param {real} _y y coordinate.
	*/
	draw = function(_x, _y) {
				
		//Exit the method if current string is undefined.
		if is_undefined(__string_current) { exit; }
		
		//Initialize position
		__dimension_x ??= _x;
		__dimension_y ??= _y;
		
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
		
		//Draw setting.
		draw_set_font(__asset_font);
		draw_set_halign(GMDIALOGUE_HALIGN);
		draw_set_valign(fa_top);
		
		if GMDIALOGUE_HALIGN == fa_center {
			__dimension_halign = string_width(__string_current) * 0.5;	
		}
		
		//Draw border behind the string.
		if is_handle(GMDIALOGUE_BACKGROUND_SPRITE) and !is_undefined(__dimension_current) {
					
			if __dimension_speed < 1 { __dimension_speed += GMDIALOGUE_BACKGROUND_ADJUSTMENT_SPEED; }
			
			if __dimension_current.width > GMDIALOGUE_BACKGROUND_WIDTH_MIN {
				__dimension_x      = lerp(__dimension_x, _x - __dimension_halign - __dimension_padding, __dimension_speed);
				__dimension_width  = lerp(__dimension_width, __dimension_padding  * 2 + __dimension_current.width, __dimension_speed);
			} else {
				__dimension_x      = _x - __dimension_halign - __dimension_padding;
				__dimension_width  = lerp(__dimension_width, __dimension_padding * 2 + GMDIALOGUE_BACKGROUND_WIDTH_MIN, __dimension_speed);
			}
			
			if __dimension_current.height > GMDIALOGUE_BACKGROUND_HEIGHT_MIN {
				__dimension_y      = lerp(__dimension_y, _y - __dimension_padding, __dimension_speed);
				__dimension_height = lerp(__dimension_height, __dimension_padding * 2 + __dimension_current.height, __dimension_speed);
			} else {
				__dimension_y      = _y - __dimension_padding;
				__dimension_height = lerp(__dimension_height, __dimension_padding * 2 + GMDIALOGUE_BACKGROUND_HEIGHT_MIN, __dimension_speed);
			} 
			
			draw_sprite_stretched(GMDIALOGUE_BACKGROUND_SPRITE, 0, __dimension_x, __dimension_y, __dimension_width, __dimension_height);
			
		}
		
		//Draw the string from string draw at set coordinates.
		draw_text(_x - (GMDIALOGUE_HALIGN != fa_center ? __dimension_halign : 0), _y, __string_draw);
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