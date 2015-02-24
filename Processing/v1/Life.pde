class Life {
  // number of rows and columns
  int _r, _c;
  // boolean array
  boolean[][] _a;
  
  
  Life(int r, int c) {
    _r = r;
    _c = c;
    
    _a = new boolean[_r][_c];
  }
  
  
  // set all entries to false
  Life blank() {
    for (int i = 0; i < _r; i++)
      for (int j = 0; j < _c; j++)
        _a[i][j] = false;
        
    return this;
  }
  
  
  // randomize the array
  Life randomize() {
    for (int i = 0; i < _r; i++)
      for (int j = 0; j < _c; j++)
        _a[i][j] = (random(1) > 0.5);
    
    return this;
  }
  
  
  // get value at coordinates (modded)
  boolean get_cell(int i, int j) {
    return _a[mod(i, _r)][mod(j, _c)];
  }
  
  
  // set value at coordinates (modded)
  Life set_cell(int i, int j, boolean val) {
    _a[mod(i, _r)][mod(j, _c)] = val;
    
    return this;
  }
  
  
  // return number of live neighbors
  int neighbors(int i, int j) {
    int result = 0;
    
    for (int di = -1; di <= 1; di++)
      for (int dj = -1; dj <= 1; dj++)
        if (((di != 0) || (dj != 0)) && get_cell(i + di, j + dj))
          result++;
          
    return result;
  }
  
  
  // iterate to next step
  Life iterate() {
    boolean[][] next = new boolean[_r][_c];
    int nbrs;
    
    for (int i = 0; i < _r; i++)
      for (int j = 0; j < _c; j++) {
        nbrs = neighbors(i, j);
        
        if (get_cell(i, j))
          next[i][j] = ((nbrs == 2) || (nbrs == 3));
        else
          next[i][j] = (nbrs == 3);
      }
      
    _a = next;
    
    return this;
  }
}
