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
Counter LIFE_PERIOD = new Counter();   // CURRENTLY UNSUPPORTED BY SERIAL CONTROLS


// width of available arena (in pixels)
int ARENA_SIZE = 10000;
// width of color field (in pixels)
int FIELD_SIZE = ARENA_SIZE / 5;
// width of color field (number of cells per edge)
int FIELD_WIDTH = 40;
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
// number of boxes shown
int NUM_SHOWN = 10000;
// number of stars
int NUM_STARS = 2000;


// the actual life boards
Life LIFE_1 = new Life(4 * LIFE_WIDTH, LIFE_WIDTH);
Life LIFE_2 = new Life(4 * LIFE_WIDTH, LIFE_WIDTH);
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
PVector CAMERA_CENTER = new PVector(0, 0, 0);
// direction of "down"
PVector CAMERA_AXIS   = new PVector(0, -1, 0);


// serial port to read from
Serial PORT;
// euler angles to read from serial port
float[] EULERS = new float[3];
// light reading from photo sensor
float LIGHT = 1024;
// time of most recent serial event
float LAST_SERIAL_EVENT = 0;


// using keyboard controls or serial controls?
boolean KEY_CONTROLS = false;


//------------------------------------------------------------------------
//------------------------------------------------------------------------


void setup() {
  // full screen the window and enable 3d graphics
  size(displayWidth, displayHeight, P3D);
  
  // set the clipping plane farther away                          // ???????????
  float z = (height / 2.0) / tan(PI * 30.0 / 180.0);
  perspective(PI / 3.0, float(width) / float(height), z / 10.0, z * 30);
  
  if (!KEY_CONTROLS) {
    // open serial port at 115200 baud
    PORT = new Serial(this, "/dev/tty.usbmodem1421", 115200);
    // only trigger serial events when newline is recieved
    PORT.bufferUntil('\n');
    // send character to arduino to indicate ready
    PORT.write('r');
  }
  
  // initialize positions and velocities of boxes
  float hfw = FIELD_SIZE / 2;                                // dirty
  float s = 20;
  
  for (int i = 0; i < NUM_SHOWN; i++) {
    POSITIONS[i] = new PVector(random(hfw - s, hfw + s), 
                               random(hfw - s, hfw + s), 
                               random(hfw - s, hfw + s));
    VELOCITIES[i] = PVector.mult(PVector.random3D(), 2);
  }
  
  for (int i = 0; i < NUM_STARS; i++) {
    STAR_POSITIONS[i] = PVector.mult(PVector.random3D(), ARENA_SIZE);
    STAR_VELOCITIES[i] = PVector.mult(PVector.random2D(), 1000);
  }
  
  // randomize the field and boards
  FIELD.color_randomize();
  LIFE_1.randomize();
  LIFE_2.randomize();

  noStroke();
}


void draw() {  
  // if using serial controls and it has been over a second since last serial event
  if (!KEY_CONTROLS & (millis() - LAST_SERIAL_EVENT > 1000)) {
    // resend command to initialize
    PORT.write('r');
    // set last event time to now
    LAST_SERIAL_EVENT = millis();
    // log status
    println("Disconnected. Attempting to re-connect.  Time: " + str(LAST_SERIAL_EVENT));
  }
  
  // update camera vectors based on input
  if (KEY_CONTROLS)
    handle_keys();
  else
    handle_controls();
    
  // update actual camera based on camera vectors
  set_camera();
  
  // clear the background
  background(BACKGROUND);   
  
  // set up the lighting
  PVector look = PVector.sub(CAMERA_CENTER, CAMERA_EYE);
  
  spotLight(red(SPOT_LIGHT), green(SPOT_LIGHT), blue(SPOT_LIGHT), // color 
            CAMERA_EYE.x   , CAMERA_EYE.y     , CAMERA_EYE.z    , // position
            look.x         , look.y           , look.z          , // direction
            PI / 4,                                               // cone angle
            map(LIGHT, 0, 1024, 40, 1));                                                   // concentration
  // map the cone angle    between small and around PI/4
  // map the concentration between small and around 40

  ambientLight(20, 20, 40);
  
  // render the content
  render_axes_labels();
  render_stars();
  render_life();
  render_boxes();
  
  // iterate the content
  LIFE_PERIOD.set_modulus(int(map(mouseX, 0, width, 1, 10)));
  
  if (LIFE_PERIOD.is_zero()) {
    LIFE_1.iterate();
    //LIFE_2.iterate();
  }
    
  LIFE_PERIOD.inc();
  FIELD.iterate(map(mouseX, 0, width , 0, 2), // k_color
                map(mouseY, 0, height, 0, 2), // k_space
                0.03);                        // k_growth
  iterate_boxes();
  iterate_stars();
  
  T += DT;
}


//------------------------------------------------------------------------
//------------------------------------------------------------------------


void serialEvent(Serial port) {
  LAST_SERIAL_EVENT = millis();

  String in_string = port.readString();
  String[] in_array = split(in_string, ',');
  
  if (in_array.length == 4) {
    // angle about MPU z axis
    EULERS[0] = float(in_array[0]);
    // angle about MPU y axis
    EULERS[1] = float(in_array[1]);
    // angle about MPU x axis
    EULERS[2] = float(in_array[2]);
    // light reading from photo sensor
    LIGHT = float(in_array[3]);
  } else {
    println("Unrecognized Serial Data: " + in_string);
  }
}


