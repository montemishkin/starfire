/* How to wire up the Arduino (other than obvious power connections):
 *   Arduino Pin    Sensor Pin
 *     A5             MPU-SCL
 *     A4             MPU-SDA
 *     D2             MPU-INT
 *
 *     D0 (RX)        BLU-TX
 *     D1 (TX)        BLU-RX
 *
 *     A0             PHOTO
 *
 *     D5             BTN-L
 *     D7             BTN-R
 *
 */


#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
#include "Wire.h"


// uncomment to see actual quaternion components 
// in [w, x, y, z] format (not best for parsing on remote host like Processing)
//#define OUTPUT_READABLE_QUATERNION

// uncomment to see Euler angles (in degrees)
// calculated from quaternions coming from FIFO.
#define OUTPUT_READABLE_EULER

// uncomment to see yaw/pitch/roll angles (in degrees)
// calculated from quaternions coming from FIFO.
// Note this also requires gravity vector calculations.
//#define OUTPUT_READABLE_YAWPITCHROLL

// uncomment to see acceleration components with gravity removed. 
// This acceleration reference frame is not compensated for orientation, 
// so +X is always +X according to the sensor, just without the effects of gravity.
// use OUTPUT_READABLE_WORLDACCEL to get acceleration compensated for orientation.
//#define OUTPUT_READABLE_REALACCEL

// uncomment to see acceleration components with gravity removed 
// and adjusted for the world frame of reference 
// (yaw is relative to initial orientation, since no magnetometer).
//#define OUTPUT_READABLE_WORLDACCEL

// uncomment for output that matches format used for InvenSense teapot demo
//#define OUTPUT_TEAPOT

// uncomment to use bluetooth
//#define USING_BLUETOOTH


#define LED_PIN 13
#define PHOTO_PIN A0
#define BTN_R_PIN 7
#define BTN_L_PIN 5


// orientation/motion vars
//-----------------------------------------------------------------------
// [w, x, y, z] quaternion container
Quaternion q;
// [x, y, z] accel sensor measurements
VectorInt16 aa;
// [x, y, z] gravity-free accel sensor measurements
VectorInt16 aaReal;
// [x, y, z] world-frame accel sensor measurements
VectorInt16 aaWorld;
// [x, y, z] gravity vector
VectorFloat gravity;
// [psi, theta, phi] Euler angle container
float euler[3];
// [yaw, pitch, roll] yaw/pitch/roll container and gravity vector
float ypr[3];
// packet structure for InvenSense teapot demo
uint8_t teapotPacket[14] = {
  '$', 0x02, 0, 0, 0, 0, 0, 0, 0, 0, 0x00, 0x00, '\r', '\n'
};
// light sensor reading
float photo = 1024;
// left button reading
bool btn_l = false;
// right button reading
bool btn_r = false;
// blink state of LED for indicating status
bool blinkState = false;



// MPU control/status vars
//-----------------------------------------------------------------------
// the actual MPU
MPU6050 mpu;
// set true if DMP init was successful
bool dmpReady = false;
// holds actual interrupt status byte from MPU
uint8_t mpuIntStatus;
// return status after each device operation (0 = success, !0 = error)
uint8_t devStatus;
// expected DMP packet size (default is 42 bytes)
uint16_t packetSize;
// count of all bytes currently in FIFO
uint16_t fifoCount;
// FIFO storage buffer
uint8_t fifoBuffer[64];


// ================================================================
// ===               INTERRUPT DETECTION ROUTINE                ===
// ================================================================

// indicates whether MPU interrupt pin has gone high
volatile bool mpuInterrupt = false;
void dmpDataReady() {
  mpuInterrupt = true;
}


// ================================================================
// ===                      INITIAL SETUP                       ===
// ================================================================

void setup() {
  // join I2C bus (I2Cdev library doesn't do this automatically)
  Wire.begin();
  TWBR = 24; // 400kHz I2C clock (200kHz if CPU is 8MHz)
  
  #ifdef USING_BLUETOOTH
    // Begin at bluetooth modem's default baud 9600
    Serial.begin(9600);
    // Enter command mode
    Serial.print("$");
    Serial.print("$");
    Serial.print("$");
    // Short delay, wait for the Mate to send back CMD
    delay(100);
    // Change to 115200 baud
    Serial.println("U,115200,N");
  #else
    Serial.begin(115200);
  #endif

  // initialize device
  Serial.println(F("Initializing I2C devices..."));
  mpu.initialize();

  // verify connection
  Serial.println(F("Testing device connections..."));
  Serial.println(mpu.testConnection() ? 
    F("MPU6050 connection successful") : F("MPU6050 connection failed"));

  // wait for ready
  Serial.println(F("\nSend any character to begin DMP programming and demo: "));
  // empty buffer
  while (Serial.available () && Serial.read());
  // wait for data
  while (!Serial.available ());
  // empty buffer again
  while (Serial.available () && Serial.read());

  // load and configure the DMP
  Serial.println(F("Initializing DMP..."));
  devStatus = mpu.dmpInitialize();

  // supply your own gyro offsets here, scaled for min sensitivity
//  mpu.setXGyroOffset(220);
//  mpu.setYGyroOffset(76);
//  mpu.setZGyroOffset(-85);
//  mpu.setZAccelOffset(1788); // 1688 factory default for my test chip

  // make sure it worked (returns 0 if so)
  if (devStatus == 0) {
    // turn on the DMP, now that it's ready
    Serial.println(F("Enabling DMP..."));
    mpu.setDMPEnabled(true);

    // enable Arduino interrupt detection
    Serial.println(
      F("Enabling interrupt detection (Arduino external interrupt 0)..."));
    attachInterrupt(0, dmpDataReady, RISING);
    mpuIntStatus = mpu.getIntStatus();

    // set our DMP Ready flag so the main loop() function knows 
    //   it's okay to use it
    Serial.println(F("DMP ready! Waiting for first interrupt..."));
    dmpReady = true;

    // get expected DMP packet size for later comparison
    packetSize = mpu.dmpGetFIFOPacketSize();
  } else {
    // ERROR!
    // 1 = initial memory load failed
    // 2 = DMP configuration updates failed
    // (if it's going to break, usually the code will be 1)
    Serial.print(F("DMP Initialization failed (code "));
    Serial.print(devStatus);
    Serial.println(F(")"));
  }

  // configure LED for output
  pinMode(LED_PIN, OUTPUT);
}



