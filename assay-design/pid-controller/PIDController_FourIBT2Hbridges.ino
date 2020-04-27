#include <PID_v1.h>
#include <Adafruit_MAX31865.h>

//Define pin numbers connected to the RTD sensors
  // Use software SPI: CS, DI, DO, CLK
  Adafruit_MAX31865 sensor1 = Adafruit_MAX31865(22, 23, 24, 25);
  Adafruit_MAX31865 sensor2 = Adafruit_MAX31865(30, 31, 32, 33);
  Adafruit_MAX31865 sensor3 = Adafruit_MAX31865(26, 27, 28, 29);
  Adafruit_MAX31865 sensor4 = Adafruit_MAX31865(34, 35, 36, 37);
  
  // use hardware SPI, just pass in the CS pin
  //Adafruit_MAX31865 max = Adafruit_MAX31865(10);

  // The value of the Rref resistor. Use 430.0 for P100!
  #define RREF 430.0

//Define pin numbers connected to the IBT-2 H-bridges

///Hbridge 1
#define H1_RPWM 6 //PWM output pins
#define H1_LPWM 7
#define H1_R_EN 51 //digital enable pins
#define H1_L_EN 50

///Hbridge 2
#define H2_RPWM 4 //PWM output pins
#define H2_LPWM 5
#define H2_R_EN 45 //digital enable pins
#define H2_L_EN 44

///Hbridge 3
#define H3_RPWM 2 //PWM output pins
#define H3_LPWM 3
#define H3_R_EN 47 //digital enable pins
#define H3_L_EN 46

///Hbridge 4
#define H4_RPWM 8 //PWM output pins
#define H4_LPWM 9
#define H4_R_EN 49 //digital enable pins
#define H4_L_EN 48


//Define Variables we'll be connecting to
///PID 1 parameters
double Setpoint1, Input1, Output1;
double Kp1=300, Ki1=65, Kd1=0;
PID myPID_1(&Input1, &Output1, &Setpoint1,Kp1,Ki1,Kd1,REVERSE);

///PID 2 parameters
double Setpoint2, Input2, Output2;
double Kp2=300, Ki2=90, Kd2=0;
PID myPID_2(&Input2, &Output2, &Setpoint2,Kp2,Ki2,Kd2,REVERSE);

///PID 3 parameters
double Setpoint3, Input3, Output3;
double Kp3=250, Ki3=90, Kd3=0;
PID myPID_3(&Input3, &Output3, &Setpoint3,Kp3,Ki3,Kd3,REVERSE);

///PID 4 parameters
double Setpoint4, Input4, Output4;
double Kp4=250, Ki4=65, Kd4=0;
PID myPID_4(&Input4, &Output4, &Setpoint4,Kp4,Ki4,Kd4,REVERSE);

//timing the serial output
//#define ONEMIN (1000UL * 60 * 0.1) //print every 10 sec
//unsigned long rolltime = millis() + ONEMIN;
float sp[4];
byte writeBuf[2];
float myfloat;

