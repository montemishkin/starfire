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


// handle the serial controls
void handle_controls() {
  // calculate input
  PVector in = PVector.sub(INIT_EULER, EULER);
  
  // calculate unit vectors (LEFT handed coordinate system!!)
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
  
  if (BTN_R && BTN_L) {  // reset field, life, stars
    FIELD.randomize();
    LIFE.randomize();
    for (int i = 0; i < N_STARS; i++)
      STARS[i] = PVector.mult(PVector.random3D(), ARENA_SIZE);
  }
}


