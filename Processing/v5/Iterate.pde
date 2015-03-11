/* Notes:
 *
 */


// render and iterate the stars
void render_iterate_stars() {
  PVector p;
  
  noStroke();
  fill(255);

  for (int i = 0; i < N_STARS; i++) {
    p = STARS[i];
    
    pushMatrix();
      translate(p.x, p.y, p.z);
      box(STAR_SIZE);
    popMatrix();

    // iterate
    p.add(PVector.mult(star_flow(STARS[i]), DT));
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
void render_iterate_blocks() {
  PVector p, v;
  float s;
  
  noStroke();

  for (int i = 0; i < N_BLOCKS; i++) {
    p = BLOCKS[i];
    v = block_flow(p);
    s = map(v.magSq(), 0, 700, 0, 255);
    
    fill(color((255 / 2) * (cos(s / 5000) + 1),
               (255 / 2) * (sin(s / 5000) + 1),
               (255 / 2) * (cos(sin(s / 5000) + 1))));
    
    pushMatrix();
      translate(p.x, p.y, p.z);
      box(BLOCK_SIZE);
    popMatrix();
    
    // iterate
    p.add(PVector.mult(v, DT));
    
    // if offscreen then reset position
    if ((BLOCKS[i].x < -H_A_S) || (H_A_S < BLOCKS[i].x) ||
        (BLOCKS[i].y < -H_A_S) || (H_A_S < BLOCKS[i].y) ||
        (BLOCKS[i].z < -H_A_S) || (H_A_S < BLOCKS[i].z))
      BLOCKS[i] = new PVector(random(-H_A_S, H_A_S),
                                       random(-H_A_S, H_A_S),
                                       random(-H_A_S, H_A_S));
  }
}


// this shouldn't go here?
PVector block_flow(PVector p) {
  PVector in = PVector.sub(INIT_EULER, EULER);
  
  // calculate unit vectors (LEFT handed coordinate system!!)
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  PVector down = CAMERA_AXIS.normalize(null);
  PVector left = down.cross(look);
  
  PVector mpu_up = down.get();
  
  mpu_up = rh_rotate(mpu_up, look, -in.z * PI / 180);
  mpu_up = rh_rotate(mpu_up, left, -in.y * PI / 180);
  
  return PVector.mult(p.cross(mpu_up), 0.4);
}


