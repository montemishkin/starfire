/* Notes:
 * 
 */
 
 
// 2D boolean array with methods geared toward Game of Life
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
        
        next[i][j] = (nbrs == 3) || ((nbrs == 2) && get_cell(i, j));
      }
      
    _a = next;
    
    return this;
  }
}


