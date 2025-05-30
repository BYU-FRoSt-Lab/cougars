/**
 * @author Nelson Durrant
 * @date September 2024
 *
 * Simple namespace declaration for micro-ROS.
 * - When setting up a new vehicle, do not directly edit the file in
 *   'templates'; rather the copied file generated by 'setup.sh' in 'config'
 * - If you edit this file, you'll need to make sure the copied file in 'config'
 *   is updated as well
 */

#define NAMESPACE "coug0" // ex. "coug0"
// #define PRESSURE_30M   // COUG1 has 30m depth pressure sensor (Comment out one you don't need)
#define PRESSURE_10M      // COUG2 has 10m depth pressure sensor
#define SERVO_OUT_HIGH 2000 // check servo ratings for pwm microsecond values
#define SERVO_OUT_LOW 1000 // COUG1 is 500-2500 COUG2 is 1000-2000
#define VOLT_PIN 27   //pins on the teensy for the battery monitor
#define CURRENT_PIN 22   //pins on the teensy for the battery monitor
#define LEAK_PIN 26       //pins on the teensy for the leak sensor
