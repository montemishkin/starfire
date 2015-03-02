/* Notes:
 *   check out this solution to smoothing analog readings:
 *     http://arduino.cc/en/Tutorial/Smoothing
 *
 */
  

import processing.serial.*;


// background opacity
float OPACITY = 20;
// background color
color BACKGROUND = color(0);
// ambient light color
color AMB_LIGHT = color(0);
// spot light color
color SPOT_LIGHT = color(255);
// spot light cone angle
float SPOT_LIGHT_ANGLE = PI / 4;
// spot light concentration
float SPOT_LIGHT_CONCENTRATION = 1;


// global time counter
float T = 0;
// global time step
float DT = 0.1;
// counter for life iteration timing
Counter LIFE_PERIOD = new Counter();


// width of available arena (in pixels)
int ARENA_SIZE = 10000;
// width of color field (number of cells per edge)
int FIELD_WIDTH = 100;
// number of life board cells per wall edge
int LIFE_WIDTH = 50;
// width of a cell within the color field (in pixels)
int FIELD_CELL_SIZE = ARENA_SIZE / FIELD_WIDTH;
// width of a cell within the life board (in pixels)
int LIFE_CELL_SIZE = ARENA_SIZE / LIFE_WIDTH;
// thickness of a cell within the life board (in pixels)
int LIFE_CELL_THICK = 40;
// half of the arena size (in pixels)
int H_A_S = ARENA_SIZE / 2;
// max number of dots
int MAX_NUM_DOTS = 1000;
// number of dots shown
int NUM_DOTS = 1000;
// number of stars
int NUM_STARS = 10000;


// the actual life board
Life LIFE = new Life(LIFE_WIDTH, LIFE_WIDTH);
// the actual color field 
Field FIELD = new Field(FIELD_WIDTH, FIELD_WIDTH);
// positions of dots (in pixels)
PVector[] DOT_POSITIONS = new PVector[MAX_NUM_DOTS];
// colors of dots
color[] DOT_COLORS = new color[MAX_NUM_DOTS];
// positions of the stars (in pixels)
PVector[] STAR_POSITIONS = new PVector[NUM_STARS];
// velocities of the stars (in pixels)
PVector[] STAR_VELOCITIES = new PVector[NUM_STARS];


// position of the eye (in pixels)
PVector CAMERA_EYE = new PVector(0, 0, -2 * ARENA_SIZE);
// position of the scene center (in pixels)
PVector CAMERA_CENTER = new PVector();
// direction of "down"
PVector CAMERA_AXIS = new PVector(0, -1, 0);


// serial port to read from
Serial PORT;
// time of most recent serial event
float LAST_SERIAL_TIME = 0;
// if there has been a serial event since last update of global variables
boolean SERIAL_READY = false;
// the initial euler angles to compare to
PVector INIT_EULER = new PVector();
// euler angles to read from serial port
PVector EULER = new PVector();
// light reading from photo sensor
FloatBuffer LIGHT = new FloatBuffer(100);
// buffer logging sound readings from microphone
FloatBuffer SOUND = new FloatBuffer(1000);
// left button reading
boolean BTN_L = false;
// right button reading
boolean BTN_R = false;


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
  } else {
    // set light buffer to HIGH so that you can see
    LIGHT.set_all(1023);
  }
 
  // initialize dots
  for (int i = 0; i < MAX_NUM_DOTS; i++) {
    DOT_POSITIONS[i] = new PVector(random(-H_A_S, H_A_S), 
                                   random(-H_A_S, H_A_S), 
                                   random(-H_A_S, H_A_S));
    DOT_COLORS[i] = color(random(255), random(255), random(255));
  }
  
  // initialize stars
  for (int i = 0; i < NUM_STARS; i++) {
    STAR_POSITIONS[i] = PVector.mult(PVector.random3D(), ARENA_SIZE);
    STAR_VELOCITIES[i] = PVector.mult(PVector.random2D(), 1000);
  }
  
  // randomize the boards
  FIELD.randomize();
  LIFE.randomize();

  noStroke();
  textMode(SHAPE);
}


