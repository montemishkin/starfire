/* Notes:
 * Let's try three different serial control modes:
 * In flat mode:
 *     you can translate left/right and forward/backward
 *
 * In wall mode:
 *     you can translate left/right and up/down
 *
 * In turn mode:
 *     you can turn left/right and up/down
 * 
 * Also, you need to:
 *     place restriction on where you can be
 *     maybe somehow show the edge of the arena also
 *     optimize the whole handle_controls dealio
 */


// step size when translating camera via keyboard controls
float CAMERA_STEP = 110;
// turn size when rotating camera via keyboard controls
float CAMERA_TURN = 0.05;
// conversions between serial data and camera movement (rotations and translations)
float ANGLE_SCALE_INV = 1000;  // inverted to avoid truncating
float TRANS_SCALE = 2;


void handle_controls() {
  PVector in = PVector.mult(PVector.sub(EULER, INIT_EULER), -1);
  // positive in.y means front tilted up
  // positive in.z means left tilted down
  
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  PVector down = CAMERA_AXIS.normalize(null);
  PVector left = look.cross(down);
  
  PVector local_shift;
  PVector total_shift = new PVector();
  
  PVector new_look = look.get();
  PVector new_down = down.get();
  
  if (BTN_R) {  // wall mode
    // translate left/right
    local_shift = left.get();
    local_shift.mult(in.z * TRANS_SCALE);
    total_shift.add(local_shift);
    
    // translate up/down
    local_shift = down.get();
    local_shift.mult(-in.y * TRANS_SCALE);
    total_shift.add(local_shift);
    
  } else if (BTN_L) { // turn mode
    // turn left/right
    new_look = rh_rotate(new_look, down, -in.z / ANGLE_SCALE_INV);
    
    // turn down/up
    new_look = rh_rotate(new_look, left, -in.y / ANGLE_SCALE_INV);
    new_down = rh_rotate(new_down, left, -in.y / ANGLE_SCALE_INV);
    
  } else {  // flat mode
    // translate left/right
    local_shift = left.get();
    local_shift.mult(in.z * TRANS_SCALE);
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
}


//------------------------------------------------------------------------
//------------------------------------------------------------------------


Boolean C_DOWN = false;
Boolean F_DOWN = false;
Boolean W_DOWN = false;
Boolean A_DOWN = false;
Boolean S_DOWN = false;
Boolean D_DOWN = false;
Boolean UP_DOWN = false;
Boolean DOWN_DOWN = false;
Boolean LEFT_DOWN = false;
Boolean RIGHT_DOWN = false;


void keyPressed() {
  if (key == 'r')                    // for testing only
    setup();
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


void keyReleased() {
  if (key == 'c')
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


void handle_keys() {
  if (C_DOWN) { // translate down
    PVector shift = CAMERA_AXIS.normalize(null);
    shift.mult(CAMERA_STEP);
    CAMERA_EYE.add(shift);
    CAMERA_CENTER.add(shift);
  }
  if (F_DOWN) { // translate up
    PVector shift = CAMERA_AXIS.normalize(null);
    shift.mult(-CAMERA_STEP);
    CAMERA_EYE.add(shift);
    CAMERA_CENTER.add(shift);
  }
  if (W_DOWN) { // translate forward
    // shift both CAMERA_EYE and CAMERA_CENTER a little bit along look
    PVector shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
    shift.normalize();
    shift.mult(CAMERA_STEP);
    CAMERA_EYE.add(shift);
    CAMERA_CENTER.add(shift);
  }
  if (A_DOWN) { // translate left
    // shift both CAMERA_EYE and CAMERA_CENTER a little bit along (look x CAMERA_AXIS)
    PVector shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE).cross(CAMERA_AXIS);
    shift.normalize();
    shift.mult(-CAMERA_STEP);
    CAMERA_EYE.add(shift);
    CAMERA_CENTER.add(shift);
  }
  if (S_DOWN) { // translate backward
    // shift both CAMERA_EYE and CAMERA_CENTER a little bit along look
    PVector shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
    shift.normalize();
    shift.mult(-CAMERA_STEP);
    CAMERA_EYE.add(shift);
    CAMERA_CENTER.add(shift);
  }
  if (D_DOWN) { // translate right
    // shift both CAMERA_EYE and CAMERA_CENTER a little bit along (look x CAMERA_AXIS)
    PVector shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE).cross(CAMERA_AXIS);
    shift.normalize();
    shift.mult(CAMERA_STEP);
    CAMERA_EYE.add(shift);
    CAMERA_CENTER.add(shift);
  }
  if (UP_DOWN) { // look up  
    // rotate both look and CAMERA_AXIS around n = (look x CAMERA_AXIS)
    PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
    PVector n = look.cross(CAMERA_AXIS).normalize(null);
    look = rh_rotate(look, n, -CAMERA_TURN);
    CAMERA_AXIS = rh_rotate(CAMERA_AXIS, n, -CAMERA_TURN);
    CAMERA_CENTER = PVector.add(CAMERA_EYE, look);
  }
  if (DOWN_DOWN) { // look down
    // rotate both look and CAMERA_AXIS around n = (look x CAMERA_AXIS)
    PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
    PVector n = look.cross(CAMERA_AXIS).normalize(null);
    look = rh_rotate(look, n, CAMERA_TURN);
    CAMERA_AXIS = rh_rotate(CAMERA_AXIS, n, CAMERA_TURN);
    CAMERA_CENTER = PVector.add(CAMERA_EYE, look);
  }
  if (LEFT_DOWN) { // turn left
    PVector up = CAMERA_AXIS.normalize(null);
    PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
    look = rh_rotate(look, up, CAMERA_TURN);
    CAMERA_CENTER = PVector.add(CAMERA_EYE, look);
  }
  if (RIGHT_DOWN) { // turn right
    PVector up = CAMERA_AXIS.normalize(null);
    PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
    look = rh_rotate(look, up, -CAMERA_TURN);
    CAMERA_CENTER = PVector.add(CAMERA_EYE, look);
  }
}

