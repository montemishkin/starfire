/* Notes:
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


  FloatBuffer(int size) {
    _len = size;
    _arr = new float[_len];
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
}


