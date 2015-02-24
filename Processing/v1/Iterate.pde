/* What if you made the stars move around the sphere surface as if they were
 * running "dots" but just wrapped around the sphere surface.
 *
 */


// moves the stars one step forward
void iterate_stars() {
  PVector p, v, th, ph;
  PVector zh = new PVector(0, cos(T / 30), sin(T / 20));
  
  for (int i = 0; i < NUM_STARS; i++) {
    p = STAR_POSITIONS[i];
    v = STAR_VELOCITIES[i];
    
    ph = zh.cross(p);
    th = p.cross(ph);
    
    ph.normalize();
    th.normalize();
    
    ph.mult(cos(T / 10));
    th.mult(sin(T / 7));
    
    p.add(PVector.mult(PVector.add(PVector.mult(ph, v.x), PVector.mult(th, v.y)), DT));
  } 
}


// moves the boxes one step forward
void iterate_boxes() {
  PVector p, v;
  
  for (int n = 0; n < NUM_SHOWN; n++) {
    p = POSITIONS[n];
    v = VELOCITIES[n];
    
    if ((p.x < 0) || (p.x > FIELD_SIZE))
      v.x *= -1;
    if ((p.y < 0) || (p.y > FIELD_SIZE))
      v.y *= -1;
    if ((p.z < 0) || (p.z > FIELD_SIZE))
      v.z *= -1;
      
    p.add(PVector.mult(v, 100 * DT));
  }
}
