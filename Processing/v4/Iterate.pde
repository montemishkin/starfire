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


