#ifndef PRIVATECREDENTIAL
#define PRIVATECREDENTIAL

ÆNDRE WIFI indstillinger i denne fil, og udkommenter denne linje
#define WLAN_SSID       "minWifi"
#define WLAN_PASS       "mitWifiPW"

// Sign up here to get an API key:
// https://docs.thingpulse.com/how-tos/openweathermap-key/
ÆNDRE thingpulse indstillinger i denne fil, og udkommenter denne linje
#define OPEN_WEATHER_MAP_APP_ID "XXXXXXXXXXXX"
#define OPEN_WEATHER_MAP_LOCATION_ID "2615730" // 2615730=Ølstykke.  updateForecasts vs updateForecastsById
// Test in a browser against https://api.openweathermap.org/data/2.5/weather?id=2615730&appid=1f51750fXXXXXXXXXXX&units=metric&lang=en
// Put in your own API key

ÆNDRE AdaFruit indstillinger i denne fil, og udkommenter denne linje
#define AIO_SERVER      "io.adafruit.com"
#define AIO_SERVERPORT  8883 //MQTTS
// Adafruit IO Account Configuration (to obtain these values, visit https://io.adafruit.com and click on API Key in top right corner)

//https://io.adafruit.com/ChristenFihl/
#define AIO_USERNAME  "ChristenFihlXXXXXXXXX"
#define AIO_KEY       "ed7fbdXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

static const char *AIO_FINGERPRINT PROGMEM = "4E C1 52 73 24 A8 36 D6 7A 4C 67 C7 91 0C 0A 22 B9 2D 5B CA";
// io.adafruit.com SHA1 fingerprint
/* WARNING - This value was last updated on 08/15/22 and may not be up-to-date!
*  If security is a concern for your project, we strongly recommend users impacted by this moving
*  to ESP32 which has certificate verification by storing root certs and having a
*  chain-of-trust rather than doing individual certificate fingerprints.
*/

#endif
