/* Notes:
 *   In flat mode:
 *     you can translate left/right and forward/backward
 *
 *   In wall mode:
 *     you can translate left/right and up/down
 *
 *   In turn mode:
 *     you can turn left/right and up/down
 *
 */


// step size when translating camera via keyboard controls
float CAMERA_STEP = 110;
// turn size when rotating camera via keyboard controls
float CAMERA_TURN = 0.05;
// conversions between serial data and camera movement (rotations and translations)
float ANGLE_SCALE_INV = 1000;  // inverted to avoid truncating
float TRANS_SCALE = 5;


// handle the serial controls
void handle_controls() {
  PVector in = PVector.mult(PVector.sub(EULER, INIT_EULER), -1);
  // positive in.y means front tilted up?
  // positive in.z means left tilted down?
  
  // LEFT handed coordinate system!!!
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  PVector down = CAMERA_AXIS.normalize(null);
  PVector left = down.cross(look);
  
  PVector local_shift;
  PVector total_shift = new PVector();
  
  PVector new_look = look.get();
  PVector new_down = down.get();
  
  if (BTN_R) {  // wall mode
    // translate left/right
    local_shift = left.get();
    local_shift.mult(-in.z * TRANS_SCALE);
    total_shift.add(local_shift);
    
    // translate up/down
    local_shift = down.get();
    local_shift.mult(-in.y * TRANS_SCALE);
    total_shift.add(local_shift);
    
  } else if (BTN_L) { // turn mode
    // turn left/right
    new_look = rh_rotate(new_look, down, -in.z / ANGLE_SCALE_INV);
    
    // turn down/up
    new_look = rh_rotate(new_look, left, in.y / ANGLE_SCALE_INV);
    new_down = rh_rotate(new_down, left, in.y / ANGLE_SCALE_INV);
    
  } else {  // flat mode
    // translate left/right
    local_shift = left.get();
    local_shift.mult(-in.z * TRANS_SCALE);
    total_shift.add(local_shift);
    
    // translate forward/backward
    local_shift = look.get();
    local_shift.mult(-in.y * TRANS_SCALE);
    total_shift.add(local_shift);
  }
  
  // apply net translation  
  CAMERA_EYE.add(total_shift);
  CAMERA_CENTER.add(total_shift);
  
  // apply net rotation
  CAMERA_CENTER = PVector.add(CAMERA_EYE, new_look);
  CAMERA_AXIS = new_down;
  
  if (BTN_R && BTN_L) {
    FIELD.randomize();
    LIFE.randomize();
    for (int i = 0; i < NUM_STARS; i++) {
      STAR_POSITIONS[i] = PVector.mult(PVector.random3D(), ARENA_SIZE);
      STAR_VELOCITIES[i] = PVector.mult(PVector.random2D(), 1000);
    }
  }
}


//------------------------------------------------------------------------
//------------------------------------------------------------------------


boolean P_DOWN = false;
boolean C_DOWN = false;
boolean F_DOWN = false;
boolean W_DOWN = false;
boolean A_DOWN = false;
boolean S_DOWN = false;
boolean D_DOWN = false;
boolean UP_DOWN = false;
boolean DOWN_DOWN = false;
boolean LEFT_DOWN = false;
boolean RIGHT_DOWN = false;


// update keyboard state
void keyPressed() {
  if (key == 'r' && !USING_SERIAL)
    setup();
  else if (key == 'p')
    P_DOWN = true;
  else if (key == 'c')
    C_DOWN = true;
  else if (key == 'f')
    F_DOWN = true;
  else if (key == 'w')
    W_DOWN = true;
  else if (key == 'a')
    A_DOWN = true;
  else if (key == 's')
    S_DOWN = true;
  else if (key == 'd')
    D_DOWN = true;
  else if (key == CODED) {
    if (keyCode == UP)
      UP_DOWN = true;
    else if (keyCode == DOWN)
      DOWN_DOWN = true;
    else if (keyCode == LEFT)
      LEFT_DOWN = true;
    else if (keyCode == RIGHT)
      RIGHT_DOWN = true;
  }
}


// update keyboard state
void keyReleased() {
  if (key == 'p')
    P_DOWN = false;
  else if (key == 'c')
    C_DOWN = false;
  else if (key == 'f')
    F_DOWN = false;
  else if (key == 'w')
    W_DOWN = false;
  else if (key == 'a')
    A_DOWN = false;
  else if (key == 's')
    S_DOWN = false;
  else if (key == 'd')
    D_DOWN = false;
  else if (key == CODED) {
    if (keyCode == UP)
      UP_DOWN = false;
    else if (keyCode == DOWN)
      DOWN_DOWN = false;
    else if (keyCode == LEFT)
      LEFT_DOWN = false;
    else if (keyCode == RIGHT)
      RIGHT_DOWN = false;
  }
}


// handle the keyboard controls
void handle_keys() {
  // LEFT handed coordinate system!!!
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  PVector down = CAMERA_AXIS.normalize(null);
  PVector left = down.cross(look);
  
  PVector local_shift;
  PVector total_shift = new PVector();
  
  PVector new_look = look.get();
  PVector new_down = down.get();
  
  if (C_DOWN) {  // translate down
    local_shift = down.get();
    local_shift.mult(CAMERA_STEP);
    total_shift.add(local_shift);
  }
  if (F_DOWN) {  // translate up
    local_shift = down.get();
    local_shift.mult(-CAMERA_STEP);
    total_shift.add(local_shift);
  }
  if (W_DOWN) {  // translate forward
    local_shift = look.get();
    local_shift.mult(CAMERA_STEP);
    total_shift.add(local_shift);
  }
  if (S_DOWN) {  // translate backward
    local_shift = look.get();
    local_shift.mult(-CAMERA_STEP);
    total_shift.add(local_shift);
  }
  if (A_DOWN) {  // translate left
    local_shift = left.get();
    local_shift.mult(CAMERA_STEP);
    total_shift.add(local_shift);
  }
  if (D_DOWN) {  // translate right
    local_shift = left.get();
    local_shift.mult(-CAMERA_STEP);
    total_shift.add(local_shift);
  }
  if (UP_DOWN) {  // turn up
    new_look = rh_rotate(new_look, left, CAMERA_TURN);
    new_down = rh_rotate(new_down, left, CAMERA_TURN);
  }
  if (DOWN_DOWN) {  // turn down
    new_look = rh_rotate(new_look, left, -CAMERA_TURN);
    new_down = rh_rotate(new_down, left, -CAMERA_TURN);
  }
  if (LEFT_DOWN) {  // turn left
    new_look = rh_rotate(new_look, down, CAMERA_TURN);
  }
  if (RIGHT_DOWN) {  // turn right
    new_look = rh_rotate(new_look, down, -CAMERA_TURN);
  }
  
  // apply net translation  
  CAMERA_EYE.add(total_shift);
  CAMERA_CENTER.add(total_shift);
  
  // apply net rotation
  CAMERA_CENTER = PVector.add(CAMERA_EYE, new_look);
  CAMERA_AXIS = new_down;
}


