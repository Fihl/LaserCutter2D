// Testet in Arduino 1.8.19. I do think Arduino 2.xx is ok too
// Instructions
//   See https://github.com/GJKJ/WSKS
//   Do NOT run any exe files to update ESP
//   DO updating PrivateCredentials.h with own parameters
//   Compile and upload this code

// PS: adafruitio_root_ca is from https://forums.adafruit.com/viewtopic.php?t=203469 (and in PrivateCredentials.h)

// Lolin S3 Mini
// I2C Scanner:
//I2C device found at address 0x23  !
//I2C device found at address 0x3C  !
//I2C device found at address 0x77  !

#include <WiFi.h>
#include "WiFiClientSecure.h"
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"
#include <JsonListener.h>

#include <time.h>
#include <sys/time.h>

//#include <DFRobot_DHT11.h>
#include "DHT.h" //The one from Adafruit
#include "SSD1306Wire.h"
#include "OLEDDisplayUi.h"
#include "Wire.h"
#include "OpenWeatherMapCurrent.h"
#include "OpenWeatherMapForecast.h"
#include "WeatherStationFonts.h"
#include "WeatherStationImages.h"

#include <Adafruit_BMP085.h>

#include "PrivateCredentials.h" // WIFI Settings

/************************* Adafruit.io Setup *********************************/
#include "PrivateCredentials.h" // AIO_SERVER, AIO_SERVERPORT, AIO_, AIO_USERNAME, AIO_KEY, AIO_FINGERPRINT
WiFiClientSecure client; // WiFiFlientSecure for SSL/TLS support
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);
#define version "3"
Adafruit_MQTT_Publish mqtt_Temp  = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Temp" version);
Adafruit_MQTT_Publish mqtt_Light = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Lys" version);
Adafruit_MQTT_Publish mqtt_Baro  = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Baro" version);
Adafruit_MQTT_Publish mqtt_Humi  = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/Fugt" version);

// DHT11 Settings
//#define DHT11_PIN 14 // ESP8266-12E  D5 read emperature and Humidity data
#define DHT22_PIN 5

//DFRobot_DHT11 DHT;
DHT dht22(DHT22_PIN, DHT22);

int32_t _Temp; //temperature
int32_t _Humi; //humidity
int32_t _Light;
int32_t _Baro;

void readTemperatureHumidity();
long readTime = 0; 
long uploadTime = 0; 

// Atmosphere and Light Sensor Settings
void readLight();
void readAtmosphere();
Adafruit_BMP085 bmp;
#define Light_ADDR  0x23
#define Atom_ADDR   0x77

/***************************
 * Begin Settings
 **************************/
#define TZ              1       // (utc+) TZ in hours
#define DST_MN          0      // use 60mn for summer time in some countries

// Setup
const int UPDATE_INTERVAL_SECS = 20 * 60; // Update every 20 minutes
// Display Settings
#define I2C_DISPLAY_ADDRESS 0x3c ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32 MEN 3C !!
#if defined(ESP8266)
const int SDA_PIN = D3;
const int SDC_PIN = D4;
#else
const int SDA_PIN = 35;
const int SCL_PIN = 36;
#endif

#include "PrivateCredentials.h" //thingpulse API keys 

// OpenWeatherMap Settings
// Sign up here to get an API key:
// https://docs.thingpulse.com/how-tos/openweathermap-key/
// Test in a browser against https://api.openweathermap.org/data/2.5/weather?id=2615730&appid=1f51750f1545e5b21f80e4c1b66062d3&units=metric&lang=en
const boolean IS_METRIC = true;

#define OPEN_WEATHER_MAP_LANGUAGE "en"
const uint8_t MAX_FORECASTS = 4;

// Adjust according to your language
const String WDAY_NAMES[] = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"};
const String MONTH_NAMES[] = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

/***************************
 * End Settings
 **************************/
 // Initialize the oled display for address 0x3c
 SSD1306Wire     display(I2C_DISPLAY_ADDRESS, SDA_PIN, SCL_PIN);
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

// Add frames, this array keeps function pointers to all frames. Frames are the single views that slide from right to left
// FrameCallback frames[] = { drawDateTime, drawCurrentWeather, drawForecast, drawLocal };
// int numberOfFrames = 4;

//My style, not showing the clock
FrameCallback frames[] = { drawCurrentWeather, drawLocal, drawForecast, drawLocal };
int numberOfFrames = 4;


OverlayCallback overlays[] = { drawHeaderOverlay };
int numberOfOverlays = 1;

void blink(byte cnt = 0)
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, 1-digitalRead(LED_BUILTIN) );
  while (cnt-- > 0) {
    //Serial.printf("%d, ",cnt);
    digitalWrite(LED_BUILTIN, 1);
    delay(100);
    digitalWrite(LED_BUILTIN, 0);
    delay(233);
  }
}