void draw() {
  // if using serial controls and it has been over a second since last serial event
  if (USING_SERIAL & (millis() - LAST_SERIAL_TIME > 1000)) {
    // resend command to initialize
    PORT.write('r');
    // set last event time to now
    LAST_SERIAL_TIME = millis();
    // log status
    println("Disconnected. Attempting to re-connect.  Time: " + str(LAST_SERIAL_TIME));
  }
  
  // update camera vectors based on input
  if (USING_SERIAL)
    handle_controls();
  handle_keys();
  
  // update global vars based on serial data
  if (SERIAL_READY)
    update_globals();
    
  // update actual camera based on camera vectors
  set_camera();
  
  OPACITY = map(mouseX, 0, width, 0, 255);
  
  // clear the background
  noStroke();
  fill(BACKGROUND, OPACITY);
  box(10 * ARENA_SIZE);
  
  // set up the lighting
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE).normalize(null);
  spotLight(red(SPOT_LIGHT), green(SPOT_LIGHT), blue(SPOT_LIGHT), // color 
            CAMERA_EYE.x   , CAMERA_EYE.y     , CAMERA_EYE.z    , // position
            look.x         , look.y           , look.z          , // direction
            SPOT_LIGHT_ANGLE,                                     // cone angle
            SPOT_LIGHT_CONCENTRATION);                            // concentration
  ambientLight(AMB_LIGHT >> 16 & 0xFF,
               AMB_LIGHT >>  8 & 0xFF,
               AMB_LIGHT >>      0xFF); 
  
  // render the content
  render_field();
  render_iterate_dots();
  //render_axes();
  render_stars();
  //render_life();
  //render_soundwave();
  if (P_DOWN)
    render_data();

  // iterate the content
  if (LIFE_PERIOD.is_zero())
    LIFE.iterate();
  iterate_stars();
  FIELD.iterate(map(mouseX, 0, width , 0, 2), // k_color
                map(mouseY, 0, height, 0, 2), // k_space
                0.03,                         // k_growth
                true);                        // is_rand
  
  // increment time
  T += DT;
  LIFE_PERIOD.inc();
}


//------------------------------------------------------------------------
//------------------------------------------------------------------------


void serialEvent(Serial port) {
  LAST_SERIAL_TIME = millis();

  String in_string = port.readString();
  String[] in_array = split(in_string, ',');
  
  in_array = trim(in_array);
  
  if (in_array.length != 7)
    println("Unrecognized Serial Data: " + in_string);
  else {
    // if first serial event ever then record initial angles
    if (LAST_SERIAL_TIME == 0) {
      INIT_EULER.x = float(in_array[0]);
      INIT_EULER.y = float(in_array[1]);
      INIT_EULER.z = float(in_array[2]);
    }
    
    // set flag to update global vars based on serial data
    SERIAL_READY = true;
    
    // angle about MPU z axis
    EULER.x = float(in_array[0]);
    // angle about MPU y axis
    EULER.y = float(in_array[1]);
    // angle about MPU x axis
    EULER.z = float(in_array[2]);
    
    // light reading from photo sensor
    LIGHT.push(float(in_array[3]));
    //LIGHT.update();
    
    // sound reading from microphone
    SOUND.push(float(in_array[4]));
    //SOUND.update();
    
    // left button reading
    BTN_L = boolean(int(in_array[5]));
    // right button reading
    BTN_R = boolean(int(in_array[6]));
  }
}


// update global variables based on serial data
void update_globals() {
  SERIAL_READY = false;
  
  AMB_LIGHT = color(map(LIGHT.get_last(), 0, 1023, 20, 0), 
                    map(LIGHT.get_last(), 0, 1023, 0, 20), 
                    map(LIGHT.get_last(), 0, 1023, 20, 0));
  OPACITY = map(LIGHT.get_last(), 0, 1023, 0, 255);
  SPOT_LIGHT_ANGLE = map(LIGHT.get_last(), 0, 1023, PI / 8, PI / 4);
  SPOT_LIGHT_CONCENTRATION = map(LIGHT.get_last(), 0, 1023, 40, 1);

//  LIFE_PERIOD.set_modulus(int(map(LIGHT.get_dev(), 0, 1023, 20, 1)));
}


