import processing.serial.*;
import eeml.*;
DataOut dOut;
float lastUpdate;
Serial myPort;   
import cc.arduino.*;
Arduino arduino;


    int sensorValues[] = {1,1,1,1,1,1,1};
    int sensorValue0 = 1;        
    int sensorValue1 = 1;    
    int sensorValue2 = 1;
    
void setup(){
    // set up DataOut object; requires URL of the EEML you are updating, and your Pachube API key   
    dOut = new DataOut(this, "https://pachube.com/api/46230.xml", "ENTER_PACHUBE_API_KEY_HERE");   

    //  and add and tag a datastream    
    dOut.addData(0,"temp");
    dOut.addData(1,"light");
    
    arduino = new Arduino(this, Arduino.list()[0], 57600);  //9600
    // serial.bufferUntil('\n');
    
    for (int i = 0; i <= 6; i++)
      arduino.pinMode(i, Arduino.INPUT);
    
    arduino.pinMode(13, Arduino.OUTPUT);
    arduino.pinMode(9, Arduino.OUTPUT);
    arduino.pinMode(8, Arduino.OUTPUT);
    


     // set the window size:
      size(640, 100);        
      background(0);
}


void draw()
{
//   String myString = myPort.readStringUntil('\n');
//   if (myString != null) {
//   String[] sensors = split(myString, ',');
//   float inByte = float(sensors[0]); 
//   println(inByte);
//   println(sensors[1]);
  

{
//for (int i = 0; i <= 6; i++)            delete me
//  arduino.pinMode(i, Arduino.INPUT);
  
for (int i = 1; i <= 6; i++)
  sensorValues[i]= arduino.analogRead(i-1);

// sensorValue[i] = arduino.analogRead(i);
// sensorValue0 = arduino.analogRead(1);
  
  System.out.println("Get sensor data.. Sensor-values : "+sensorValues[1] +", " +sensorValues[2] + ", "+sensorValues[3] +", "+sensorValues[4] +", "+sensorValues[5] +", "+sensorValues[6] +"  ---");   // "\n---------------------");
  arduino.digitalWrite(9, arduino.LOW);
  delay(300);
  arduino.digitalWrite(9, arduino.HIGH);
  delay(300);
}




    // update once every 10 seconds (could also be e.g. every mouseClick)
    if ((millis() - lastUpdate) > 5000){
        println("ready to POST: ");
        dOut.update(0, sensorValue0); // update the datastream 
        
//         dOut.update(1, sensors[1]); // update the datastream 
        int response = dOut.updatePachube(); // updatePachube() updates by an authenticated PUT HTTP request
        if ((response) == 200){
          println("Feed updated sucessfully");
          arduino.digitalWrite(8, arduino.HIGH);
          delay(100);
          arduino.digitalWrite(8, arduino.LOW);
        }
          else {
           if ((response) == 401){
             println("Update failed: unauthorized");}
             else {
               if ((response) == 404){
                 println("Update failed: feed doesn't exist");}
                 else {
                   println("Update failed: unknown error nr."+response+"...");}
             }}
//        println(response); // should be 200 if successful; 401 if unauthorized; 404 if feed doesn't exist

        lastUpdate = millis();
    }
  }
