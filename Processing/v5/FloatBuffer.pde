/* Notes:
 *   The _avg and _dev fields are not updated automatically when the buffer data
 *     is changed.  You must manually update using update_avg or update.
 *
 *   What if instead of copying over a whole new array each time a value is pushed,
 *     you just always keep the same array and change the insertion point?
 * 
 */

// a data buffer for float values
class FloatBuffer {
  // size of buffer
  int _len;
  // the buffer array
  float[] _arr;
  // the average over the buffer
  float _avg;
  // the deviation (from average) over the buffer
  float _dev;


  FloatBuffer(int size) {
    _len = size;
    _arr = new float[_len];
    _avg = 0;
    _dev = 0;
  }
  
  
  // returns the size of the buffer
  int get_size() {
    return _len;
  }
  
  
  // return the ith entry of the buffer
  float get_ith(int i) {
    return _arr[i];
  }
  
  
  // return most recent value pushed into buffer
  float get_last() {
    return _arr[_len - 1];
  }
  
  
  // return difference between most recent two values
  float get_diff() {
    return _arr[_len - 1] - _arr[_len - 2];
  }
  
  
  // return average over entries between [a, b) 
  float get_avg_over(int a, int b) {
    float result = 0;
    
    for (int i = a; i < b; i++) 
      result += _arr[i];
      
    result /= (b - a - 1);
    
    return result;
  }
  
  
  // returns average over entire buffer AS OF LAST UPDATE
  float get_avg() {
    return _avg;
  }
  
  
  // returns deviation (from average) over entire buffer AS OF LAST UPDATE
  float get_dev() {
    return _dev;
  }
  
  
  // update just the average
  FloatBuffer update_avg() {
    _avg = 0;
    
    for (int i = 0; i < _len; i++) 
      _avg += _arr[i];
      
    _avg /= _len;
    
    return this;
  }
  
  
  // update both average and deviation
  FloatBuffer update() {
    update_avg();
    
    _dev = 0;
    
    for (int i = 0; i < _len; i++)
      _dev += pow(_arr[i] - _avg, 2);
      
    _dev = sqrt(_dev);
    
    return this;
  }
  
  
  // push a value in
  FloatBuffer push(float val) {
    shift();
    _arr[_len - 1] = val;
    
    return this;
  }
  
  
  // shifts the buffer's entries down an index 
  FloatBuffer shift() {
    float[] result = new float[_len];
    
    for (int i = 0; i < _len - 1; i++)
      result[i] = _arr[i + 1];
      
    _arr = result;
    
    return this;
  }
  
  
  // sets all entries to a given value
  FloatBuffer set_all(float val) {
    for (int i = 0; i < _len; i++)
      _arr[i] = val;
      
    return this;
  }
}


