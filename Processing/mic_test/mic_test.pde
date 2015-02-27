import processing.serial.*;

Serial myPort;

// how many of initial readings to ignore
int trash_cutoff = 100;
// how many of initial readings have already been ignored
int trash_counter = 0;

// length of sound buffer
int buffer_length = 1280;
// buffer which logs sound readings
float[] buffer = new float[buffer_length];
// most recent sound reading
float last;
// change between two most recent sound readings
float delta;
// average over buffer
float average;
// deviation (from average) of buffer
float deviation;


void setup() {  
  size(displayWidth, displayHeight, P3D);
  
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  myPort.bufferUntil('\n');
}


void draw() {
  float x, y, r;
  
  background(0);
  
  // print data to screen
  fill(255);
  text("Last: " + str(last), 10, 20);
  text("Delta: " + str(delta), 10, 40);
  text("Average: " + str(average), 10, 60);
  text("Deviation: " + str(deviation), 10, 80);
  
  // plot sound wave
  stroke(255);
  noFill();
  beginShape();
  for (int i = 0; i < buffer.length; i++) {
    x = i;
    y = map(buffer[i], 0, 1023, height, 0);
    vertex(x, y);
  }
  endShape();
  
  // determine color from sound
  noStroke();
  fill(map(last, 0, 1023, 0, 255),
       map(last, 0, 1023, 0, 255), 
       100);
  
  // render circle with radius proportional to last
  r = map(last, 100, 400, 0, height / 4);
  ellipse(width / 5, height / 2, r, r);
  
  // render circle with radius proportional to delta
  r = map(delta, 0, 500, 0, height / 4);
  ellipse(2 * width / 5, height / 2, r, r);
  
  // render circle with radius proportional to average
  r = map(average, 0, 1023, 0, height / 4);
  ellipse(3 * width / 5, height / 2, r, r);
  
  // render circle with radius proportional to deviation
  r = map(deviation, 0, 1023, 0, height / 4);
  ellipse(4 * width / 5, height / 2, r, r);
}


void serialEvent(Serial p) {
  if (trash_counter < trash_cutoff) {
    p.readString();
    trash_counter++;
  } else {
    buffer = shift_float_list(buffer);
    buffer[buffer.length - 1] = float(trim(p.readString()));
    
    last = buffer[buffer.length - 1];
    delta = last - buffer[buffer.length - 2];
    average = float_list_average(buffer);
    deviation = float_list_deviation(buffer);
  }
} 


//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------


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

