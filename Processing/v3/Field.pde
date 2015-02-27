/* Notes:
 * You can evaluate the field at a coordinate (individually i, j, k) 
 *     or a position (a pvector).
 * When you do so, you can get back a vector (a pvector) or a color (a color).
 *
 * For example, v_at_c gives the vector at some coordinates.  That is, it takes three
 *     integer arguments and returns a pvector.
 *
 *
 * HEY! maybe try replacing this by a 4d int array.  use floats to do iterations but
 *     that's all?  In fact, maybe a 3d color array would be better?
 * 
 */
 
 
// 3D PVector field
class Field {
  // height, width, depth of array
  int _h, _w, _d;
  // the field array
  PVector[][][] _f;
  
  
  Field(int h, int w, int d) {
    _h = h;
    _w = w;
    _d = d;
    
    _f = new PVector[_h][_w][_d];
  }
  
  
  // set all entries to zero
  Field blank() {
    for (int i = 0; i < _h; i++)
      for (int j = 0; j < _w; j++)
        for (int k = 0; k < _d; k++)
          _f[i][j][k] = new PVector();
                                    
    return this;
  }
  
  
  // randomize each entry between min and max
  Field randomize(float min, float max) {
    for (int i = 0; i < _h; i++)
      for (int j = 0; j < _w; j++)
        for (int k = 0; k < _d; k++)
          _f[i][j][k] = new PVector(random(min, max), 
                                    random(min, max), 
                                    random(min, max));
                                    
    return this;
  }
  
  
  // set each entry to a random color
  Field color_randomize() {
    for (int i = 0; i < _h; i++)
      for (int j = 0; j < _w; j++)
        for (int k = 0; k < _d; k++)
          _f[i][j][k] = new PVector(round(random(0, 255)), 
                                    round(random(0, 255)), 
                                    round(random(0, 255)));
                                    
    return this;
  }
  
  
  // trim each entry to be a valid color
  Field color_trim() {
    PVector v;
    for (int i = 0; i < _h; i++)
      for (int j = 0; j < _w; j++)
        for (int k = 0; k < _d; k++) {
          v = _f[i][j][k];
          
          v.x = constrain(floor(v.x), 0, 255);
          v.y = constrain(floor(v.y), 0, 255);
          v.z = constrain(floor(v.z), 0, 255); 
        }
    return this;
  }
  
  
  // return random position
  PVector random_position() {
    return new PVector(int(random(_h)), int(random(_w)), int(random(_d)));
  }
  
  
  // return vector at given coordinates
  PVector v_at_c(float i, float j, float k) {
    return _f[mod(i, _h)][mod(j, _w)][mod(k, _d)];
  }
  
  
  // return vector at given position
  PVector v_at_p(PVector p) {
    return _f[mod(int(p.x), _h)][mod(int(p.y), _w)][mod(int(p.z), _d)];
  }
  
  
  // return color at given coordinates
  color c_at_c(float i, float j, float k) {
    PVector v = _f[mod(i, _h)][mod(j, _w)][mod(k, _d)];
    return color(v.x, v.y, v.z);
  }
  
  
  // return color at given position
  color c_at_p(PVector p) {
    PVector v = _f[mod(int(p.x), _h)][mod(int(p.y), _w)][mod(int(p.z), _d)];
    return color(v.x, v.y, v.z);
  }
  
  
  // put vector v to given coordinates
  void v_to_c(PVector v, float i, float j, float k) {
    _f[mod(i, _h)][mod(j, _w)][mod(k, _d)] = v.get();
  }
  
  
  // put vector to given position w
  void v_to_p(PVector v, PVector p) {
    _f[mod(int(p.x), _h)][mod(int(p.y), _w)][mod(int(p.z), _d)] = v.get();
  }
  
  
  // put color to given coordinates
  void c_to_c(color c, float i, float j, float k) {
    _f[mod(i, _h)][mod(j, _w)][mod(k, _d)] = new PVector(c >> 16 & 0xFF,
                                                         c >> 8  & 0xFF,
                                                         c       & 0xFF);
  }
  
  
  // put color to given position
  void c_to_p(color c, PVector p) {
    _f[mod(int(p.x), _h)]
      [mod(int(p.y), _w)]
      [mod(int(p.z), _d)] = new PVector(c >> 16 & 0xFF,
                                        c >> 8  & 0xFF,
                                        c       & 0xFF);
  }
  
  
  // return laplacian at given (i,j,k) position
  PVector lapl(float i, float j, float k) {
    PVector result = PVector.mult(_f[mod(i, _h)][mod(j, _w)][mod(k, _d)], -6);
                         
    result.add(_f[mod(i + 1, _h)][mod(j    , _w)][mod(k    , _d)]);
    result.add(_f[mod(i - 1, _h)][mod(j    , _w)][mod(k    , _d)]);
    result.add(_f[mod(i    , _h)][mod(j + 1, _w)][mod(k    , _d)]);
    result.add(_f[mod(i    , _h)][mod(j - 1, _w)][mod(k    , _d)]);
    result.add(_f[mod(i    , _h)][mod(j    , _w)][mod(k + 1, _d)]);
    result.add(_f[mod(i    , _h)][mod(j    , _w)][mod(k - 1, _d)]);
          
    return result;
  }
  
  
  // iterate to next step
  Field iterate(float k_color, float k_space, float k_growth) {
    PVector[][][] next = new PVector[_h][_w][_d];
  
    PVector cur_vector, dc_color, dc_space, dc;
  
    for (int i = 0; i < _h; i++)
      for (int j = 0; j < _w; j++) 
        for (int k = 0; k < _d; k++) {
          cur_vector = v_at_c(i, j, k);
                                         
          //dc_color = cur_vector.cross(random_omega());
          dc_color = cur_vector.cross(new PVector(1, 1, 1));
          dc_color.add(PVector.mult(cur_vector, k_growth));
          dc_color.mult(k_color);
          
          dc_space = PVector.mult(lapl(i, j, k), k_space);
          
          dc = PVector.add(dc_color, dc_space);
          dc.mult(DT);
          
          next[i][j][k] = PVector.add(cur_vector, dc);
        }
    
    _f = next;
    color_trim();
    
    return this;
  }
}
