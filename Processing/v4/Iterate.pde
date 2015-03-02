/* Notes:
 *   What if you made the stars move around the sphere surface as if they were
 *     running "dots" but just wrapped around the sphere surface.
 *   What if you instead modeled the star motion in spherical coordinates, thus
 *     opening the possibility for movements in radial direction.
 *     Maybe: v = "position in cartesian expansion" x "(r, cos(theta), sin(phi)) but
 *     in cartesian".
 *
 */


// moves the stars one step forward in time
void iterate_stars() {
  PVector p, v, th, ph;
  PVector zh = new PVector(0, 1, 0);
  
  for (int i = 0; i < NUM_STARS; i++) {
    STAR_POSITIONS[i].add(PVector.mult(star_flow(STAR_POSITIONS[i]), DT));
    //STAR_POSITIONS[i].setMag(ARENA_SIZE);
  }
}


// this shouldn't go here?
PVector star_flow(PVector p) {
//  return new PVector(-1000 * cos(p.y / 1000),
//                      1000 * sin(p.x / 1000));
                      
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
  
//  return new PVector(-400 * sin(exp(p.y*p.y / 1000000)),
//                     -400 * sin(exp(p.z*p.z / 1000000)),
//                     -400 * sin(exp(p.x*p.x / 1000000)));
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


