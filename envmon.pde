import processing.serial.*;
import cc.arduino.*;
import eeml.*;
import pachuino.*;

Pachuino p;

void setup(){   
    p = new Pachuino(this, Arduino.list()[0], 57600);  // 115200);
    p.manualUpdate("https://pachube.com/api/45927.xml"); // change URL -- Achtung .xml  !
    p.setKey("ENTER_PACHUBE_API_KEY_HERE");   

   
    // local sensors   
    p.addLocalSensor("analog", 0,"Light for test");
    p.addLocalSensor("analog", 1,"Temp-room");
    p.addLocalSensor("analog", 2,"Temp-heater");
    p.addLocalSensor("analog", 3,"Temp-outdoor");
    p.addLocalSensor("digital", 2, "button");
    p.addLocalSensor("digital", 5, "button2"); 

    // remote sensors
   

}

void draw(){
    float tempVal1 = p.localSensor[3].value;

    // String tempTags1 = p.localSensor[0].tags;

    // p.debug();
}



// you don't need to change any of these

// void onReceiveEEML(DataIn d){ 
//     p.updateRemoteSensors(d);
// }
