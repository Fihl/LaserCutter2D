#include <ESPWiFi.h>
#include <ESPHTTPClient.h>
#include <JsonListener.h>

#include <time.h>
#include <sys/time.h>

#include "SSD1306Wire.h"
#include "OLEDDisplayUi.h"
#include "Wire.h"
#include "OpenWeatherMapCurrent.h"
#include "OpenWeatherMapForecast.h"
#include "WeatherStationFonts.h"
#include "WeatherStationImages.h"
#include <ESP8266WiFi.h>
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"

#include <Adafruit_BMP085.h>

#include "PrivateCredentials.h" // WIFI Settings

/************************* Adafruit.io Setup *********************************/
#include "PrivateCredentials.h" // AIO_SERVER, AIO_SERVERPORT, AIO_, AIO_USERNAME, AIO_KEY, AIO_FINGERPRINT
WiFiClientSecure client; // WiFiFlientSecure for SSL/TLS support
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);

Adafruit_MQTT_Publish mqtt_Temp = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Temp");
Adafruit_MQTT_Publish mqtt_Light = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Lys");
Adafruit_MQTT_Publish mqtt_Baro = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Baro");
Adafruit_MQTT_Publish mqtt_Humi = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Fugt");

// DHT11 Settings
#define pin 14 // ESP8266-12E  D5 read emperature and Humidity data
int _Temp; //temperature
int _Humi; //humidity
void readTemperatureHumidity();
long readTime = 0; 
long uploadTime = 0; 

// Atmosphere and Light Sensor Settings
void readLight();
void readAtmosphere();
Adafruit_BMP085 bmp;
const int Light_ADDR = 0b0100011;   // address:0x23
const int Atom_ADDR = 0b1110111;  // address:0x77
int _Light;
float _Baro;

/***************************
 * Begin Settings
 **************************/
#define TZ              1       // (utc+) TZ in hours
#define DST_MN          0      // use 60mn for summer time in some countries

// Setup
const int UPDATE_INTERVAL_SECS = 20 * 60; // Update every 20 minutes
// Display Settings
const int I2C_DISPLAY_ADDRESS = 0x3c;
#if defined(ESP8266)
//const int SDA_PIN = D1;
//const int SDC_PIN = D2;

const int SDA_PIN = D3;
const int SDC_PIN = D4;
#else
//const int SDA_PIN = GPIO5;
//const int SDC_PIN = GPIO4 

const int SDA_PIN = GPIO0;
const int SDC_PIN = GPIO2 
#endif


// OpenWeatherMap Settings
// Sign up here to get an API key:
// https://docs.thingpulse.com/how-tos/openweathermap-key/
// Test in a browser against https://api.openweathermap.org/data/2.5/weather?id=2615730&appid=1f51750fXXXXXXXXXXX&units=metric&lang=en
// Put in your own API key
const boolean IS_METRIC = true;
// Add your own thingpulse ID
#include "PrivateCredentials.h" //thingpulse API keys 

// Pick a language code from this list:
// Arabic - ar, Bulgarian - bg, Catalan - ca, Czech - cz, German - de, Greek - el,
// English - en, Persian (Farsi) - fa, Finnish - fi, French - fr, Galician - gl,
// Croatian - hr, Hungarian - hu, Italian - it, Japanese - ja, Korean - kr,
// Latvian - la, Lithuanian - lt, Macedonian - mk, Dutch - nl, Polish - pl,
// Portuguese - pt, Romanian - ro, Russian - ru, Swedish - se, Slovak - sk,
// Slovenian - sl, Spanish - es, Turkish - tr, Ukrainian - ua, Vietnamese - vi,
// Chinese Simplified - zh_cn, Chinese Traditional - zh_tw.

String OPEN_WEATHER_MAP_LANGUAGE = "en";
const uint8_t MAX_FORECASTS = 4;

// Adjust according to your language
const String WDAY_NAMES[] = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"};
const String MONTH_NAMES[] = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

/***************************
 * End Settings
 **************************/
 // Initialize the oled display for address 0x3c
 SSD1306Wire     display(I2C_DISPLAY_ADDRESS, SDA_PIN, SDC_PIN);
 OLEDDisplayUi   ui( &display );

OpenWeatherMapCurrentData currentWeather;
OpenWeatherMapCurrent currentWeatherClient;

OpenWeatherMapForecastData forecasts[MAX_FORECASTS];
OpenWeatherMapForecast forecastClient;

#define TZ_MN           ((TZ)*60)
#define TZ_SEC          ((TZ)*3600)
#define DST_SEC         ((DST_MN)*60)
time_t now;

