/* Notes:
 * check out this solution to smoothing analog readings:
 *     http://arduino.cc/en/Tutorial/Smoothing
 *
 */
  

import processing.serial.*;


// background color
color BACKGROUND = color(0);
// spotlight color
color SPOT_LIGHT = color(255);


// global time counter
float T = 0;
// global time step
float DT = 0.1;
// counter for life iteration timing
Counter LIFE_PERIOD = new Counter();


// width of available arena (in pixels)
int ARENA_SIZE = 10000;
// width of color field (in pixels)
int FIELD_SIZE = ARENA_SIZE / 5;
// width of color field (number of cells per edge)
int FIELD_WIDTH = 30;
// number of life board cells per wall edge
int LIFE_WIDTH = 50;
// width of a cell within the color field (in pixels)
int FIELD_CELL_SIZE = FIELD_SIZE / FIELD_WIDTH;
// width of a cell within the life board (in pixels)
int LIFE_CELL_SIZE = ARENA_SIZE / LIFE_WIDTH;
// thickness of a cell within the life board (in pixels)
int LIFE_CELL_THICK = 40;
// half of the arena size (in pixels)
int H_A_S = ARENA_SIZE / 2;
// half of the field size (in pixels)
int H_F_S = FIELD_SIZE / 2;
// number of boxes shown
int NUM_SHOWN = 10000;
// number of stars
int NUM_STARS = 2000;


// the actual life board
Life LIFE = new Life(4 * LIFE_WIDTH, LIFE_WIDTH);
// the actual color field 
Field FIELD = new Field(FIELD_WIDTH, FIELD_WIDTH, FIELD_WIDTH);
// positions of the shown boxes (in pixels)
PVector[] POSITIONS = new PVector[NUM_SHOWN];
// velocities of the shown boxes (in pixels)
PVector[] VELOCITIES = new PVector[NUM_SHOWN];
// positions of the stars (in pixels)
PVector[] STAR_POSITIONS = new PVector[NUM_STARS];
// velocities of the stars (in pixels)
PVector[] STAR_VELOCITIES = new PVector[NUM_STARS];


// position of the eye (in pixels)
PVector CAMERA_EYE    = new PVector(0, 0, -1.6 * FIELD_SIZE);
// position of the scene center (in pixels)
PVector CAMERA_CENTER = new PVector();
// direction of "down"
PVector CAMERA_AXIS   = new PVector(0, -1, 0);


// serial port to read from
Serial PORT;
// the initial euler angles to compare to
PVector INIT_EULER = new PVector();
// euler angles to read from serial port
PVector EULER = new PVector();
// light reading from photo sensor
float LIGHT = 1023;
// length of buffer that will log sound data
int SOUND_BUFFER_SIZE = 1280;
// buffer logging sound readings from microphone
float[] SOUND_BUFFER = new float[SOUND_BUFFER_SIZE];
// standard deviation (from average) of sound buffer
float SOUND_DEVIATION = 0;
// left button reading
boolean BTN_L = false;
// right button reading
boolean BTN_R = false;
// time of most recent serial event
float LAST_SERIAL_EVENT = 0;


// using keyboard controls or serial controls?
boolean USING_SERIAL = false;


//------------------------------------------------------------------------
//------------------------------------------------------------------------


void setup() {
  // full screen the window and enable 3d graphics
  size(displayWidth, displayHeight, P3D);
  
  // set the clipping plane farther away                          // dirty
  float z = (height / 2.0) / tan(PI * 30.0 / 180.0);
  perspective(PI / 3.0, float(width) / float(height), z / 10.0, z * 300);
  
  if (USING_SERIAL) {
    // open serial port at 115200 baud
    PORT = new Serial(this, "/dev/tty.usbmodem1421", 115200);
    // only trigger serial events when newline is recieved
    PORT.bufferUntil('\n');
    // send character to arduino to indicate ready
    PORT.write('r');
  }
  
  // initialize positions and velocities of boxes
  float s = 20;                                                    // dirty
  
  for (int i = 0; i < NUM_SHOWN; i++) {
    POSITIONS[i] = new PVector(random(H_F_S - s, H_F_S + s), 
                               random(H_F_S - s, H_F_S + s), 
                               random(H_F_S - s, H_F_S + s));
    VELOCITIES[i] = PVector.mult(PVector.random3D(), 2);
  }
  
  for (int i = 0; i < NUM_STARS; i++) {
    STAR_POSITIONS[i] = PVector.mult(PVector.random3D(), ARENA_SIZE);
    STAR_VELOCITIES[i] = PVector.mult(PVector.random2D(), 1000);
  }
  
  // randomize the field and boards
//  FIELD.blank();
//  FIELD.c_to_c(color(255), 0, 0, 0);
//  FIELD.c_to_c(color(255, 0, 0), 1, 0, 0);
//  FIELD.c_to_c(color(0, 255, 0), 0, 1, 0);
//  FIELD.c_to_c(color(0, 0, 255), 0, 0, 1);
//  FIELD.c_to_c(random_color(), -1, -1, 1);
//  FIELD.c_to_c(random_color(), -1, 1, -1);

  FIELD.color_randomize();
  LIFE.randomize();

  noStroke();
  textMode(SHAPE);
}


