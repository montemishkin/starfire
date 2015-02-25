/* Notes:
 * You will need to have a switch to toggle between turn and translate modes.
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
// conversions between serial data and camera movement (rotations and translations)
float ANGLE_SCALE_INV = 2000;  // inverted to avoid truncating
float TRANS_SCALE = 2;


void handle_controls() {
  // translate forward/backward
  // shift both CAMERA_EYE and CAMERA_CENTER a little bit along look
  PVector shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
  shift.normalize();
  shift.mult(EULERS[1] * TRANS_SCALE);
  CAMERA_EYE.add(shift);
  CAMERA_CENTER.add(shift);
    
  // translate left/right
  // shift both CAMERA_EYE and CAMERA_CENTER a little bit along (look x CAMERA_AXIS)
  shift = PVector.sub(CAMERA_CENTER, CAMERA_EYE).cross(CAMERA_AXIS);
  shift.normalize();
  shift.mult(-EULERS[2] * TRANS_SCALE);
  CAMERA_EYE.add(shift);
  CAMERA_CENTER.add(shift);

  // turn left/right
  PVector up = CAMERA_AXIS.normalize(null);
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
  look = rh_rotate(look, up, -EULERS[0] / ANGLE_SCALE_INV);
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

