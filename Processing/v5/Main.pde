/* Notes:
 *
 */


void setup() {
  // full screen the window and enable 3d graphics
  size(displayWidth, displayHeight, P3D);
  // hide the mouse
  noCursor();
  // any text that is drawn should be big
  textSize(20);
  
  // set the clipping plane far away
  float z = (height / 2.0) / tan(PI * 30.0 / 180.0);
  perspective(PI / 3.0, float(width) / float(height), z / 10.0, z * 300);
  
  // open serial port at 115200 baud
  PORT = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  // only trigger serial events when newline is recieved
  PORT.bufferUntil('\n');
  // clear the port
  while (PORT.available() > 0)
    PORT.readString();
  // send character to arduino to indicate ready
  PORT.write('r');
 
  // initialize all simulation variables
  FIELD.randomize();
  LIFE.randomize();
  for (int i = 0; i < MAX_N_BLOCKS; i++)
    BLOCKS[i] = new PVector(random(-H_A_S, H_A_S), 
                            random(-H_A_S, H_A_S), 
                            random(-H_A_S, H_A_S));
  for (int i = 0; i < N_STARS; i++)
    STARS[i] = PVector.mult(PVector.random3D(), ARENA_SIZE);
}


void draw() {
  // if has been over a second since last serial event
  if (millis() - LAST_SERIAL_TIME > 1000) {
    // resend command to initialize
    PORT.write('r');
    // set last event time to now
    LAST_SERIAL_TIME = millis();
    // log status
    CONSOLE += ">>> Disconnected. Attempting to re-connect.  Time: " 
                                      + str(LAST_SERIAL_TIME) + "\n";
  }
  
  // if haven't yet received valid data packet
  if (!SERIAL_BEGUN) {
    // log the console to the display
    background(20, 20, 200);
    fill(255);
    text(CONSOLE, 20, height - (30 * split(CONSOLE, '\n').length));
    
    // exit the draw loop early
    return;
  }
  
//  if (BTN_L && BTN_R){ 
//    render_data();
//    
//    return;
//  }
  
  // update camera vectors based on input
  handle_controls();
  // update actual camera based on camera vectors
  set_camera();
  
  // update global vars based on serial data
  if (SERIAL_READY)
    update_globals();
  
  // clear the background
  noStroke();
  fill(BACKGROUND, OPACITY);
  box(10 * ARENA_SIZE);
  
  // set the lighting
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
  render_life();
  render_soundwave();
  render_iterate_blocks();
  render_iterate_stars();

  // iterate the content
  if (LIFE_PERIOD.is_zero())
    LIFE.iterate();
  
  PVector in = PVector.sub(INIT_EULER, EULER);
  FIELD.iterate(map(in.z, -180, 180, 0, 2), // k_color
                map(in.x, -180, 180, 0, 2), // k_space
                0.03);                      // k_growth
  
  // increment time
  T += DT;
  LIFE_PERIOD.inc();
}


// triggered by serial port having received a '\n'
void serialEvent(Serial port) {
  LAST_SERIAL_TIME = millis();
  
  String in_string = port.readString();
  String[] in_array = split(in_string, ',');
  
  in_array = trim(in_array);
  
  if (in_array.length != 7)
    CONSOLE += ">>> Non data-packet string received: " + in_string;
  else {
    // if first serial event ever then record initial angles
    if (!SERIAL_BEGUN) {
      INIT_EULER.x = float(in_array[0]);
      INIT_EULER.y = float(in_array[1]);
      INIT_EULER.z = float(in_array[2]);
      
      SERIAL_BEGUN = true;
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
    // sound reading from microphone
    SOUND.push(float(in_array[4]));
    
    // left button reading
    BTN_L = boolean(int(in_array[5]));
    // right button reading
    BTN_R = boolean(int(in_array[6]));
  }
}


// update global variables based on serial data
void update_globals() {
  SERIAL_READY = false;
  
  //LIGHT.update();
  //SOUND.update();
  
  float l = LIGHT.get_last();
  
  N_BLOCKS = int(map(l, 0, 1023, MAX_N_BLOCKS, 0));
  OPACITY = map(l, 0, 1023, 0, 255);
  SPOT_LIGHT_ANGLE = map(l, 0, 1023, PI / 8, PI / 4);
  SPOT_LIGHT_CONCENTRATION = map(l, 0, 1023, 40, 3);
  AMB_LIGHT = color(map(l, 0, 1023, 20, 0), 
                    map(l, 0, 1023, 0, 20), 
                    map(l, 0, 1023, 20, 0));
  
  //LIFE_PERIOD.set_modulus(int(map(LIGHT.get_dev(), 0, 1023, 20, 1)));
}


