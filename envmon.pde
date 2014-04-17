import processing.serial.*;
import cc.arduino.*;
import eeml.*;
import pachuino.*;

Pachuino p;

void setup(){   
    p = new Pachuino(this, Arduino.list()[0], 57600);   
    p.manualUpdate("https://pachube.com/api/45927"); // change URL -- this is the feed you want to update
    p.setKey("ENTER_PACHUBE_API_KEY_HERE");   

   
    // local sensors   
    p.addLocalSensor("analog", 0,"lightSensor");
    p.addLocalSensor("analog", 1,"temperature");
    p.addLocalSensor("digital", 2, "button");
    p.addLocalSensor("digital", 5, "button2"); 

    // remote sensors
   

}

void draw(){
    float tempVal1 = p.localSensor[3].value;

    String tempTags1 = p.localSensor[0].tags;

    //p.debug();
}



// you don't need to change any of these

void onReceiveEEML(DataIn d){ 
    p.updateRemoteSensors(d);
}
