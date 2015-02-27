/* Notes:
 * make the boundaries run the game of life!!!
 * make the derivative of the soundwave determine the speed of life
 *
 */
 
 
// render life board to arena walls
void render_life() {
  noStroke();
  
  fill(255);
  
  // +z wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE.get_cell(i, j)) {
        pushMatrix();
          translate((j * LIFE_CELL_SIZE) - H_A_S, H_A_S - (i * LIFE_CELL_SIZE), H_A_S);
          box(LIFE_CELL_SIZE, LIFE_CELL_SIZE, LIFE_CELL_THICK);
        popMatrix();
      }
  
  // +x wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE.get_cell(i, j + LIFE_WIDTH)) {
        pushMatrix();
          translate(H_A_S, H_A_S - (i * LIFE_CELL_SIZE), H_A_S - (j * LIFE_CELL_SIZE));
          box(LIFE_CELL_THICK, LIFE_CELL_SIZE, LIFE_CELL_SIZE);
        popMatrix();
      }
  
  // -z wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE.get_cell(i, j + (2 *LIFE_WIDTH))) {
        pushMatrix();
          translate(H_A_S - (j * LIFE_CELL_SIZE), H_A_S - (i * LIFE_CELL_SIZE), -H_A_S);
          box(LIFE_CELL_SIZE, LIFE_CELL_SIZE, LIFE_CELL_THICK);
        popMatrix();
      }
  
  // -x wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE.get_cell(i, j + (3 * LIFE_WIDTH))) {
        pushMatrix();
          translate(-H_A_S, H_A_S - (i * LIFE_CELL_SIZE), (j * LIFE_CELL_SIZE) - H_A_S);
          box(LIFE_CELL_THICK, LIFE_CELL_SIZE, LIFE_CELL_SIZE);
        popMatrix();
      }
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


// renders the shown boxes to the screen
void render_boxes() {
  noStroke();
  
  PVector p, q;

  for (int i = 0; i < NUM_SHOWN; i++) {
    // position of box (in pixels)
    p = POSITIONS[i];

    // to become coordinates of box within the field
    q = p.get();
    q.x = floor(q.x / FIELD_CELL_SIZE);
    q.y = floor(q.y / FIELD_CELL_SIZE);
    q.z = floor(q.z / FIELD_CELL_SIZE);
    
    fill(FIELD.c_at_p(q));
    pushMatrix();
      translate(-H_F_S, -H_F_S, -H_F_S);
      translate(p.x, p.y, p.z);
      box(FIELD_CELL_SIZE);
    popMatrix();
  }
}


