//Thanks for BLINKER
//BY ILS
//Copyright Free 2019

#define BLINKER_WIFI
//#define BLINKER_ESP_SMARTCONFIG
#define BLINKER_DUEROS_OUTLET

#include <Blinker.h>

char auth[] = "dc1ec311bc55";
char ssid[] = "DFS";
char pswd[] = "aishidongfang";

BlinkerButton Button1("btn-sw1");
volatile bool oState = false;

void button1_callback(const String & state)
{
    BLINKER_LOG("get button state: ", state);

    if (oState == false) {
        duerPowerState(BLINKER_CMD_ON);
    }
    else {
        duerPowerState(BLINKER_CMD_OFF);
    }
}

//void isr_button()
//{
//    if (oState == false) {
//        duerPowerState(BLINKER_CMD_ON);
//    }
//    else {
//        duerPowerState(BLINKER_CMD_OFF);
//    }
//}

void duerPowerState(const String & state)
{
    BLINKER_LOG("need set power state: ", state);

    if (state == BLINKER_CMD_ON) {
        digitalWrite(LED_BUILTIN, LOW);
        digitalWrite(D1, HIGH);
        
        BlinkerDuerOS.powerState("on");
        BlinkerDuerOS.print();

        Button1.color("#00A000");
        Button1.text("ON");
        Button1.print();
        
        oState = true;
    }
    else if (state == BLINKER_CMD_OFF) {
        digitalWrite(LED_BUILTIN, HIGH);
        digitalWrite(D1, LOW);

        BlinkerDuerOS.powerState("off");
        BlinkerDuerOS.print();

        Button1.color("#FF0000");
        Button1.text("OFF");
        Button1.print();
        
        oState = false;
    }
}

void duerQuery(int32_t queryCode)
{
    BLINKER_LOG("DuerOS Query codes: ", queryCode);

    switch (queryCode)
    {
        case BLINKER_CMD_QUERY_TIME_NUMBER :
            BLINKER_LOG("DuerOS Query time");
            BlinkerDuerOS.time(millis());
            BlinkerDuerOS.print();
            break;
        default :
            BlinkerDuerOS.time(millis());
            BlinkerDuerOS.print();
            break;
    }
}

void dataRead(const String & data)
{
    BLINKER_LOG("Blinker readString: ", data);

    Blinker.vibrate();
    
    uint32_t BlinkerTime = millis();
    Blinker.print(BlinkerTime);
    Blinker.print("millis", BlinkerTime);
}

void setup()
{
    Serial.begin(115200);
    BLINKER_DEBUG.stream(Serial);

    pinMode(LED_BUILTIN, OUTPUT);
    pinMode(D1, OUTPUT);
    digitalWrite(LED_BUILTIN, HIGH);
    digitalWrite(D1, LOW);

    Blinker.begin(auth, ssid, pswd);
    Blinker.attachData(dataRead);
    
    BlinkerDuerOS.attachPowerState(duerPowerState);
    BlinkerDuerOS.attachQuery(duerQuery);

    Button1.color("#FF0000");
    Button1.text("OFF");
    Button1.print();
    Button1.attach(button1_callback);

//    pinMode(D1, INPUT_PULLUP);
//    attachInterrupt(D1, isr_button, FALLING);
}

void loop()
{
    Blinker.run();
}
