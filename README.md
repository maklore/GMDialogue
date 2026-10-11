<h1 align="center">GMDialogue</h1>
<h3 align="center">A small dialogue system.</h3>

### Basic setup
- Create a script in GameMaker
	- Copy everything from [GMDialogue.gml](https://github.com/maklore/GMDialogue/blob/main/scripts/GMDialogue/GMDialogue.gml)
	- Paste to script file

- Create an object
	- Add to Create event:
    ```gml
    dialogue = new GMDialogue(ASSET_FONT, WRITE_SPEED, WRAP_WIDTH);
    dialogue.add("This is a string.");
    ```
  
	- Add to Step event:
    ```gml
    if (SOME ENTER THE DIALOGUE TRIGGER) {
    	dialogue.next();	
    }

    if (SOME LEAVES THE DIALOGUE TRIGGER) {
		dialogue.reset();
    }
    ```
	- Add to Draw event:
    ```gml
    dialogue.draw(X, Y);
    ```
 	- Add object to room
  - Enjoy!
