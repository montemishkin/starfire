/* Notes:
 *
 */


import processing.serial.*;


// stores info to log to loading screen
String CONSOLE = "";


// Color and Lighting Variables
//---------------------------------------------------------------------
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


// Timing Variables
//---------------------------------------------------------------------
// global time counter
float T = 0;
// global time step
float DT = 0.1;
// counter for life iteration timing
Counter LIFE_PERIOD = new Counter();


// Sizing Variables
//---------------------------------------------------------------------
// width of available arena (in pixels)
int ARENA_SIZE = 10000;
// width of color field (number of cells per edge)
int FIELD_WIDTH = 100;
// number of life board cells per wall edge
int LIFE_WIDTH = 100;
// width of a cell within the color field (in pixels)
int FIELD_CELL_SIZE = ARENA_SIZE / FIELD_WIDTH;
// thickness of a cell within the color field (in pixels)
int FIELD_CELL_THICK = 40;
// width of a cell within the life board (in pixels)
int LIFE_CELL_SIZE = ARENA_SIZE / LIFE_WIDTH;
// thickness of a cell within the life board (in pixels)
int LIFE_CELL_THICK = 40;
// half of the arena size (in pixels)
int H_A_S = ARENA_SIZE / 2;
// max number of blocks
int MAX_N_BLOCKS = 10000;
// number of blocks shown
int N_BLOCKS = 100;
// size of block (in pixels)
int BLOCK_SIZE = 20;
// number of stars
int N_STARS = 10000;
// size of star (in pixels)
int STAR_SIZE = 20;
// input / how much you actually turn
float ANGLE_SCALE_INV = 1000;  // inverted to avoid truncating
// how much you actually move / input
float TRANS_SCALE = 5;


// Simulation Variables
//---------------------------------------------------------------------
// the actual life board
Life LIFE = new Life(LIFE_WIDTH, LIFE_WIDTH);
// the actual color field 
Field FIELD = new Field(FIELD_WIDTH, FIELD_WIDTH);
// positions of blocks (in pixels)
PVector[] BLOCKS = new PVector[MAX_N_BLOCKS];
// positions of the stars (in pixels)
PVector[] STARS = new PVector[N_STARS];


// Scene Variables
//---------------------------------------------------------------------
// position of the eye (in pixels)
PVector CAMERA_EYE = new PVector(0, 0, -2 * ARENA_SIZE);
// position of the scene center (in pixels)
PVector CAMERA_CENTER = new PVector();
// direction of "down" (LEFT HANDED COORDINATE SYSTEM!)
PVector CAMERA_AXIS = new PVector(0, -1, 0);


// Serial Variables
//---------------------------------------------------------------------
// have we begun recieving valid serial data?
boolean SERIAL_BEGUN = false;
// has there been a serial event since last update of global variables?
boolean SERIAL_READY = false;
// timestamp of most recent serial event
float LAST_SERIAL_TIME = 0;
// serial port to read from
Serial PORT;
// the initial euler angles to compare to
PVector INIT_EULER = new PVector();
// euler angles to read from serial port
PVector EULER = new PVector();
// buffer logging light readings
FloatBuffer LIGHT = new FloatBuffer(100);
// buffer logging sound readings
FloatBuffer SOUND = new FloatBuffer(300);
// left button reading
boolean BTN_L = false;
// right button reading
boolean BTN_R = false;


