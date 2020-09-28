const int ExperimentPin = 3; //we're defining the constant ExperimentPin as the int 3

const char CmdUnspecified = 'n'; //We're then defining 3 constants as different characters
const char CmdSetTriggerLow = 'l';
const char CmdSetTriggerHigh = 'h';

bool LEDon = false;
int delay_value = 10;
char serialState = CmdUnspecified;

void setup()
{
    Serial.begin(115200); //Starts serial data transmission
    pinMode(ExperimentPin, OUTPUT); //set pin number 3 to be an output
    digitalWrite(ExperimentPin, LOW); //assign a low output to that pin (0 V)
}

void loop()
{
    char serialState = CmdUnspecified;

    if (Serial.available() > 0) { //if you're getting any information through the serial port
        serialState = Serial.read(); //change the state to whatever you're reading
    }

//I think right now serialState can either be h, l or 7
    switch(serialState) {
        case CmdUnspecified: //If no command is specified
          digitalWrite(ExperimentPin, LOW); //don't send any output through the pin
          break;
        case CmdSetTriggerLow: //if the trigger is set to low (state = l)
          LEDon = false;
          digitalWrite(ExperimentPin, LOW); //don't send any output through the pin
          break;
        case CmdSetTriggerHigh:
          LEDon = true; 
          delay_value = 10;
          break;
        case '1':
          LEDon = true; 
          delay_value = 1;
          break;
        case '2':
          LEDon = true; 
          delay_value = 2;
          break;
        case '3':
          LEDon = true; 
          delay_value = 3;
          break;
        case '4':
          LEDon = true; 
          delay_value = 4;
          break;
        case '5':
          LEDon = true; 
          delay_value = 5;
          break;
        case '6':
          LEDon = true; 
          delay_value = 6;
          break;
        case '7': //if the state reads 7 (as in the 'conditioned menotaxis')
          LEDon = true; //set the LEDon variable to be TRUE
          delay_value = 7; //and the delay_value variable to be 7
          break;
        case '8':
          LEDon = true; 
          delay_value = 8;
          break;
        case '9':
          LEDon = true; 
          delay_value = 9;
          break;
        default:
          break;
    }
        
//next comes a segment for pulsewidth modulation
    if (LEDon) { //if the LEDon variable is TRUE
        digitalWrite(ExperimentPin, HIGH);   // turn the LED on
        delay(delay_value);                       // wait for as many ms as the delay_value says
        digitalWrite(ExperimentPin, LOW);    // turn the LED off
        delay(10-delay_value); //wait for as many ms as 10-delay_value
    }
}
