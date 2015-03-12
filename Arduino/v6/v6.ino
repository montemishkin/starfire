/* How to wire up the Arduino (other than obvious power connections):
 *   Arduino Pin    Sensor Pin
 *     A5             MPU-SCL
 *     A4             MPU-SDA
 *     D2             MPU-INT
 *
 *     D0 (RX)        BLU-TX
 *     D1 (TX)        BLU-RX
 *
 *     A0             LIGHT
 *
 *     D5             BTN-L
 *     D7             BTN-R
 *
 *     A2             MIC
 *
 */


// import libraries
#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
#include "Wire.h"


// set pin numbers
#define LED_PIN   13
#define LIGHT_PIN A0
#define MIC_PIN   A2
#define BTN_R_PIN 7
#define BTN_L_PIN 5


// Sensor Variables
//---------------------------------------------------------------------
// [w, x, y, z] quaternion container
Quaternion q;
// [x, y, z] gravity vector
VectorFloat g;
// [yaw, pitch, roll] yaw, pitch, roll container
float ypr[3];

// light sensor reading
float light = 1023;
// microphone reading
float sound = 0;
// left button reading
bool btn_l = false;
// right button reading
bool btn_r = false;
// blink state of LED for indicating status
bool blink_state = false;


// MPU control/status variables
//---------------------------------------------------------------------
// the actual MPU
MPU6050 mpu;
// set true if DMP init was successful
bool dmp_ready = false;
// holds actual interrupt status byte from MPU
uint8_t mpu_int_status;
// return status after each device operation (0 = success, !0 = error)
uint8_t dev_status;
// expected DMP packet size (default is 42 bytes)
uint16_t packet_size;
// count of all bytes currently in FIFO
uint16_t fifo_count;
// FIFO storage buffer
uint8_t fifo_buffer[64];
// indicates whether MPU interrupt pin has gone high
volatile bool mpu_interrupt = false;


// Interrupt Detection Scheme
//---------------------------------------------------------------------
void dmp_data_ready() {
  mpu_interrupt = true;
}