// flag changed in the ticker function every 10 minutes
bool readyForWeatherUpdate = false;
String lastUpdate = "--";
long timeSinceLastWUpdate = 0;
//declaring prototypes
void drawProgress(OLEDDisplay *display, int percentage, String label);
void updateData(OLEDDisplay *display);
void drawDateTime(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y);
void drawCurrentWeather(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y);
void drawForecast(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y);
void drawLocal(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y);
void drawHeaderOverlay(OLEDDisplay *display, OLEDDisplayUiState* state);
void setReadyForWeatherUpdate();


// Add frames, this array keeps function pointers to all frames
// frames are the single views that slide from right to left
FrameCallback frames[] = { drawDateTime, drawCurrentWeather, drawForecast, drawLocal };
int numberOfFrames = 4;

OverlayCallback overlays[] = { drawHeaderOverlay };
int numberOfOverlays = 1;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\nWeatherStationDemoFull.ino");
  Wire.begin(0,2);
  Wire.beginTransmission(Atom_ADDR);
  if (!bmp.begin()) { //initialize Atmosphere sensor
    Serial.println("Could not find BMP180 or BMP085 sensor at 0x77");
  }else{
    Serial.println("Find BMP180 or BMP085 sensor at 0x77");
  }
  Wire.endTransmission();

  Wire.beginTransmission(Light_ADDR); //initialize light sensor
  Wire.write(0b00000001);
  Wire.endTransmission();
  
  display.init(); // initialize display
  display.clear();
  display.display();
  
  //display.flipScreenVertically();
  display.setFont(ArialMT_Plain_10);
  display.setTextAlignment(TEXT_ALIGN_CENTER);
  display.setContrast(255);
  
  Serial.print("Connecting to ");
  Serial.println(WLAN_SSID);
  WiFi.begin(WLAN_SSID, WLAN_PASS); // Connect to WiFi access point.
  int counter = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.printf("%d ",counter++);
    display.clear();
    display.drawString(64, 10, "Connecting to WiFi");
    display.drawXbm(46, 30, 8, 8, counter % 3 == 0 ? activeSymbole : inactiveSymbole);
    display.drawXbm(60, 30, 8, 8, counter % 3 == 1 ? activeSymbole : inactiveSymbole);
    display.drawXbm(74, 30, 8, 8, counter % 3 == 2 ? activeSymbole : inactiveSymbole);
    display.display();
  }
  Serial.println();

  Serial.printf("WiFi connected, IP address: %s\n",WiFi.localIP());

  client.setFingerprint(AIO_FINGERPRINT); // check the fingerprint of io.adafruit.com's SSL cert
  Serial.println("MQTTS server: " AIO_SERVER);
  MQTT_connect();

  // Get time from network time service
  configTime(TZ_SEC, DST_SEC, "pool.ntp.org");
  ui.setTargetFPS(30);
  ui.setActiveSymbol(activeSymbole);
  ui.setInactiveSymbol(inactiveSymbole);
  // You can change this to
  // TOP, LEFT, BOTTOM, RIGHT
  ui.setIndicatorPosition(BOTTOM);
  // Defines where the first frame is located in the bar.
  ui.setIndicatorDirection(LEFT_RIGHT);
  // You can change the transition that is used
  // SLIDE_LEFT, SLIDE_RIGHT, SLIDE_TOP, SLIDE_DOWN
  ui.setFrameAnimation(SLIDE_LEFT);
  ui.setFrames(frames, numberOfFrames);
  ui.setOverlays(overlays, numberOfOverlays);
  // Inital UI takes care of initialising the display too.
  ui.init();
  updateData(&display);  
}

// Function to connect and reconnect as necessary to the MQTT server.
void MQTT_connect() {
  if (mqtt.connected()) return;
  Serial.print("Connecting to MQTT... ");
  uint8_t retries = 3;
  int ret;
  while ((ret = mqtt.connect()) != 0) {
       Serial.println(mqtt.connectErrorString(ret));
       Serial.println("Retrying MQTT connection in 5 seconds...");
       mqtt.disconnect();
       delay(5000);  // wait 5 seconds
       retries--;
       if (retries == 0) while (1); // die and wait for WDT to reset me
  }
  Serial.println("MQTT Connected!");
}

void drawProgress(OLEDDisplay *display, int percentage, String label) {
  display->clear();
  display->setTextAlignment(TEXT_ALIGN_CENTER);
  display->setFont(ArialMT_Plain_10);
  display->drawString(64, 10, label);
  display->drawProgressBar(2, 28, 124, 10, percentage);
  display->display();
  delay(300);
}