// ================================================================
// ===                    MAIN PROGRAM LOOP                     ===
// ================================================================

void loop() {
  // if setup failed, don't try to do anything
  if (!dmpReady) return;

  // wait for MPU interrupt or extra packet(s) available
  while (!mpuInterrupt && fifoCount < packetSize) {
    // other program behavior stuff here
    //   if you are really paranoid you can frequently test in between other
    //   stuff to see if mpuInterrupt is true, and if so, "break;" from the
    //   while() loop to immediately process the MPU data

    photo = analogRead(PHOTO_PIN);
    btn_l = (digitalRead(BTN_L_PIN) == HIGH);
    btn_r = (digitalRead(BTN_R_PIN) == HIGH);
  }

  // reset interrupt flag and get INT_STATUS byte
  mpuInterrupt = false;
  mpuIntStatus = mpu.getIntStatus();

  // get current FIFO count
  fifoCount = mpu.getFIFOCount();

  // check for overflow (should never happen unless code is inefficient)
  if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
    // reset so we can continue cleanly
    mpu.resetFIFO();
    Serial.println(F("FIFO overflow!"));

    // otherwise, check for DMP data ready interrupt 
    //  (this should happen frequently)
  } else if (mpuIntStatus & 0x02) {
    // wait for correct available data length, should be a VERY short wait
    while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();

    // read a packet from FIFO
    mpu.getFIFOBytes(fifoBuffer, packetSize);

    // track FIFO count here in case there is > 1 packet available
    // (this lets us immediately read more without waiting for interrupt)
    fifoCount -= packetSize;

    #ifdef OUTPUT_READABLE_QUATERNION
      // display quaternion values in easy matrix form: w x y z
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      Serial.print(q.w);
      Serial.print(",");
      Serial.print(q.x);
      Serial.print(",");
      Serial.print(q.y);
      Serial.print(",");
      Serial.print(q.z);
    #endif

    #ifdef OUTPUT_READABLE_EULER
      // display Euler angles in degrees
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      mpu.dmpGetEuler(euler, &q);
      Serial.print(euler[0] * 180/M_PI);
      Serial.print(",");
      Serial.print(euler[1] * 180/M_PI);
      Serial.print(",");
      Serial.print(euler[2] * 180/M_PI);
    #endif

    #ifdef OUTPUT_READABLE_YAWPITCHROLL
      // display Euler angles in degrees
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      mpu.dmpGetGravity(&gravity, &q);
      mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);
      Serial.print(ypr[0] * 180/M_PI);
      Serial.print(",");
      Serial.print(ypr[1] * 180/M_PI);
      Serial.print(",");
      Serial.print(ypr[2] * 180/M_PI);
    #endif

    #ifdef OUTPUT_READABLE_REALACCEL
      // display real acceleration, adjusted to remove gravity
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      mpu.dmpGetAccel(&aa, fifoBuffer);
      mpu.dmpGetGravity(&gravity, &q);
      mpu.dmpGetLinearAccel(&aaReal, &aa, &gravity);
      Serial.print(aaReal.x);
      Serial.print(",");
      Serial.print(aaReal.y);
      Serial.print(",");
      Serial.print(aaReal.z);
    #endif

    #ifdef OUTPUT_READABLE_WORLDACCEL
      // display initial world-frame acceleration, adjusted to remove gravity
      // and rotated based on known orientation from quaternion
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      mpu.dmpGetAccel(&aa, fifoBuffer);
      mpu.dmpGetGravity(&gravity, &q);
      mpu.dmpGetLinearAccel(&aaReal, &aa, &gravity);
      mpu.dmpGetLinearAccelInWorld(&aaWorld, &aaReal, &q);
      Serial.print(aaWorld.x);
      Serial.print(",");
      Serial.print(aaWorld.y);
      Serial.print(",");
      Serial.print(aaWorld.z);
    #endif

    #ifdef OUTPUT_TEAPOT
      // display quaternion values in InvenSense Teapot demo format:
      teapotPacket[2] = fifoBuffer[0];
      teapotPacket[3] = fifoBuffer[1];
      teapotPacket[4] = fifoBuffer[4];
      teapotPacket[5] = fifoBuffer[5];
      teapotPacket[6] = fifoBuffer[8];
      teapotPacket[7] = fifoBuffer[9];
      teapotPacket[8] = fifoBuffer[12];
      teapotPacket[9] = fifoBuffer[13];
      Serial.write(teapotPacket, 14);
      // packetCount, loops at 0xFF on purpose
      teapotPacket[11]++;
    #endif

    Serial.print(",");                    // problematic if using teapot output!
    Serial.print(photo);
    Serial.print(",");
    Serial.print(btn_l);
    Serial.print(",");
    Serial.print(btn_r);
    Serial.println();

    // blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
  }
}


