#include <stdlib.h>

volatile unsigned int custom_code;
volatile byte key_code;
volatile byte o_key_code;
volatile unsigned long last_fall_time;
volatile byte bit_count;
volatile byte state;
//volatile int arrdur[32];

//初始化
void setup() {
  cli();
  //设置13口 LED 为输出
  pinMode(13, OUTPUT);
  //设置2口 INT0 为输入
  pinMode(2, INPUT);
  //设置输出口x为高阻
  pinMode(4, INPUT);
  //设置输出口+为高阻
  pinMode(5, INPUT);
  //设置输出口-为高阻
  pinMode(6, INPUT);
  //设置串口 9600
  Serial.begin(9600);
  //设置中断处理，下降沿
  attachInterrupt(0, ir_interrupt, FALLING);
  state=0;
  //闪灯2次表示启动完成
  led_blink();
  led_blink();
  Serial.println("init success");
  //开中断开始工作
  last_fall_time=0;
  sei();
}
//循环
void loop()
{
  //未接收到数据
  if(state <= 2)
  {
    return;
  }
  //一组数据完毕
  if(state==3)
  {
    //验证
    if((key_code^o_key_code)==255)
    {
      if(custom_code==251)
      {
        if(key_code==2)
        {
          press_key_up();
        }
        else if(key_code==3)
        {
          press_key_down();
        }
        else if(key_code==9)
        {
          press_key_mute();
        }
      }
      Serial.print("key is: ");
      Serial.print(custom_code, HEX);
      Serial.print(' ');
      Serial.println(key_code, HEX);
      led_blink();
    }
  }
  //else
  //{
  //  print_data();
  //}
  state = 0;
  last_fall_time=0;
  //sei();
}
//中断处理
/*中断中如果调用print，会因时间太长，影响计时准确，无法得到正确的数据。*/
void ir_interrupt()
{
  unsigned long curr_fall_time;
  unsigned long fall_during;
  byte bit_value;
  
  //关中断，查看计时
  cli();
  //获取当前的时间，微秒级。中断会停止micros计时，但影响不是很大。
  curr_fall_time = micros();
  //无上次计时，应该是header的第一个fall
  if (last_fall_time == 0)
  {
    last_fall_time=curr_fall_time;
    state=1;
    sei();
    return;
  }
  //有上次计时，是header或数据
  fall_during = curr_fall_time - last_fall_time;
  //header信号13.5ms，扩大判定域以增强容错能力，下同
  if (fall_during > 13400 && fall_during < 13600)
  {
    state=2;
    bit_count=0;
    custom_code=0;
    key_code=0;
    o_key_code=0;
    sei();
    return; //返回，等待下次开始接收
  }
  //记录一下数据以便输出
  //arrdur[bit_conut]=fall_during;
  bit_count++;
  //0信号1.125ms
  if (fall_during > 1024 && fall_during < 1225)
  {
    bit_value=0;
  }
  //1信号2.245ms
  else if (fall_during > 2145 && fall_during < 2345)
  {
    bit_value=128;
  }
  //非法信号，归零状态
  //else
  //{
  //  state=4;
  //  return;
  // }
  if(bit_count>=1 && bit_count<=16)
  {
    custom_code=custom_code>>1|bit_value;
  }
  else if(bit_count>=17 && bit_count<=24)
  {
    key_code=key_code>>1|bit_value;
  }
  else if(bit_count>=25 && bit_count<=32)
  {
    o_key_code=o_key_code>>1|bit_value;
  }
  //接收完32位，设置状态到主程序输出。此处不开中断
  if (bit_count == 32)
  {
    state = 3;
    //return;
  }
  //不足位数，记录本次计时，开中断继续接收
  last_fall_time = curr_fall_time;
  sei();
}
//闪灯
void led_blink()
{
  digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(50);              // wait for a second
  digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
  delay(50);              // wait for a second
}

//音量+，8.6K接地
void press_key_up()
{
  pinMode(5, OUTPUT);
  digitalWrite(5, LOW);
  delay(300);
  digitalWrite(5, HIGH);
  pinMode(5, INPUT);
}

//音量-，6.2K接地
void press_key_down()
{
  pinMode(6, OUTPUT);
  digitalWrite(6, LOW);
  delay(300);
  digitalWrite(6, HIGH);
  pinMode(6, INPUT);
}

//静音，0K接地
void press_key_mute()
{
  pinMode(4, OUTPUT);
  digitalWrite(4, LOW);
  delay(2000);
  digitalWrite(4, HIGH);
  pinMode(4, INPUT);
}

/*
void print_data()
{
  for(int i=0;i<32;i++)
  {
    Serial.print((int)arrdur[i]);
    if(i==15)
    {
      Serial.println(' ');
    }
    else
    {
      Serial.print(' ');
    }
  }
  Serial.println(' ');
}
*/