void updateData(OLEDDisplay *display) {
  drawProgress(display, 10, "Updating time...");
  drawProgress(display, 30, "Updating weather...");
  currentWeatherClient.setMetric(IS_METRIC);
  currentWeatherClient.setLanguage(OPEN_WEATHER_MAP_LANGUAGE);
  currentWeatherClient.updateCurrentById(&currentWeather, OPEN_WEATHER_MAP_APP_ID, OPEN_WEATHER_MAP_LOCATION_ID);
  drawProgress(display, 50, "Updating forecasts...");
  forecastClient.setMetric(IS_METRIC);
  forecastClient.setLanguage(OPEN_WEATHER_MAP_LANGUAGE);
  uint8_t allowedHours[] = {12};
  forecastClient.setAllowedHours(allowedHours, sizeof(allowedHours));
  forecastClient.updateForecastsById(forecasts, OPEN_WEATHER_MAP_APP_ID, OPEN_WEATHER_MAP_LOCATION_ID, MAX_FORECASTS);
  readyForWeatherUpdate = false;
  drawProgress(display, 100, "Done...");
  delay(1000);
}

void drawDateTime(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y) {
  now = time(nullptr);
  struct tm* timeInfo;
  timeInfo = localtime(&now);
  char buff[16];

  display->setTextAlignment(TEXT_ALIGN_CENTER);
  display->setFont(ArialMT_Plain_10);
  String date = WDAY_NAMES[timeInfo->tm_wday];

  sprintf_P(buff, PSTR("%s, %02d/%02d/%04d"), WDAY_NAMES[timeInfo->tm_wday].c_str(), timeInfo->tm_mday, timeInfo->tm_mon+1, timeInfo->tm_year + 1900);
  display->drawString(64 + x, 5 + y, String(buff));
  display->setFont(ArialMT_Plain_24);

  sprintf_P(buff, PSTR("%02d:%02d:%02d"), timeInfo->tm_hour, timeInfo->tm_min, timeInfo->tm_sec);
  display->drawString(64 + x, 15 + y, String(buff));
  display->setTextAlignment(TEXT_ALIGN_LEFT);
}

void drawLocal(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y)
{ 
  char buff[30];
  display->setTextAlignment(TEXT_ALIGN_LEFT);
  display->setFont(ArialMT_Plain_10);
  sprintf_P(buff, PSTR("Temp: %d"), _Temp);
  display->drawString(x, 5 + y, String(buff));
  sprintf_P(buff, PSTR("Light: %d"), _Light);
  display->drawString(x, 15 + y, String(buff));
  sprintf_P(buff, PSTR("Humi: %d"), _Humi);
  display->drawString(x, 25 + y, String(buff));
  sprintf_P(buff, PSTR("Barometric: %.1f hPa"), _Baro);
  display->drawString(x, 35 + y, String(buff));
}

void drawCurrentWeather(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y) {
  display->setFont(ArialMT_Plain_10);
  display->setTextAlignment(TEXT_ALIGN_CENTER);
  display->drawString(64 + x, 38 + y, currentWeather.description);

  display->setFont(ArialMT_Plain_24);
  display->setTextAlignment(TEXT_ALIGN_LEFT);
  String temp = String(currentWeather.temp, 1) + (IS_METRIC ? "°C" : "°F");
  display->drawString(60 + x, 5 + y, temp);

  display->setFont(Meteocons_Plain_36);
  display->setTextAlignment(TEXT_ALIGN_CENTER);
  display->drawString(32 + x, 0 + y, currentWeather.iconMeteoCon);
}


void drawForecast(OLEDDisplay *display, OLEDDisplayUiState* state, int16_t x, int16_t y) {
  drawForecastDetails(display, x, y, 0);
  drawForecastDetails(display, x + 44, y, 1);
  drawForecastDetails(display, x + 88, y, 2);
}

void drawForecastDetails(OLEDDisplay *display, int x, int y, int dayIndex) {
  time_t observationTimestamp = forecasts[dayIndex].observationTime;
  struct tm* timeInfo;
  timeInfo = localtime(&observationTimestamp);
  display->setTextAlignment(TEXT_ALIGN_CENTER);
  display->setFont(ArialMT_Plain_10);
  display->drawString(x + 20, y, WDAY_NAMES[timeInfo->tm_wday]);

  display->setFont(Meteocons_Plain_21);
  display->drawString(x + 20, y + 12, forecasts[dayIndex].iconMeteoCon);
  String temp = String(forecasts[dayIndex].temp, 0) + (IS_METRIC ? "°C" : "°F");
  display->setFont(ArialMT_Plain_10);
  display->drawString(x + 20, y + 34, temp);
  display->setTextAlignment(TEXT_ALIGN_LEFT);
}

void drawHeaderOverlay(OLEDDisplay *display, OLEDDisplayUiState* state) {
  now = time(nullptr);
  struct tm* timeInfo;
  timeInfo = localtime(&now);
  char buff[14];
  sprintf_P(buff, PSTR("%02d:%02d"), timeInfo->tm_hour, timeInfo->tm_min);

  display->setColor(WHITE);
  display->setFont(ArialMT_Plain_10);
  display->setTextAlignment(TEXT_ALIGN_LEFT);
  display->drawString(0, 54, String(buff));
  display->setTextAlignment(TEXT_ALIGN_RIGHT);
  String temp = String(currentWeather.temp, 1) + (IS_METRIC ? "°C" : "°F");
  display->drawString(128, 54, temp);
  display->drawHorizontalLine(0, 52, 128);
}