void draw() {
  // if using serial controls and it has been over a second since last serial event
  if (USING_SERIAL & (millis() - LAST_SERIAL_EVENT > 1000)) {
    // resend command to initialize
    PORT.write('r');
    // set last event time to now
    LAST_SERIAL_EVENT = millis();
    // log status
    println("Disconnected. Attempting to re-connect.  Time: " + str(LAST_SERIAL_EVENT));
  }
  
  // update camera vectors based on input
  if (USING_SERIAL)
    handle_controls();
    
  handle_keys();
    
  // update actual camera based on camera vectors
  set_camera();
  
  // clear the background
  background(BACKGROUND);
  
  // set up the lighting
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  
  spotLight(red(SPOT_LIGHT), green(SPOT_LIGHT), blue(SPOT_LIGHT), // color 
            CAMERA_EYE.x   , CAMERA_EYE.y     , CAMERA_EYE.z    , // position
            look.x         , look.y           , look.z          , // direction
            map(LIGHT, 0, 1023, PI / 8, PI / 4),                  // cone angle
            map(LIGHT, 0, 1023, 40, 1));                          // concentration

  ambientLight(map(LIGHT, 0, 1023, 20, 0), 
               map(LIGHT, 0, 1023, 0, 20), 
               map(LIGHT, 0, 1023, 20, 0));
  
  // render the content
  render_axes();
  render_stars();
  render_life();
  //render_boxes();
  render_soundbox();
  render_soundwave();
  if (P_DOWN)
    render_data();

  // iterate the content
  LIFE_PERIOD.set_modulus(int(map(mouseX, 0, width, 1, 20)));
  
  if (LIFE_PERIOD.is_zero())
    LIFE.iterate();
    
  LIFE_PERIOD.inc();
  FIELD.iterate(map(mouseX, 0, width , 0, 2), // k_color
                map(mouseY, 0, height, 0, 2), // k_space
                0.03);                        // k_growth
  //iterate_boxes();
  iterate_stars();
  
  T += DT;
}


//------------------------------------------------------------------------
//------------------------------------------------------------------------


void serialEvent(Serial port) {
  LAST_SERIAL_EVENT = millis();

  String in_string = port.readString();
  String[] in_array = split(in_string, ',');
  
  in_array = trim(in_array);
  
  if (in_array.length != 7)
    println("Unrecognized Serial Data: " + in_string);
  else {
    // if first serial event ever then record initial values
    if (LAST_SERIAL_EVENT == 0) {
      INIT_EULER.x = float(in_array[0]);
      INIT_EULER.y = float(in_array[1]);
      INIT_EULER.z = float(in_array[2]);
    }
    
    // angle about MPU z axis
    EULER.x = float(in_array[0]);
    // angle about MPU y axis
    EULER.y = float(in_array[1]);
    // angle about MPU x axis
    EULER.z = float(in_array[2]);
    
    // light reading from photo sensor
    LIGHT = float(in_array[3]);
    
    // sound reading from microphone
    SOUND_BUFFER = shift_float_list(SOUND_BUFFER);
    SOUND_BUFFER[SOUND_BUFFER.length - 1] = float(in_array[4]);
    SOUND_DEVIATION = float_list_deviation(SOUND_BUFFER);
    
    // left button reading
    BTN_L = boolean(int(in_array[5]));
    // right button reading
    BTN_R = boolean(int(in_array[6]));
  }
}


