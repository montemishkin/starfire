/* Notes:
 *
 */


// renders the stars in the background
void render_iterate_stars() {
  noStroke();
  
  PVector r;
  
  fill(255);
  for (int i = 0; i < NUM_STARS; i++) {
    r = STAR_POSITIONS[i];
    r.add(PVector.mult(star_flow(STAR_POSITIONS[i]), DT));
    
    pushMatrix();
      translate(r.x, r.y, r.z);
      box(20);
    popMatrix();
  }
}


// this shouldn't go here?
PVector star_flow(PVector p) {
                      
  float pr = sqrt(p.x*p.x + p.y*p.y + p.z*p.z);
  float pt = acos(p.z / pr);
  float pp = atan2(p.y, p.x);
  
  float vr = -(pr - ARENA_SIZE) * exp(-pow(pr - ARENA_SIZE, 2));
  float vt = 1000 * cos( pt * pt);
  float vp = 1000 * sin(2 * pp*pp);
  
  PVector idk = new PVector(vr * sin(vt) * cos(vp),
                            vr * sin(vt) * sin(vp),
                            vr * cos(vt));
                            
  return new PVector(vr, vt, vp);
}


// render and iterate the blocks
//   (since they do not self interact this is ok and saves a loop over the array)
void render_iterate_blocks() {
  noStroke();
  
  PVector p;
  PVector v;
  float s;
  
  for (int i = 0; i < NUM_BLOCKS; i++) {
    p = BLOCK_POSITIONS[i];
    v = block_flow(p);
    s = map(v.magSq(), 0, 700, 0, 255);
    
    fill(color((255 / 2) * (cos(s / 5000) + 1),
               (255 / 2) * (sin(s / 5000) + 1),
               (255 / 2) * (cos(sin(s / 5000) + 1))));
    
    pushMatrix();
      translate(p.x, p.y, p.z);
      box(map(SOUND.get_last(), 0, 1023, 0, 100));
    popMatrix();
    
    BLOCK_POSITIONS[i].add(PVector.mult(v, DT));
    
    // if offscreen then reset position
    if ((BLOCK_POSITIONS[i].x < -H_A_S) || (H_A_S < BLOCK_POSITIONS[i].x) ||
        (BLOCK_POSITIONS[i].y < -H_A_S) || (H_A_S < BLOCK_POSITIONS[i].y) ||
        (BLOCK_POSITIONS[i].z < -H_A_S) || (H_A_S < BLOCK_POSITIONS[i].z))
      BLOCK_POSITIONS[i] = new PVector(random(-H_A_S, H_A_S),
                                       random(-H_A_S, H_A_S),
                                       random(-H_A_S, H_A_S));
  }
}


// this shouldn't go here?
PVector block_flow(PVector p) {
  PVector in = PVector.mult(PVector.sub(EULER, INIT_EULER), -1);
  // positive in.y means front tilted up?
  // positive in.z means left tilted down?
  
  // LEFT handed coordinate system!!!
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  PVector down = CAMERA_AXIS.normalize(null);
  PVector left = down.cross(look);
  
  PVector mpu_up = down.get();
  
  mpu_up = rh_rotate(mpu_up, look, -in.z * PI / 180);
  mpu_up = rh_rotate(mpu_up, left, -in.y * PI / 180);
  
  return PVector.mult(p.cross(mpu_up), 0.4);
}