void setup() {
  blink(2);
  delay(3000); //Delay before initilizing USB, else crash on S3
  Serial.begin(115200);
  delay(1000);
  Serial.println("\nWeatherStationDemoMQTT_S3mini.ino");  
  
  Wire.begin();

  display.init(); // initialize display
  display.clear();
  display.display();
  
  //display.flipScreenVertically();
  display.setFont(ArialMT_Plain_10);
  display.setTextAlignment(TEXT_ALIGN_CENTER);
  display.setContrast(255);
  Serial.printf("Connecting %s",WLAN_SSID);
  WiFi.begin(WLAN_SSID, WLAN_PASS); // Connect to WiFi access point.
  int counter = 0;
  while (WiFi.status() != WL_CONNECTED) {
    blink(1);
    delay(500);
    Serial.printf(", %d",++counter);
    display.clear();
    display.drawString(64, 10, "Connecting WiFi");
    display.drawXbm(46, 30, 8, 8, counter % 3 == 0 ? activeSymbole : inactiveSymbole);
    display.drawXbm(60, 30, 8, 8, counter % 3 == 1 ? activeSymbole : inactiveSymbole);
    display.drawXbm(74, 30, 8, 8, counter % 3 == 2 ? activeSymbole : inactiveSymbole);
    display.display();
  }
  Serial.printf("\nWiFi connected, IP address: %s\n",WiFi.localIP() .toString().c_str() );
  // https://arduino.stackexchange.com/questions/30534/formatting-of-ipaddress-via-printf-family-similar-to-serial-object
  
  display.drawString(64, 10, "Connected " WLAN_SSID);
  display.display();

  //client.setFingerprint(AIO_FINGERPRINT); // check the fingerprint of io.adafruit.com's SSL cert
  // Set Adafruit IO's root CA
  client.setCACert(adafruitio_root_ca);
  
  Serial.println("MQTTS server: " AIO_SERVER);
  MQTT_connect();

  // Get time from network time service
  configTime(TZ_SEC, DST_SEC, "pool.ntp.org");

  ui.setTargetFPS(30);
  ui.setActiveSymbol(activeSymbole);
  ui.setInactiveSymbol(inactiveSymbole);
  blink(1);

  Serial.printf("BMP180 or BMP085 sensor at 0x%x: ", Atom_ADDR);
  if (bmp.begin()) Serial.println("OK"); else Serial.println("FAILED"); //initialize Atmosphere sensor

  Serial.printf("Light sensor at ox%x \n", Light_ADDR);
  Wire.beginTransmission(Light_ADDR); //initialize light sensor
  Wire.write(0b00000001);
  Wire.endTransmission();

  dht22.begin();
  
  ui.setIndicatorPosition(BOTTOM);          // TOP, LEFT, BOTTOM, RIGHT
  ui.setIndicatorDirection(LEFT_RIGHT);     // Defines where the first frame is located in the bar.  
  ui.setFrameAnimation(SLIDE_LEFT);         // SLIDE_LEFT, SLIDE_RIGHT, SLIDE_TOP, SLIDE_DOWN
  ui.setFrames(frames, numberOfFrames);
  ui.setOverlays(overlays, numberOfOverlays);
  ui.init();
  updateData(&display);  
}

// Function to connect and reconnect as necessary to the MQTT server.
void MQTT_connect() {
  if (mqtt.connected()) return;
  blink(3);
  Serial.print("Connecting to MQTT... ");
  uint8_t retries = 3;
  int ret;
  while ((ret = mqtt.connect()) != 0) {
    blink(3);
    Serial.println(mqtt.connectErrorString(ret));
    Serial.println("Retrying MQTT connection in 5 seconds...");
    mqtt.disconnect();
    delay(5000);  // wait 5 seconds
    retries--;
    while (!retries) {blink(2); delay(3000);}; // die and wait for WDT to reset me
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
  Serial.println("updateData");
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
  Serial.println("updateData DONE");
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
  sprintf_P(buff, PSTR("Temp: %d"), _Temp);           display->drawString(x, 5 + y, String(buff));
  sprintf_P(buff, PSTR("Light: %d"), _Light);         display->drawString(x, 15 + y, String(buff));
  sprintf_P(buff, PSTR("Humi: %d"), _Humi);           display->drawString(x, 25 + y, String(buff));
  sprintf_P(buff, PSTR("Barometric: %d hPa"), _Baro); display->drawString(x, 35 + y, String(buff));
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

void readTemperatureHumidity(){
  int j;
  unsigned int loopCnt;
  int chr[40] = {0};
  unsigned long time1;

  //DHT.read(DHT11_PIN);
  //_Temp = DHT.temperature;
  //_Humi = DHT.humidity;
  _Temp = dht22.readTemperature(false);
  _Humi = dht22.readHumidity();
}

void readLight(){
  Wire.beginTransmission(Light_ADDR);
  Wire.write(0b00000111); //Reset
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
  _Baro = bmp.readPressure() / 100;
}

//upload temperature humidity data to thinkspak.com
void uploadMQTT(){
  MQTT_connect();
  Serial.println("Uploading MQTT");
  //if (_Temp)    
  if (! mqtt_Temp.publish(_Temp)) Serial.printf("Failed temperature %d\n",_Temp);
  if (_Light)   if (! mqtt_Light.publish(_Light)) Serial.printf("Failed temperature %d\n",_Light);
  if (_Baro)    if (! mqtt_Baro.publish(_Baro)) Serial.printf("Failed temperature %d\n",_Baro);
  //if (_Humi)
  if (! mqtt_Humi.publish(_Humi)) Serial.printf("Failed temperature %d\n",_Humi);
}

void loop() {  
  if(millis() - readTime > 5000) {   //Read Temperature Humidity every 5 seconds
    readTemperatureHumidity();
    readLight();
    readAtmosphere();
    readTime = millis();
    Serial.printf("Temp: %d, Humi: %d, Barometric: %d hPa, Light: %d\n",_Temp,_Humi,_Baro,_Light);
    blink(1);
  }
  //Upload Temperature Humidity every 60 seconds
  if(millis() - uploadTime > 60000){
    uploadMQTT();
    uploadTime = millis();
    blink(3);
  }
  if (millis() - timeSinceLastWUpdate > (1000L*UPDATE_INTERVAL_SECS)) {
    timeSinceLastWUpdate = millis();
    Serial.println("Setting readyForUpdate to true");
    readyForWeatherUpdate = true;
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