void setup()
{
  Serial.begin(115200);

  //start temperature sensors
  sensor1.begin(MAX31865_3WIRE);  // set to 2WIRE or 4WIRE as necessary
  sensor2.begin(MAX31865_3WIRE);
  sensor3.begin(MAX31865_3WIRE);
  sensor4.begin(MAX31865_3WIRE);

  
  //initialize PID parameters

    Setpoint4=20;
    Setpoint3=20;
    Setpoint2=20;
    Setpoint1=20;
    
  ///PID 1
  Input1 = sensor1.temperature(100, RREF); //initialize the variables we're linked to
  myPID_1.SetOutputLimits(-255, 255); // We can't analogWrite more than 255 to the driver.
 
  pinMode(H1_L_EN, OUTPUT);// Turn the driver on 
  pinMode(H1_R_EN, OUTPUT);
  digitalWrite(H1_R_EN, HIGH);
  digitalWrite(H1_L_EN, HIGH);

  myPID_1.SetMode(AUTOMATIC); //turn the PID on

   ///PID 2
  Input2 = sensor2.temperature(100, RREF); //initialize the variables we're linked to
  myPID_2.SetOutputLimits(-255, 255); // We can't analogWrite more than 255 to the driver.
 
  pinMode(H2_L_EN, OUTPUT);// Turn the driver on 
  pinMode(H2_R_EN, OUTPUT);
  digitalWrite(H2_R_EN, HIGH);
  digitalWrite(H2_L_EN, HIGH);

  myPID_2.SetMode(AUTOMATIC); //turn the PID on

   ///PID 3
  Input3 = sensor3.temperature(100, RREF); //initialize the variables we're linked to
  myPID_3.SetOutputLimits(-255, 255); // We can't analogWrite more than 255 to the driver.
 
  pinMode(H3_L_EN, OUTPUT);// Turn the driver on 
  pinMode(H3_R_EN, OUTPUT);
  digitalWrite(H3_R_EN, HIGH);
  digitalWrite(H3_L_EN, HIGH);

  myPID_3.SetMode(AUTOMATIC); //turn the PID on

   ///PID 4
  Input4 = sensor4.temperature(100, RREF); //initialize the variables we're linked to
  myPID_4.SetOutputLimits(-255, 255); // We can't analogWrite more than 255 to the driver.
 
  pinMode(H4_L_EN, OUTPUT);// Turn the driver on 
  pinMode(H4_R_EN, OUTPUT);
  digitalWrite(H4_R_EN, HIGH);
  digitalWrite(H4_L_EN, HIGH);

  myPID_4.SetMode(AUTOMATIC); //turn the PID on

// set setpoints
   //while(!Serial || Serial.available() <= 0); //wait for serial input to become available
   if(Serial.available() > 0){
     for (int i=0; i<4; i++){
      sp[i]= Serial.parseFloat();
    }
      Setpoint4=sp[0];
      Setpoint3=sp[1];
      Setpoint2=sp[2];
      Setpoint1=sp[3];
  }
}


void loop()
{

  if(Serial.available() > 0){
   for (int i=0; i<4; i++){
    sp[i]= Serial.parseFloat();
  }
    Setpoint4=sp[0];
    Setpoint3=sp[1];
    Setpoint2=sp[2];
    Setpoint1=sp[3];
}

    
  ///PID 1
  Input1 = sensor1.temperature(100, RREF);
  myPID_1.Compute();
  if (Output1 < 0) {
    analogWrite(H1_RPWM,abs(Output1));
    analogWrite(H1_LPWM,0);
  } else if (Output1 > 0) {
    analogWrite(H1_RPWM,0);
    analogWrite(H1_LPWM,abs(Output1));
  } else {
    analogWrite(H1_LPWM,0);
    analogWrite(H1_RPWM,0);
  }

  ///PID 2
  Input2 = sensor2.temperature(100, RREF);
  myPID_2.Compute();
  if (Output2 < 0) {
    analogWrite(H2_LPWM,abs(Output2));
    analogWrite(H2_RPWM,0);
  } else if (Output2 > 0) {
    analogWrite(H2_LPWM,0);
    analogWrite(H2_RPWM,abs(Output2));
  } else {
    analogWrite(H2_LPWM,0);
    analogWrite(H2_RPWM,0);
  }

  ///PID 3
  Input3 = sensor3.temperature(100, RREF);
  myPID_3.Compute();
  if (Output3 < 0) {
    analogWrite(H3_RPWM,abs(Output3));
    analogWrite(H3_LPWM,0);
  } else if (Output3 > 0) {
    analogWrite(H3_RPWM,0);
    analogWrite(H3_LPWM,abs(Output3));
  } else {
    analogWrite(H3_LPWM,0);
    analogWrite(H3_RPWM,0);
  }

  ///PID 4
  Input4 = sensor4.temperature(100, RREF);
  myPID_4.Compute();
  if (Output4 < 0) {
    analogWrite(H4_LPWM,abs(Output4));
    analogWrite(H4_RPWM,0);
  } else if (Output4 > 0) {
    analogWrite(H4_LPWM,0);
    analogWrite(H4_RPWM,abs(Output4));
  } else {
    analogWrite(H4_LPWM,0);
    analogWrite(H4_RPWM,0);
  }
  
//  } else {
//    // let's save some power and just shut the TEC off
//    digitalWrite(R_EN, LOW);
//    digitalWrite(L_EN, LOW);
// 


      Serial.print(Setpoint4);
      Serial.print(" ");
      Serial.print(Setpoint3);
      Serial.print(" ");
      Serial.print(Setpoint2);
      Serial.print(" ");
      Serial.print(Setpoint1);
      Serial.print(" ");
      Serial.print(Input4);
      Serial.print(" ");
      Serial.print(Input3);
      Serial.print(" ");
      Serial.print(Input2);
      Serial.print(" ");
      Serial.println(Input1);

}

