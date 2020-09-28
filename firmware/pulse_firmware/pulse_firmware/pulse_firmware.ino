#include "SerialReceiver.h"

const int ExperimentPin = 3;

const int CmdUnspecified = -1;
const int CmdSetTriggerLow = 0;
const int CmdSetTriggerHigh = 10;

bool LEDon = false;
int delay_value = 10;

SerialReceiver receiver = SerialReceiver();

void setup()
{
    Serial.begin(115200);
    pinMode(ExperimentPin, OUTPUT);
    digitalWrite(ExperimentPin, LOW);
}

void loop()
{
    int cmd = CmdUnspecified;

    while (Serial.available() > 0) {
        receiver.process(Serial.read());
        if (receiver.messageReady()) {
            cmd = receiver.readInt(0);
            receiver.reset();
            Serial.println(cmd);
        }
    }

    if (cmd == CmdSetTriggerLow)
    {
        Serial.println("Trigger LOW");
        LEDon = false;
        digitalWrite(ExperimentPin, LOW);
    }else if (cmd == CmdSetTriggerHigh){
        Serial.println("Trigger HIGH");
        LEDon = true; 
        delay_value = 10;
    }else if (cmd > CmdSetTriggerLow && cmd < CmdSetTriggerHigh){
        Serial.println("Trigger INT");
        LEDon = true; 
        delay_value = cmd;
    }

    if (LEDon) {
        digitalWrite(ExperimentPin, HIGH);   // turn the LED on (HIGH is the voltage level)
        delay(delay_value);                       // wait for a second
        digitalWrite(ExperimentPin, LOW);    // turn the LED off by making the voltage LOW
        delay(10-delay_value); 
    }
}
