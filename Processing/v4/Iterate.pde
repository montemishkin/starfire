/* Notes:
 *   What if you made the stars move around the sphere surface as if they were
 *     running "dots" but just wrapped around the sphere surface.
 *
 */


// moves the stars one step forward in time
void iterate_stars() {
  PVector p, v, th, ph;
  PVector zh = new PVector(0, cos(T / 30), sin(T / 20));
  
  for (int i = 0; i < NUM_STARS; i++) {
    p = STAR_POSITIONS[i];
    v = STAR_VELOCITIES[i];
    
    ph = PVector.mult(zh.cross(p).normalize(null), cos(T / 10));
    th = PVector.mult(p.cross(ph).normalize(null), sin(T / 7));
    
    p.add(PVector.mult(PVector.add(PVector.mult(ph, v.x), PVector.mult(th, v.y)), DT));
  } 
}


// render and iterate the dots
//   (since they do not self interact this is ok and saves a loop over the array)
void render_iterate_dots() {
  noStroke();
  
  PVector p;
  PVector v;
  float s;
  
  for (int i = 0; i < NUM_DOTS; i++) {
    p = DOT_POSITIONS[i];
    v = flow(p);
    s = map(v.magSq(), 0, 700, 0, 255);
    
    fill(color((255 / 2) * (cos(s / 200) + 1),
               (255 / 2) * (sin(s / 200) + 1),
               (255 / 2) * (cos(sin(s / 200) + 1))));
    
    pushMatrix();
      translate(p.x, p.y, p.z);
      box(100);
    popMatrix();
    
    DOT_POSITIONS[i].add(PVector.mult(v, DT));
    
    // if offscreen then reset position
    if ((DOT_POSITIONS[i].x < -H_A_S) || (H_A_S < DOT_POSITIONS[i].x) ||
        (DOT_POSITIONS[i].y < -H_A_S) || (H_A_S < DOT_POSITIONS[i].y) ||
        (DOT_POSITIONS[i].z < -H_A_S) || (H_A_S < DOT_POSITIONS[i].z))
      DOT_POSITIONS[i] = new PVector(random(-H_A_S, H_A_S),
                                     random(-H_A_S, H_A_S),
                                     random(-H_A_S, H_A_S));
  }
}


// this shouldn't go here?
PVector flow(PVector p) {
  //return new PVector(100, -201, -401);
  
  return PVector.mult(p.cross(new PVector(0, 1, 0)), 0.1);
  
//  return new PVector(-100 * cos(p.y / 1000),
//                     100 * sin(p.z / 1000),
//                     100 * cos(p.x / 1000));
  
//  return new PVector(-400 * sin(exp(p.y*p.y / 1000000)),
//                     -400 * sin(exp(p.z*p.z / 1000000)),
//                     -400 * sin(exp(p.x*p.x / 1000000)));
}