// render only the boundary of the field
void render_soundbox() {
  noStroke();
  
  // -z wall
  for (int i = 0; i < FIELD_WIDTH; i++)
    for (int j = 0; j < FIELD_WIDTH; j++) {
      fill(FIELD.c_at_c(i, j, 0));
      pushMatrix();
        translate((j * FIELD_CELL_SIZE) - H_F_S, 
                  H_F_S - (i * FIELD_CELL_SIZE), 
                  -H_F_S);
        box(FIELD_CELL_SIZE, FIELD_CELL_SIZE, FIELD_CELL_SIZE);
      popMatrix();
    }
    
  // +z wall
  for (int i = 0; i < FIELD_WIDTH; i++)
    for (int j = 0; j < FIELD_WIDTH; j++) {
      fill(FIELD.c_at_c(i, j, -1));
      pushMatrix();
        translate((j * FIELD_CELL_SIZE) - H_F_S, 
                  H_F_S - (i * FIELD_CELL_SIZE), 
                  H_F_S - FIELD_CELL_SIZE);
        box(FIELD_CELL_SIZE, FIELD_CELL_SIZE, FIELD_CELL_SIZE);
      popMatrix();
    }
    
  // -x wall
  for (int i = 0; i < FIELD_WIDTH; i++)
    for (int k = 0; k < FIELD_WIDTH; k++) {
      fill(FIELD.c_at_c(i, 0, k));
      pushMatrix();
        translate(-H_F_S, 
                  H_F_S - (i * FIELD_CELL_SIZE), 
                  (k * FIELD_CELL_SIZE) - H_F_S);
        box(FIELD_CELL_SIZE, FIELD_CELL_SIZE, FIELD_CELL_SIZE);
      popMatrix();
    }
    
  // +x wall
  for (int i = 0; i < FIELD_WIDTH; i++)
    for (int k = 0; k < FIELD_WIDTH; k++) {
      fill(FIELD.c_at_c(i, -1, k));
      pushMatrix();
        translate(H_F_S - FIELD_CELL_SIZE, 
                  H_F_S - (i * FIELD_CELL_SIZE), 
                  (k * FIELD_CELL_SIZE) - H_F_S);
        box(FIELD_CELL_SIZE, FIELD_CELL_SIZE, FIELD_CELL_SIZE);
      popMatrix();
    }
    
  // -y wall
  for (int j = 0; j < FIELD_WIDTH; j++)
    for (int k = 0; k < FIELD_WIDTH; k++) {
      fill(FIELD.c_at_c(-1, j, k));
      pushMatrix();
        translate((j * FIELD_CELL_SIZE) - H_F_S, 
                  -H_F_S + FIELD_CELL_SIZE, 
                  (k * FIELD_CELL_SIZE) - H_F_S);
        box(FIELD_CELL_SIZE, FIELD_CELL_SIZE, FIELD_CELL_SIZE);
      popMatrix();
    }
    
  // +y wall
  for (int j = 0; j < FIELD_WIDTH; j++)
    for (int k = 0; k < FIELD_WIDTH; k++) {
      fill(FIELD.c_at_c(0, j, k));
      pushMatrix();
        translate((j * FIELD_CELL_SIZE) - H_F_S, 
                  H_F_S, 
                  (k * FIELD_CELL_SIZE) - H_F_S);
        box(FIELD_CELL_SIZE, FIELD_CELL_SIZE, FIELD_CELL_SIZE);
      popMatrix();
    }
}


// render sound wave to boundary
void render_soundwave() {
  float x, y, z;
  
  stroke(255);
  noFill();
  beginShape();
  for (int i = 0; i < SOUND_BUFFER.length; i++) {
    y = map(SOUND_BUFFER[i], 0, 1023, -H_A_S, H_A_S);
    
    if (i > 3 * SOUND_BUFFER_SIZE / 4) {
      x = ((i - (3 * SOUND_BUFFER_SIZE / 4)) * 4 * ARENA_SIZE / SOUND_BUFFER_SIZE) - H_A_S; 
      z = H_A_S;
    } else if (i > SOUND_BUFFER_SIZE / 2) {
      x = -H_A_S;
      z = (((i - (SOUND_BUFFER_SIZE / 2)) * 4 * ARENA_SIZE / SOUND_BUFFER_SIZE) - H_A_S);
    } else if (i > SOUND_BUFFER_SIZE / 4) {
      x = H_A_S - ((i - (SOUND_BUFFER_SIZE / 4)) * 4 * ARENA_SIZE / SOUND_BUFFER_SIZE);
      z = -H_A_S;
    } else {
      x = H_A_S;
      z = H_A_S - (i * 4 * ARENA_SIZE / SOUND_BUFFER_SIZE);
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
    text("Light: " + str(LIGHT), col_1, row_1, 0);
    text("Sound: " + str(SOUND_DEVIATION), col_2, row_1, 0);
    text("Angles: " + str(EULER.x) 
             + ", " + str(EULER.y) 
             + ", " + str(EULER.z), col_1, 60, 0);
    text("Buttons: " + str(BTN_L) + ", " + str(BTN_R), col_2, row_2, 0);
  popMatrix();
}


