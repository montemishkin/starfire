/* Notes:
 *
 */


void setup() {
  // join I2C bus (I2Cdev library doesn't do this automatically)
  Wire.begin();

  // open serial port at 115200 baud
  Serial.begin(115200);

  // initialize mpu device
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
  dev_status = mpu.dmpInitialize();

  // make sure it worked (returns 0 if so)
  if (dev_status == 0) {
    // turn on the DMP, now that it's ready
    Serial.println(F("Enabling DMP..."));
    mpu.setDMPEnabled(true);

    // enable Arduino interrupt detection
    Serial.println(
      F("Enabling interrupt detection (Arduino external interrupt 0)..."));
    attachInterrupt(0, dmp_data_ready, RISING);
    mpu_int_status = mpu.getIntStatus();

    // set our DMP Ready flag so the main loop() function knows 
    //   it's okay to use it
    Serial.println(F("DMP ready! Waiting for first interrupt..."));
    dmp_ready = true;

    // get expected DMP packet size for later comparison
    packet_size = mpu.dmpGetFIFOPacketSize();
  } else {
    // ERROR!
    // 1 = initial memory load failed
    // 2 = DMP configuration updates failed
    // (if it's going to break, usually the code will be 1)
    Serial.print(F("DMP Initialization failed (code "));
    Serial.print(dev_status);
    Serial.println(F(")"));
  }

  // configure LED for output
  pinMode(LED_PIN, OUTPUT);
}


