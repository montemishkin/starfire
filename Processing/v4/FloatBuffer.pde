/* Notes:
 *   The _avg and _dev fields are not updated automatically when the buffer data
 *     is changed.  You must manually update using update_avg or update.
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
  
  
  // return most recent value pushed into buffer
  float get_last() {
    return _arr[_len - 1];
  }
  
  
  // returns the averag over the buffer AS OF LAST UPDATE
  float get_avg() {
    return _avg;
  }
  
  
  // returns the deviation (from average) over the buffer AS OF LAST UPDATE
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
  
  
  // update both the average and deviation
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


