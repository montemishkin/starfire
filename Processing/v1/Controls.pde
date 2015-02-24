/* You will need to have a switch to toggle between turn and translate modes.
 * In turn mode:
 *     operations performed on "look" vector
 *
 * In translate mode:
 *     operations performed on both eye location and scene center
 *     except for the yaw which idk what to do with.  maybe just same as turn mode?
 * 
 * Also, you need to:
 *     place restriction on where you can be
 *     maybe somehow show the edge of the arena also
 */


// step size when translating camera via keyboard controls
float CAMERA_STEP = 110;
// turn size when rotating camera via keyboard controls
float CAMERA_TURN = 0.05;


void handle_controls() {
  float angle_scale = 3600;
  float trans_scale = 1;
  
//  // translate down
//  PVector shift = CAMERA_AXIS.normalize(null);
//  shift.mult(CAMERA_STEP);
//  CAMERA_EYE.add(shift);
//  CAMERA_CENTER.add(shift);
   
  // translate forward/backward
  // shift both CAMERA_EYE and CAMERA_CENTER a little bit along look
  PVector shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
  shift.normalize();
  shift.mult(-EULERS[1] / trans_scale);
  CAMERA_EYE.add(shift);
  CAMERA_CENTER.add(shift);
    
  // translate left/right
  // shift both CAMERA_EYE and CAMERA_CENTER a little bit along (look x CAMERA_AXIS)
  shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE).cross(CAMERA_AXIS);
  shift.normalize();
  shift.mult(-EULERS[2] / trans_scale);
  CAMERA_EYE.add(shift);
  CAMERA_CENTER.add(shift);

//  // look down
//  // rotate both look and CAMERA_AXIS around n = (look x CAMERA_AXIS)
//  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
//  PVector n = look.cross(CAMERA_AXIS).normalize(null);
//  look = rh_rotate(look, n, CAMERA_TURN);
//  CAMERA_AXIS = rh_rotate(CAMERA_AXIS, n, CAMERA_TURN);
//  CAMERA_CENTER = PVector.add(CAMERA_EYE, look);

  // turn left/right
  PVector up = CAMERA_AXIS.normalize(null);
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
  look = rh_rotate(look, up, -EULERS[0] / angle_scale);
  CAMERA_CENTER = PVector.add(CAMERA_EYE, look);
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
  if (key == 'r')                    // for debug only.  remove later
    setup();
  if (key == 'c')
    C_DOWN = true;
  if (key == 'f')
    F_DOWN = true;
  if (key == 'w')
    W_DOWN = true;
  if (key == 'a')
    A_DOWN = true;
  if (key == 's')
    S_DOWN = true;
  if (key == 'd')
    D_DOWN = true;
  if (key == CODED) {
    if (keyCode == UP)
      UP_DOWN = true;
    if (keyCode == DOWN)
      DOWN_DOWN = true;
    if (keyCode == LEFT)
      LEFT_DOWN = true;
    if (keyCode == RIGHT)
      RIGHT_DOWN = true;
  }
  
  //TEST
  if (key == 'p') {
    println(CAMERA_EYE);
    println(CAMERA_CENTER);
    println(CAMERA_AXIS);
  }
}


void keyReleased() {
  if (key == 'c')
    C_DOWN = false;
  if (key == 'f')
    F_DOWN = false;
  if (key == 'w')
    W_DOWN = false;
  if (key == 'a')
    A_DOWN = false;
  if (key == 's')
    S_DOWN = false;
  if (key == 'd')
    D_DOWN = false;
  if (key == CODED) {
    if (keyCode == UP)
      UP_DOWN = false;
    if (keyCode == DOWN)
      DOWN_DOWN = false;
    if (keyCode == LEFT)
      LEFT_DOWN = false;
    if (keyCode == RIGHT)
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
    
    //WHY ARE UP AND DOWN BACKWARDS??????
    
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

