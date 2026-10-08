/* FONT ALIGNMENT HORIZONTALLY */
#macro GMDIALOGUE_HALIGN                      fa_center

/* SPRITE RENDERED BEHIND TEXT, SUGGEST USING NINE-SLICE */
#macro GMDIALOGUE_BACKGROUND_SPRITE           sprGMDialogueBackground //Change to your sprite asset.

/* DISTANCE FROM TEXT TO EDGE OF DRAWN SPRITE */
#macro GMDIALOGUE_BACKGROUND_PADDING          10

/* MINIMUM WIDTH OF SPRITE TO DRAW */
#macro GMDIALOGUE_BACKGROUND_WIDTH_MIN        80

/* MINIMUM HEIGHT OF SPRITE TO DRAW */
#macro GMDIALOGUE_BACKGROUND_HEIGHT_MIN       32

/* SPEED PER FRAME SHOULD ADJUST TO FIT TEXT*/
#macro GMDIALOGUE_BACKGROUND_ADJUSTMENT_SPEED 1/60


/// Simple dialogue system with typewriter effect.
/// @param {Asset.GMFont} _font Asset font.
/// @param {real} _write_speed Speed per gamespeed fps.
/// @param {real} _width Maximum width in pixels before adding newline character.
function GMDialogue(_font, _write_speed, _wrap = 0) constructor {
	
	//Initialize variables.
	__queue_list        = [];
	__asset_font        = _font;
	__string_current    = undefined;
	__string_draw       = "";
	__string_length     = 0;
	__string_position   = 0;
	__string_wrap       = _wrap;
	__string_x          = 0;
	__background_list   = [];
	__background_current = undefined;
	__background_padding = GMDIALOGUE_BACKGROUND_PADDING;
	__background_halign  = undefined;
	__background_x       = undefined;
	__background_y       = undefined;
	__background_width   = undefined;
	__background_height  = undefined;
	__background_speed   = 0;
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
		//If not undefined then wrap string.
		if __string_wrap > 0 {
			_string_push = __string_wrapped(_string, __string_wrap);	
		}
		//Add string to end of the array.
		array_push(__queue_list, _string_push);
		array_push(__background_list, {
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
		
		//Get the string and backgrounds from the start of the array and remove it from the array.
		__string_current = array_shift(__queue_list);          //Returns undefined if empty.
		__background_current = array_shift(__background_list); //Returns undefined if empty.
		
		//Exit the method and set background data as undefined if current string is undefined.
		if is_undefined(__string_current) { 
			__background_x = undefined;
			__background_y = undefined;
			__background_width  = undefined;
			__background_height = undefined;
			exit; 
		}
		
		//Reset string position, and draw.
		__string_position = 0;
		__string_draw = "";
		
		//If the string is undefined, don't change string length. Reset background pos
		if !is_undefined(__string_current) {
			__string_length = string_length(__string_current)
		}
		
		//Reset variables before drawing next string.
		__write_complete = false;
		__background_speed = 0;
		__background_halign = undefined;
		__string_x = 0;
	}
	
	/**
	* Draw string sent from queue list.
	* @param {real} _x x coordinate.
	* @param {real} _y y coordinate.
	*/
	draw = function(_x, _y) {
				
		//Exit the method if current string is undefined.
		if is_undefined(__string_current) { exit; }
		
		//Draw setting.
		draw_set_font(__asset_font);
		draw_set_halign(GMDIALOGUE_HALIGN);
		draw_set_valign(fa_top);
		
		//Initialize position, width, and height.
		__background_x      ??= _x;
		__background_y      ??= _y;
		__background_width  ??= GMDIALOGUE_HALIGN == fa_center ? 0 : GMDIALOGUE_BACKGROUND_WIDTH_MIN;
		__background_height ??= GMDIALOGUE_BACKGROUND_HEIGHT_MIN;
		__background_halign ??= GMDIALOGUE_HALIGN == fa_center ? string_width(__string_current) * 0.5 : __background_current.width * 0.5;
		
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
		

		
		//Draw background sprite behind the string.
		if is_handle(GMDIALOGUE_BACKGROUND_SPRITE) and !is_undefined(__background_current) {
			
			var _background_padtwice = __background_padding * 2;
			
			if __background_speed < 1 { 
				__background_speed += GMDIALOGUE_BACKGROUND_ADJUSTMENT_SPEED; 
			}
			
			if __background_current.width > GMDIALOGUE_BACKGROUND_WIDTH_MIN {
				if GMDIALOGUE_HALIGN == fa_center {
					__background_x = lerp(__background_x, _x - __background_halign - __background_padding, __background_speed)
					__string_x = 0;
				} else {
					__background_x = _x - __background_halign - __background_padding;
					__string_x = __background_current.width * 0.5;
				}
				__background_width = lerp(__background_width, _background_padtwice + __background_current.width, __background_speed);
				
			} else {
				__background_x = _x - __background_halign - __background_padding;
				__background_width = lerp(__background_width, _background_padtwice + GMDIALOGUE_BACKGROUND_WIDTH_MIN, __background_speed);
				__string_x = GMDIALOGUE_BACKGROUND_WIDTH_MIN * 0.5;
			}

			if __background_current.height > GMDIALOGUE_BACKGROUND_HEIGHT_MIN {
				if GMDIALOGUE_HALIGN == fa_center {
					__background_y      = lerp(__background_y, _y - __background_padding, __background_speed);
					__background_height = lerp(__background_height, _background_padtwice + __background_current.height, __background_speed);
				} else {
					__background_y      = _y - __background_padding;
					__background_height = _background_padtwice + __background_current.height;
				}
				
			} else {
				__background_y = _y - __background_padding;
				if GMDIALOGUE_HALIGN == fa_center or __background_height > GMDIALOGUE_BACKGROUND_HEIGHT_MIN {
					__background_height = lerp(__background_height, _background_padtwice + GMDIALOGUE_BACKGROUND_HEIGHT_MIN, __background_speed);
				} else {
					__background_height = _background_padtwice + GMDIALOGUE_BACKGROUND_HEIGHT_MIN;
				}
			}
			
			draw_sprite_stretched(GMDIALOGUE_BACKGROUND_SPRITE, 0, __background_x, __background_y, __background_width, __background_height);
						
		}
		
		//Draw the string from string draw at set coordinates.
		draw_text(_x - __string_x, _y, __string_draw);
		//draw_circle(_x, _y, 100, true) //debug
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