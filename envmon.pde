import processing.serial.*;
import eeml.*;
DataOut dOut;
float lastUpdate;
Serial myPort;   
import cc.arduino.*;
Arduino arduino;


    float sensorValues[] = {0,0,0,0,0,0};
    float sumValues[] = {0,0,0,0,0,0};
    float averageValues[] = {0,0,0,0,0,0};
    int averageCounter = (int) 0;

    
void setup(){
    // set up DataOut object; requires URL of the EEML you are updating, and your Pachube API key   
    dOut = new DataOut(this, "https://pachube.com/api/46230.xml", "ENTER_PACHUBE_API_KEY_HERE");   

    //  and add and tag a datastream    
    dOut.addData(0,"light");
    dOut.addData(1,"temp1");
    dOut.addData(2,"temp2");
    dOut.addData(3,"temp3");
    dOut.addData(4,"empty");
    dOut.addData(5,"empty");
    
    arduino = new Arduino(this, Arduino.list()[0], 57600);  //9600
    // serial.bufferUntil('\n');
    
    for (int i = 0; i <= 6; i++)
      arduino.pinMode(i, Arduino.INPUT);
    
    arduino.pinMode(13, Arduino.OUTPUT);
    arduino.pinMode(9, Arduino.OUTPUT);
    arduino.pinMode(8, Arduino.OUTPUT);
    


 --------------------------// set the window size:
      size(640, 100);        
      background(0);
}


void draw()
  
for (int i = 0; i < 6; i++)
  sensorValues[i]= arduino.analogRead(i);

for (int i = 0; i < 6; i++)
  sumValues[i]= sumValues[i] + sensorValues[i];
  averageCounter = averageCounter + 1;
  
  System.out.println("Get sensor data...  values: "+sensorValues[0] +", "+sensorValues[1] +", " +sensorValues[2] + ", "+sensorValues[3] +", "+sensorValues[4] +", "+sensorValues[5] +"  ---");   // "\n---------------------");
  arduino.digitalWrite(9, arduino.LOW);
  delay(300);
  arduino.digitalWrite(9, arduino.HIGH);
  delay(300);
}


// -----------------update once every 10 seconds (could also be e.g. every mouseClick)

    if ((millis() - lastUpdate) > 5000){
        println("ready to POST average of "+averageCounter+" values...");
        
        for (int i = 0; i < 6; i++)
         averageValues[i]= (sumValues[i] / (averageCounter) );

        println("which are the following averages "+averageValues[0]+", "+averageValues[1]+", "+averageValues[2]+", "+averageValues[3]+", "+averageValues[4]+", "+averageValues[5]+"  ...");

        dOut.update(0, averageValues[0]);           // update the datastream
        dOut.update(1, averageValues[1]);           // update the datastream
        dOut.update(2, averageValues[2]);           // update the datastream
        dOut.update(3, averageValues[3]);           // update the datastream
        dOut.update(4, averageValues[4]);           // update the datastream
        dOut.update(5, averageValues[5]);           // update the datastream



// reset variables
        averageCounter = 0;
        sumValues[0] = (0); sumValues[1] = (0); sumValues[2] = (0); sumValues[3] = (0);sumValues[4] = (0); sumValues[5] = (0);
                
        int response = dOut.updatePachube();       // updatePachube() updates by an authenticated PUT HTTP request
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
