/* Notes:
 *
 */


// log console message to screen
void render_console() {
  background(20, 20, 200);
  fill(255);
  image(FINCH, width - 100, 0, 100, 100);
  text("Is your finch healthy?\nEnter age to find out.", width - 310, 40);
  text(CONSOLE, 20, height - (30 * split(CONSOLE, '\n').length));
}

 
// render life board at top of arena
void render_life() {
  noStroke();
  fill(255);
  
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE.get_cell(i, j)) {
        pushMatrix();
          translate(H_A_S - (i * LIFE_CELL_SIZE), 
                    H_A_S, 
                    H_A_S - (j * LIFE_CELL_SIZE));
          box(LIFE_CELL_SIZE, LIFE_CELL_THICK, LIFE_CELL_SIZE);
        popMatrix();
      }
}


// render color field at bottom of arena
void render_field() {
  noStroke();
  
  for (int i = 0; i < FIELD_WIDTH; i++)
    for (int j = 0; j < FIELD_WIDTH; j++) {
      fill(FIELD.at_ij(i, j));
      pushMatrix();
        translate(H_A_S - (i * FIELD_CELL_SIZE), 
                  -H_A_S, 
                  H_A_S - (j * FIELD_CELL_SIZE));
        box(FIELD_CELL_SIZE, FIELD_CELL_THICK, FIELD_CELL_SIZE);
      popMatrix();
    }
}


// render sound wave to sides of arena
void render_soundwave() {
  float x, y, z;
  
  stroke(255, 0, 255);
  noFill();

  beginShape();
  for (int i = 0; i < SOUND.get_size(); i++) {
    y = map(SOUND.get_ith(i), 0, 1023, -H_A_S, H_A_S);
    
    if (i > 3 * SOUND.get_size() / 4) {
      x = (i * 4 * ARENA_SIZE / SOUND.get_size()) - (3 * ARENA_SIZE) - H_A_S;
      z = H_A_S;
    } else if (i > SOUND.get_size() / 2) {
      x = -H_A_S;
      z = (i * 4 * ARENA_SIZE / SOUND.get_size()) - (2 * ARENA_SIZE) - H_A_S;
    } else if (i > SOUND.get_size() / 4) {
      x = H_A_S + ARENA_SIZE - (i * 4 * ARENA_SIZE / SOUND.get_size());
      z = -H_A_S;
    } else {
      x = H_A_S;
      z = H_A_S - (i * 4 * ARENA_SIZE / SOUND.get_size());
    }
    
    vertex(x, y, z);
  }
  endShape();
}