void setReadyForWeatherUpdate() {
  Serial.println("Setting readyForUpdate to true");
  readyForWeatherUpdate = true;
}

//read temperature humidity data
void readTemperatureHumidity(){
  int j;
  unsigned int loopCnt;
  int chr[40] = {0};
  unsigned long time1;
bgn:
  delay(2000);
  //Set interface mode 2 to: output
  //Output low level 20ms (>18ms)
  //Output high level 40μs
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  delay(20);
  digitalWrite(pin, HIGH);
  delayMicroseconds(40);
  digitalWrite(pin, LOW);
  //Set interface mode 2: input
  pinMode(pin, INPUT);
  //High level response signal
  loopCnt = 10000;
  while (digitalRead(pin) != HIGH){
    if (loopCnt-- == 0){
      //If don't return to high level for a long time, output a prompt and start over
      Serial.println("HIGH Humidity");
      goto bgn;
    }
  }
  //Low level response signal
  loopCnt = 30000;
  while (digitalRead(pin) != LOW){
    if (loopCnt-- == 0){
      //If don't return low for a long time, output a prompt and start over
      Serial.println("LOW Humidity");
      goto bgn;
    }
  }
  //Start reading the value of bit1-40
  for (int i = 0; i < 40; i++){
    while (digitalRead(pin) == LOW){}
    //When the high level occurs, write down the time "time"
    time1 = micros();
    while (digitalRead(pin) == HIGH){}
    //When there is a low level, write down the time and subtract the time just saved
    //If the value obtained is greater than 50μs, it is ‘1’, otherwise it is ‘0’
    //And save it in an array
    if (micros() - time1  > 50){
      chr[i] = 1;
    } else {
      chr[i] = 0;
    }
  }
  //Humidity, 8-bit bit, converted to a value
  _Humi = chr[0] * 128 + chr[1] * 64 + chr[2] * 32 + chr[3] * 16 + chr[4] * 8 + chr[5] * 4 + chr[6] * 2 + chr[7];
  //Temperature, 8-bit bit, converted to a value
  _Temp = chr[16] * 128 + chr[17] * 64 + chr[18] * 32 + chr[19] * 16 + chr[20] * 8 + chr[21] * 4 + chr[22] * 2 + chr[23];
}

void readLight(){
  // reset
  Wire.beginTransmission(Light_ADDR);
  Wire.write(0b00000111);
  Wire.endTransmission();
 
  Wire.beginTransmission(Light_ADDR);
  Wire.write(0b00100000);
  Wire.endTransmission();
  // typical read delay 120ms
  delay(120);
  Wire.requestFrom(Light_ADDR, 2); // 2byte every time
  for (_Light = 0; Wire.available() >= 1; ) {
    char c = Wire.read();
    _Light = (_Light << 8) + (c & 0xFF);
  }
  _Light = _Light / 1.2;
}


void readAtmosphere(){
  _Baro = bmp.readPressure() / 100.0;
}

//upload temperature humidity data to thinkspak.com
void uploadMQTT(){
  MQTT_connect();
  if (! mqtt_Temp.publish(_Temp)) Serial.printf("Failed temperature %d",_Temp);
  if (! mqtt_Light.publish(_Light)) Serial.printf("Failed temperature %d",_Light);
  if (! mqtt_Baro.publish(_Baro)) Serial.printf("Failed temperature %f",_Baro);
  if (! mqtt_Humi.publish(_Humi)) Serial.printf("Failed temperature %f",_Humi);
}

void loop() {  
  //Read Temperature Humidity every 5 seconds
  if(millis() - readTime > 5000){
    readTemperatureHumidity();
    readLight();
    readAtmosphere();
    readTime = millis();
    Serial.printf("Temp: %d, Humi: %d, Barometric: %.1f hPa, Light: %d\n",_Temp,_Humi,_Baro,_Light);
  }
  //Upload Temperature Humidity every 60 seconds
  if(millis() - uploadTime > 60000){
    uploadMQTT();
    uploadTime = millis();
  }
  if (millis() - timeSinceLastWUpdate > (1000L*UPDATE_INTERVAL_SECS)) {
    setReadyForWeatherUpdate();
    timeSinceLastWUpdate = millis();
  }

  if (readyForWeatherUpdate && ui.getUiState()->frameState == FIXED) {
    updateData(&display);
  }

  int remainingTimeBudget = ui.update();

  if (remainingTimeBudget > 0) {
    // You can do some work here
    // Don't do stuff if you are below your
    // time budget.
    delay(remainingTimeBudget);
  }
}
