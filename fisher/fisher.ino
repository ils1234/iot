volatile byte output_current;
volatile unsigned long start_time;
volatile byte serial_index;
volatile byte serial_data[6];

//重要的事情说三遍协议，port 0-5 value 0 1
//port value port value port value
//例 101010 表示第2个继电器关闭（输出1），继电器为低触发
//例 313131 表示第4个继电器开启（输出0）

void setup() {
  //设置13口 LED 为输出并设置low
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
  //设置A0-A7为输出并设置high
  init_outpin();
  output_current=0;
  serial_index=100;
  //设置串口 9600
  Serial.begin(9600);
  while(!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  Serial.println("wait command");
  //闪灯1次表示启动完成
  led_blink();
  while(Serial.available()<=0) {
    delay(300);
  }
}

void loop() {
  unsigned long curr_time;
  unsigned long during;
  curr_time=micros();
  during=curr_time-start_time;
  if(during>3000) {
    serial_index=20;
    delay(100);
  }
  while(Serial.available()>0) {
    if(serial_index>=6) {
      serial_index=0;
      start_time=micros();
    }
    serial_data[serial_index]=Serial.read();
    serial_index++;
    if(serial_index==6) {
      if (serial_data[0] != serial_data[2]
        || serial_data[0] != serial_data[4]
        || serial_data[1] != serial_data[3]
        || serial_data[1] != serial_data[5]) {
        Serial.println("bad data");
        break;
      }
      set_value(serial_data[0], serial_data[1]);
    }
  }
}

//闪灯
void led_blink() {
  digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(500);              // wait for a second
  digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
  delay(50);              // wait for a second
}

void init_outpin() {
  pinMode(A0, OUTPUT);
  digitalWrite(A0, HIGH);
  pinMode(A1, OUTPUT);
  digitalWrite(A1, HIGH);
  pinMode(A2, OUTPUT);
  digitalWrite(A2, HIGH);
  pinMode(A3, OUTPUT);
  digitalWrite(A3, HIGH);
  pinMode(A4, OUTPUT);
  digitalWrite(A4, HIGH);
  pinMode(A5, OUTPUT);
  digitalWrite(A5, HIGH);
  pinMode(A6, OUTPUT);
  digitalWrite(A6, HIGH);
  pinMode(A7, OUTPUT);
  digitalWrite(A7, HIGH);
}

void set_value(byte port_id, byte value) {
  byte port;
  switch (port_id) {
    case '0':
      port=A0;
      break;
    case '1':
      port=A1;
      break;
    case '2':
      port=A2;
      break;
    case '3':
      port=A3;
      break;
    case '4':
      port=A4;
      break;
    case '5':
      port=A5;
      break;
    case '6':
      port=A6;
      break;
    case '7':
      port=A7;
      break;
    case 'A':
      port=0; 
      break;
    default:
      print_value();
      return;
  }
  switch (value) {
    case '0':
      port_off(port);
      break;
    case '1':
      port_on(port);
      break;
    case '2':
      port_tick(port);
      break;
    default:
      print_value();
      break;
  }
}

void port_on(byte port) {
  byte i;
  if (port==0) {
    for (i=A0;i<=A7;i++) {
      _port_on(i);
    }
  }
  else {
    _port_on(port);
  }
}

void _port_on(byte port) {
  bitSet(output_current, port-14);
  digitalWrite(port, LOW);
  Serial.print("A");
  Serial.print(port - 14);
  Serial.println(" on");
}

void port_off(byte port) {
  byte i;
  if (port==0) {
    for (i=A0;i<=A7;i++) {
      _port_off(i);
    }
  }
  else {
    _port_off(port);
  }
}

void _port_off(byte port) {
  digitalWrite(port, HIGH);
  bitClear(output_current, port-14);
  Serial.print("A");
  Serial.print(port - 14);
  Serial.println(" off");
}

void port_tick(byte port) {
  byte i;
  if (port==0) {
    for (i=A0;i<=A7;i++) {
      _port_tick(i);
    }
  }
  else {
    _port_tick(port);
  }
}

void _port_tick(byte port) {
  digitalWrite(port, LOW);
  delay(100);
  digitalWrite(port, HIGH);
  output_current=0;
  Serial.print("A");
  Serial.print(port - 14);
  Serial.println(" tick");
}

void print_value() {
  int i;
  int v;
  for (i = 0; i < 8; i++)
  {
    v = bitRead(output_current, i);
    Serial.print("A");
    Serial.print(i);
    if (v == 1)
    {
      Serial.println(" on");
    }
    else
    {
      Serial.println(" off");
    }
  }
}

