/* Notes:
 *
 */


// updates the actual camera to reflect any changes made to the camera vectors
void set_camera() {
  camera(CAMERA_EYE.x   , CAMERA_EYE.y   , CAMERA_EYE.z   ,
         CAMERA_CENTER.x, CAMERA_CENTER.y, CAMERA_CENTER.z, 
         CAMERA_AXIS.x  , CAMERA_AXIS.y  , CAMERA_AXIS.z  );
}


// rotates vector v around unit vector n by angle phi according to right hand rule
PVector rh_rotate(PVector v, PVector n, float phi) {
  PVector n_comp = PVector.mult(n, v.dot(n));
  PVector vn_comp = PVector.mult(v.cross(n), -sin(phi));
  PVector nvn_comp = PVector.mult(n.cross(v.cross(n)), cos(phi));
  
  return PVector.add(PVector.add(n_comp, vn_comp), nvn_comp);
}


// the right kind of modulo
int mod(float n, float m) {
  return int(n) - (int(m) * floor(n / m));
}


