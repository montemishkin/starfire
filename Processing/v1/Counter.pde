class Counter {
  // the counter value
  int _v;
  // the counting modulus
  int _m;
  
  
  Counter() {
    _v = 0;
    _m = 1;
  }
  
  
  // tells whether or not the count is zero
  boolean is_zero() {
    return _v == 0;
  }
  
  
  // mods out the counter value
  Counter mod_it() {
    _v = mod(_v, _m);
    
    return this;
  }
  
  
  // increase the counter value by one (modded)
  Counter inc() {
    _v++;
    return mod_it();
  }
  
  
  // decrease the counter value by one (modded)
  Counter dec() {
    _v--;
    return mod_it();
  }
  
  
  // set a new modulus and then mod by it
  Counter set_modulus(int m) {
//    if (m <= 0) {
//      println("Error: non-positive modulus");
//      exit();
//    }
    
    _m = m;
    
    return mod_it();
  }
}

