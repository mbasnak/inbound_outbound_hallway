#include "SerialReceiver.h"

const int TriggerPin = 3;
const int ExperimentPin = 6;

const int CmdUnspecified = -1;
const int CmdSetTriggerLow = 0;
const int CmdSetTriggerHigh = 1;

bool LEDon = false;



SerialReceiver receiver = SerialReceiver();

void setup()
{
    Serial.begin(115200);
    pinMode(TriggerPin,OUTPUT);
    digitalWrite(TriggerPin,LOW);
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

    switch (cmd)
    {
        case CmdSetTriggerLow:
            Serial.println("Trigger LOW");
            LEDon = false;
            digitalWrite(TriggerPin,LOW);
            digitalWrite(ExperimentPin, HIGH);
            break;

        case CmdSetTriggerHigh:
            Serial.println("Trigger HIGH");
            LEDon = true; 
            digitalWrite(ExperimentPin, HIGH);
            break;
        
        case CmdUnspecified:
            Serial.println("Experiment OFF");
            digitalWrite(TriggerPin, LOW);
            digitalWrite(ExperimentPin, LOW);

        default:
            break;

    }

    if (LEDon) {
        digitalWrite(TriggerPin, HIGH);   // turn the LED on (HIGH is the voltage level)
        delay(24);                       // wait for a second
        digitalWrite(TriggerPin, LOW);    // turn the LED off by making the voltage LOW
        delay(1); 
    }
}
