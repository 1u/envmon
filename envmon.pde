import processing.serial.*;
import eeml.*;
DataOut dOut;
float lastUpdate;
// Serial myPort;   
import cc.arduino.*;
Arduino arduino;


    float sensorValues[] = {0,0,0,0,0,0};
    float sumValues[] = {0,0,0,0,0,0};
    float averageValues[] = {0,0,0,0,0,0};
    float realAValues[] = {0,0,0,0,0,0};
    int averageCounter = (int) 0;
    
    int updating = 0;
    int xPosOld = 0;
    int xAvPosOld = 0;
    float yPosOld = 0;
    int xPos = 1;         // horizontal position of the graph
    


// ------------------------------------------ SETUP --------------------------------------------
void setup(){
  
  println(Serial.list());
  
    // set up DataOut object; requires URL of the EEML you are updating, and your Pachube API key   
    dOut = new DataOut(this, "https://pachube.com/api/46290.xml", 
    "Mic4VPjFsKUAH8IFpS2RznxAgE2LWhRygjmI6a-ErnVdmNpRc2lkFd0AA4O3YIV7gKGRm22fxvblDMF_Eo95t6Clk52Jm1ebZVlNcYhX8_qN-g55UndFjSuQ67S-T-95");   

    //  and add and tag a datastream    
    dOut.addData(0,"light, LDR, light level");
    dOut.addData(1,"temp, air, room temp");
    dOut.addData(2,"temp, air, heater temp");
    dOut.addData(3,"temp, air, outside temp");
    dOut.addData(4,"empty");
    dOut.addData(5,"empty");
    
    arduino = new Arduino(this, Arduino.list()[0], 57600);  //9600
    // serial.bufferUntil('\n');
    
    for (int i = 0; i <= 6; i++)
      arduino.pinMode(i, Arduino.INPUT);
    
    arduino.pinMode(13, Arduino.OUTPUT);
    arduino.pinMode(9, Arduino.OUTPUT);
    arduino.pinMode(8, Arduino.OUTPUT);
    

      size(640, 150);                                       // set the window size:
      background(0);
}



// ----------------------------------------------------------------------------------------------
void draw()
{
  
{
for (int i = 0; i < 6; i++)
  sensorValues[i]= arduino.analogRead(i);                    // read the values from the arduino

for (int i = 0; i < 6; i++)                                  // sum them up
  sumValues[i]= sumValues[i] + sensorValues[i];
  averageCounter = averageCounter + 1;
  
//   System.out.println("Get sensor data...  values:   "+sensorValues[0] +",    "+sensorValues[1] +",    " +sensorValues[2] + ",    "+sensorValues[3] +",    "+sensorValues[4] +",    "+sensorValues[5] +" ");   // "\n---------------------");
  arduino.digitalWrite(9, arduino.LOW);
  delay(100);
  arduino.digitalWrite(9, arduino.HIGH);                      // blink once for every data-block
  delay(50);
}




// ------------------------------------  draw the graph:  ------------------------------------


 stroke(255,100,50);
 line(xPos, height, xPos, height - ((sensorValues[1] - 465 )* 2) ); 
 stroke(100,100,255);
 line(xPos, height, xPos, height - ((sensorValues[3] - 460 )* 8) ); 
 stroke(200,200,200);
 line(xPos, height, xPos, height - sensorValues[0]); 
 
 if (updating == 1) {                                      // draw the average-line
     stroke(255,230,200);
     line(xAvPosOld, height - yPosOld, (xPos + xPosOld)/2 , height - (averageValues[1] * 4.15 - 7 ));
     text(averageValues[1], (xPos + xPosOld)/2 - 25 , height- averageValues[1] * 4.15 - 7);
     xAvPosOld = (xPos + xPosOld)/2;
     xPosOld = xPos;
     yPosOld = averageValues[1] * 4.15 - 7 ;
     }
 
 if (xPos >= width) {                                      // at the edge of the screen, go back to the beginning:
 xPos = 0; background(0); xPosOld = 0;}
 else {
   xPos++;                                                 // increment the horizontal position:
 }





// -----------------update Pachube once every 10 seconds (could also be e.g. every mouseClick)


updating = 0;
    if ((millis() - lastUpdate) > 10000){
        updating = 1;
        for (int i = 0; i < 6; i++)
          averageValues[i]= (sumValues[i] / (averageCounter) );                  // make average
        for (int i = 1; i < 6; i++)
          averageValues[i]= ((averageValues[i] - 471) / 1.70f );                  //  come to a realistic value
        for (int i = 0; i < 6; i++)
          averageValues[i] = Math.round(averageValues[i] * 100) / 100.0f;        // round the Value to 2 floatingpoints

        println(" ready to POST average of "+averageCounter+" averaged values        "+averageValues[0]+",   "+averageValues[1]+",   "+averageValues[2]+",   "+averageValues[3]+",   "+averageValues[4]+",   "+averageValues[5]+"  ...");

        dOut.update(0, averageValues[0]);                                        // update the datastream
        dOut.update(1, averageValues[1]);
        dOut.update(2, averageValues[2]);
        dOut.update(3, averageValues[3]);
        dOut.update(4, averageValues[4]);
        dOut.update(5, averageValues[5]);

// reset variables
        averageCounter = 0;
        sumValues[0] = (0); sumValues[1] = (0); sumValues[2] = (0); sumValues[3] = (0);sumValues[4] = (0); sumValues[5] = (0);
                
        int response = dOut.updatePachube();                                     // updatePachube() updates by an authenticated PUT HTTP request
        if ((response) == 200){
          println("Feed updated sucessfully");
          arduino.digitalWrite(8, arduino.HIGH);
          delay(100);
          arduino.digitalWrite(8, arduino.LOW);
        }
          else if ((response) == 401){
            println("Update failed: unauthorized");}
            else if ((response) == 404){
              println("Update failed: feed doesn't exist");}
                else {
                  println("Update failed: unknown error nr."+response+"...");}

        lastUpdate = millis();



    }
  }
