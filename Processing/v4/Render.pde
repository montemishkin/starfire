/* Notes:
 *   make the boundaries run the game of life!!!
 *   make the derivative of the soundwave determine the speed of life
 *
 */

 
// render life board to arena walls
void render_life() {
  noStroke();
  
  fill(255);
  
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE.get_cell(i, j)) {
        pushMatrix();
          translate(H_A_S - (i * LIFE_CELL_SIZE), -H_A_S - 100, H_A_S - (j * LIFE_CELL_SIZE));
          box(LIFE_CELL_SIZE, LIFE_CELL_THICK, LIFE_CELL_SIZE);
        popMatrix();
        pushMatrix();
          translate(H_A_S - (i * LIFE_CELL_SIZE), H_A_S + 100, H_A_S - (j * LIFE_CELL_SIZE));
          box(LIFE_CELL_SIZE, LIFE_CELL_THICK, LIFE_CELL_SIZE);
        popMatrix();
      }
  
//  // +z wall
//  for (int i = 0; i < LIFE_WIDTH; i++)
//    for (int j = 0; j < LIFE_WIDTH; j++)
//      if (LIFE.get_cell(i, j)) {
//        pushMatrix();
//          translate((j * LIFE_CELL_SIZE) - H_A_S, H_A_S - (i * LIFE_CELL_SIZE), H_A_S);
//          box(LIFE_CELL_SIZE, LIFE_CELL_SIZE, LIFE_CELL_THICK);
//        popMatrix();
//      }
//  
//  // +x wall
//  for (int i = 0; i < LIFE_WIDTH; i++)
//    for (int j = 0; j < LIFE_WIDTH; j++)
//      if (LIFE.get_cell(i, j + LIFE_WIDTH)) {
//        pushMatrix();
//          translate(H_A_S, H_A_S - (i * LIFE_CELL_SIZE), H_A_S - (j * LIFE_CELL_SIZE));
//          box(LIFE_CELL_THICK, LIFE_CELL_SIZE, LIFE_CELL_SIZE);
//        popMatrix();
//      }
//  
//  // -z wall
//  for (int i = 0; i < LIFE_WIDTH; i++)
//    for (int j = 0; j < LIFE_WIDTH; j++)
//      if (LIFE.get_cell(i, j + (2 *LIFE_WIDTH))) {
//        pushMatrix();
//          translate(H_A_S - (j * LIFE_CELL_SIZE), H_A_S - (i * LIFE_CELL_SIZE), -H_A_S);
//          box(LIFE_CELL_SIZE, LIFE_CELL_SIZE, LIFE_CELL_THICK);
//        popMatrix();
//      }
//  
//  // -x wall
//  for (int i = 0; i < LIFE_WIDTH; i++)
//    for (int j = 0; j < LIFE_WIDTH; j++)
//      if (LIFE.get_cell(i, j + (3 * LIFE_WIDTH))) {
//        pushMatrix();
//          translate(-H_A_S, H_A_S - (i * LIFE_CELL_SIZE), (j * LIFE_CELL_SIZE) - H_A_S);
//          box(LIFE_CELL_THICK, LIFE_CELL_SIZE, LIFE_CELL_SIZE);
//        popMatrix();
//      }
}


// renders the stars in the background
void render_stars() {
  noStroke();
  
  PVector r;
  
  fill(255);
  for (int i = 0; i < NUM_STARS; i++) {
    r = STAR_POSITIONS[i];
    
    pushMatrix();
      translate(r.x, r.y, r.z);
      box(20);
    popMatrix();
  }
}


// render the floor
void render_field() {
  noStroke();
  
  for (int i = 0; i < FIELD_WIDTH; i++)
    for (int j = 0; j < FIELD_WIDTH; j++) {
      fill(FIELD.at_ij(i, j));
      pushMatrix();
        translate((j * ARENA_SIZE / 100) - H_A_S, 
                  -H_A_S, 
                  H_A_S - (i * ARENA_SIZE / 100));
        box(ARENA_SIZE / 100);
      popMatrix();
    }
}


// render sound wave to boundary
void render_soundwave() {
  float x, y, z;
  
  stroke(200);
  noFill();
  beginShape();
  for (int i = 0; i < SOUND.get_size(); i++) {
    y = map(SOUND.get_ith(i), 0, 1023, -H_A_S, H_A_S);
    
    if (i > 3 * SOUND.get_size() / 4) {
      x = ((i - (3 * SOUND.get_size() / 4)) * 4 * ARENA_SIZE / SOUND.get_size()) - H_A_S; 
      z = H_A_S;
    } else if (i > SOUND.get_size() / 2) {
      x = -H_A_S;
      z = (((i - (SOUND.get_size() / 2)) * 4 * ARENA_SIZE / SOUND.get_size()) - H_A_S);
    } else if (i > SOUND.get_size() / 4) {
      x = H_A_S - ((i - (SOUND.get_size() / 4)) * 4 * ARENA_SIZE / SOUND.get_size());
      z = -H_A_S;
    } else {
      x = H_A_S;
      z = H_A_S - (i * 4 * ARENA_SIZE / SOUND.get_size());
    }
    
    vertex(x, y, z);
  }
  endShape();
}


// draw axes labels
void render_axes() {
  textSize(400);
  fill(255);
  pushMatrix();
    translate(-H_A_S, 0, 0);
    text("-X", 0, 0, 0);
  popMatrix();
  pushMatrix();
    translate(H_A_S, 0, 0);
    text("+X", 0, 0, 0);
  popMatrix();
  pushMatrix();
    translate(0, -H_A_S, 0);
    text("-Y", 0, 0, 0);
  popMatrix();
  pushMatrix();
    translate(0, H_A_S, 0);
    text("+Y", 0, 0, 0);
  popMatrix();
  pushMatrix();
    translate(0, 0, -H_A_S);
    text("-Z", 0, 0, 0);
  popMatrix();
  pushMatrix();
    translate(0, 0, H_A_S);
    text("+Z", 0, 0, 0);
  popMatrix();
}


// render raw data in front of the camera
void render_data() {
  // requires some better transformations and lighting
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  PVector txt_plane = PVector.add(PVector.mult(look, 1000), CAMERA_EYE);
  
  int col_1 = -800;
  int col_2 = 100;
  int row_1 = -60;
  int row_2 = 60;
  
  textSize(50);
  pushMatrix();
    translate(txt_plane.x, txt_plane.y, txt_plane.z);
    rotateX(PI);
    fill(200);
    box(2000, 500, 10);
    translate(0, 0, 20);
    noStroke();
    fill(255);
    text("Light: " + str(LIGHT.get_last()), col_1, row_1, 0);
    text("Sound: " + str(SOUND.get_last()), col_2, row_1, 0);
    text("Angles: " + str(EULER.x) 
             + ", " + str(EULER.y) 
             + ", " + str(EULER.z), col_1, 60, 0);
    text("Buttons: " + str(BTN_L) + ", " + str(BTN_R), col_2, row_2, 0);
  popMatrix();
}


