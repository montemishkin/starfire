/* Notes:
 *
 */


void loop() {
  // if setup failed, don't try to do anything
  if (!dmp_ready) return;

  // wait for MPU interrupt or extra packet(s) available
  while (!mpu_interrupt && fifo_count < packet_size) {
    // read from other (non interrupt) sensors
    light = analogRead(LIGHT_PIN);
    sound = analogRead(MIC_PIN);
    btn_l = (digitalRead(BTN_L_PIN) == HIGH);
    btn_r = (digitalRead(BTN_R_PIN) == HIGH);
    sw    = (digitalRead(SW_PIN) == HIGH);
  }

  // reset interrupt flag and get INT_STATUS byte
  mpu_interrupt = false;
  mpu_int_status = mpu.getIntStatus();

  // get current FIFO count
  fifo_count = mpu.getFIFOCount();

  // check for overflow (should never happen unless code is inefficient)
  if ((mpu_int_status & 0x10) || fifo_count == 1024) {
    // reset so we can continue cleanly
    mpu.resetFIFO();
    Serial.println(F("FIFO overflow!"));

    // otherwise, check for DMP data ready interrupt 
    //  (this should happen frequently)
  } else if (mpu_int_status & 0x02) {
    // wait for correct available data length, should be a very short wait
    while (fifo_count < packet_size) fifo_count = mpu.getFIFOCount();

    // read a packet from FIFO
    mpu.getFIFOBytes(fifo_buffer, packet_size);

    // track FIFO count here in case there is > 1 packet available
    // (this lets us immediately read more without waiting for interrupt)
    fifo_count -= packet_size;

    // calculate motion
    mpu.dmpGetQuaternion(&q, fifo_buffer);
    mpu.dmpGetGravity(&g, &q);
    mpu.dmpGetYawPitchRoll(ypr, &q, &g);
    
    // write yaw, pitch, roll angles in degrees
    Serial.print(ypr[0] * 180/M_PI);
    Serial.print(",");
    Serial.print(ypr[1] * 180/M_PI);
    Serial.print(",");
    Serial.print(ypr[2] * 180/M_PI);

    // write other sensor and button readings
    Serial.print(",");
    Serial.print(light);
    Serial.print(",");
    Serial.print(sound);
    Serial.print(",");
    Serial.print(btn_l);
    Serial.print(",");
    Serial.print(btn_r);
    Serial.print(",");
    Serial.print(sw);
    Serial.println();

    // blink LED to indicate activity
    blink_state = !blink_state;
    digitalWrite(LED_PIN, blink_state);
  }
}


