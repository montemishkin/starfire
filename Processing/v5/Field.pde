/* Notes:
 * 
 */
 
 
// 2D color field
class Field {
  // rows, columns
  int _r, _c;
  // the color array
  color[][] _a;
  
  
  Field(int r, int c) {
    _r = r;
    _c = c;
    
    _a = new color[_r][_c];
  }
  
  
  // set each entry to a random color
  Field randomize() {
    for (int i = 0; i < _r; i++)
      for (int j = 0; j < _c; j++)
        _a[i][j] = color(random(255), random(255), random(255));
                                    
    return this;
  }
  
  
  // return color at given (i, j) coordinates
  color at_ij(int i, int j) {
    return _a[mod(i, _r)][mod(j, _c)];
  }
  
  
  // return laplacian at given (i, j) coordinates
  PVector lapl(float i, float j) {
    color temp_c = _a[mod(i, _r)][mod(j, _c)];
    PVector temp_v = new PVector(temp_c >> 16 & 0xFF,
                                 temp_c >>  8 & 0xFF,
                                 temp_c       & 0xFF);
    
    PVector result = PVector.mult(temp_v, -4);
    
    temp_c = _a[mod(i + 1, _r)][mod(j, _c)];
    temp_v = new PVector(temp_c >> 16 & 0xFF,
                         temp_c >>  8 & 0xFF,
                         temp_c       & 0xFF);
    result.add(temp_v);
    
    temp_c = _a[mod(i - 1, _r)][mod(j, _c)];
    temp_v = new PVector(temp_c >> 16 & 0xFF,
                         temp_c >>  8 & 0xFF,
                         temp_c       & 0xFF);
    result.add(temp_v);
    
    temp_c = _a[mod(i, _r)][mod(j + 1, _c)];
    temp_v = new PVector(temp_c >> 16 & 0xFF,
                         temp_c >>  8 & 0xFF,
                         temp_c       & 0xFF);
    result.add(temp_v);
    
    temp_c = _a[mod(i, _r)][mod(j - 1, _c)];
    temp_v = new PVector(temp_c >> 16 & 0xFF,
                         temp_c >>  8 & 0xFF,
                         temp_c       & 0xFF);
    result.add(temp_v);
          
    return result;
  }
  
  
  // iterate to next step
  Field iterate(float k_color, float k_space, float k_growth) {
    color[][] next = new color[_r][_c];
  
    color temp_c;
    PVector temp_v, dc_color, dc_space, dc;
  
    for (int i = 0; i < _r; i++)
      for (int j = 0; j < _c; j++) {
        temp_c = _a[mod(i, _r)][mod(j, _c)];
        temp_v = new PVector(temp_c >> 16 & 0xFF,
                             temp_c >>  8 & 0xFF,
                             temp_c       & 0xFF);

        dc_color = temp_v.cross(new PVector(random(2), 
                                            random(2), 
                                            random(2)));
        
        dc_color.add(PVector.mult(temp_v, k_growth));
        dc_color.mult(k_color);
        
        dc_space = PVector.mult(lapl(i, j), k_space);
        
        dc = PVector.add(dc_color, dc_space);
        dc.mult(DT);
        
        temp_v.add(dc);
        
        next[i][j] = color(constrain(temp_v.x, 0, 255),
                           constrain(temp_v.y, 0, 255),
                           constrain(temp_v.z, 0, 255));
      }
    
    _a = next;
    
    return this;
  }
}


