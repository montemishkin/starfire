

// updates the actual camera to reflect any changes made to the camera vectors
void set_camera() {
  camera(CAMERA_EYE.x   , CAMERA_EYE.y   , CAMERA_EYE.z   ,
         CAMERA_CENTER.x, CAMERA_CENTER.y, CAMERA_CENTER.z, 
         CAMERA_AXIS.x  , CAMERA_AXIS.y  , CAMERA_AXIS.z  );
}


// rotates vector v around unit vector n by angle phi according to right hand rule
PVector rh_rotate(PVector v, PVector n, float phi) {
  PVector n_comp   = PVector.mult(n, v.dot(n));
  PVector vn_comp  = PVector.mult(v.cross(n), -sin(phi));
  PVector nvn_comp = PVector.mult(n.cross(v.cross(n)), cos(phi));
  
  return PVector.add(PVector.add(n_comp, vn_comp), nvn_comp);
}


// returns a random color
color random_color() {
  return color(floor(random(256)), floor(random(256)), floor(random(256)));
}


// returns a "random" vector about which the color field rotates locally 
PVector random_omega() {
  return new PVector(random(2), random(2), random(2));
}


// the right kind of modulo
int mod(float n, float m) {
  return int(n) - (int(m) * floor(n / m));
}


// shifts a float list's entries down an index 
float[] shift_float_list(float[] list) {
  float[] result = new float[list.length];
  
  for (int i = 0; i < list.length - 1; i++)
    result[i] = list[i + 1];
    
  return result;
}


// calculates average value of a float list
float float_list_average(float[] list) {
  float sum = 0;
  
  for (int i = 0; i < list.length; i++)
    sum += list[i];
    
  return sum / list.length;
}


// calculates "standard deviation" of a float list (from its average)
float float_list_deviation(float[] list) {
  float av = float_list_average(list);
  float dev = 0;
  
  for (int i = 0; i < list.length; i++)
    dev += pow(list[i] - av, 2);
    
  return sqrt(dev);
}


