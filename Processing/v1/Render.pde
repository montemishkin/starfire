/* Notes:
 * make the boundaries run the game of life!!!
 * make the derivative of the soundwave determine the speed of life
 *
 */
 
 
// render life board to arena walls
void render_life() {
  fill(255);
  
  // +z wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE_1.get_cell(i, j)) {
        pushMatrix();
          translate((j * LIFE_CELL_SIZE) - H_A_S, H_A_S - (i * LIFE_CELL_SIZE), H_A_S);
          box(LIFE_CELL_SIZE, LIFE_CELL_SIZE, LIFE_CELL_THICK);
        popMatrix();
      }
  
  // +x wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE_1.get_cell(i, j + LIFE_WIDTH)) {
        pushMatrix();
          translate(H_A_S, H_A_S - (i * LIFE_CELL_SIZE), H_A_S - (j * LIFE_CELL_SIZE));
          box(LIFE_CELL_THICK, LIFE_CELL_SIZE, LIFE_CELL_SIZE);
        popMatrix();
      }
  
  // -z wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE_1.get_cell(i, j + (2 *LIFE_WIDTH))) {
        pushMatrix();
          translate(H_A_S - (j * LIFE_CELL_SIZE), H_A_S - (i * LIFE_CELL_SIZE), -H_A_S);
          box(LIFE_CELL_SIZE, LIFE_CELL_SIZE, LIFE_CELL_THICK);
        popMatrix();
      }
  
  // -x wall
  for (int i = 0; i < LIFE_WIDTH; i++)
    for (int j = 0; j < LIFE_WIDTH; j++)
      if (LIFE_1.get_cell(i, j + (3 * LIFE_WIDTH))) {
        pushMatrix();
          translate(-H_A_S, H_A_S - (i * LIFE_CELL_SIZE), (j * LIFE_CELL_SIZE) - H_A_S);
          box(LIFE_CELL_THICK, LIFE_CELL_SIZE, LIFE_CELL_SIZE);
        popMatrix();
      }
}


// renders the stars in the background
void render_stars() {
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
      translate(-FIELD_SIZE/2, -FIELD_SIZE/2, -FIELD_SIZE/2);
      translate(p.x, p.y, p.z);
      box(FIELD_CELL_SIZE);
    popMatrix();
  }
}


// draw axes labels
void render_axes_labels() {
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


