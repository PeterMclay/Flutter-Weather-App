import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather.dart';
import 'package:weatherapp/constants.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTemp;
  int feelsLikeTemp;
  int humidity, pressure, visibilty, uvi;
  List<String> sunriseSunset;
  String condition;
  String backgroundImage;
  List windData;
  String windColor;
  Color backgroundColor;

  String wind = 'Calm';
  String angle = 'North East';
  final List<Precipitation> precipitationEntries = <Precipitation>[];
  final List<HourlyForcast> hourlyEntries = <HourlyForcast>[];
  final List<Wind> windEntries = <Wind>[];

  @override
  void initState() {
    super.initState();
  }

  Future getLocationData() async {
    precipitationEntries.clear();
    hourlyEntries.clear();
    windEntries.clear();
    WeatherData weatherData = WeatherData();
    await weatherData.getLocationData();
    currentTemp = weatherData.getCurrentTemperature();
    feelsLikeTemp = weatherData.getCurrentFeelsLikeTemperature();
    humidity = weatherData.getCurrentHumidity();
    pressure = weatherData.getCurrentPressure();
    visibilty = weatherData.getCurrentVisibility();
    uvi = weatherData.getCurrentUVI();
    sunriseSunset = weatherData.getCurrentSunriseSunrset();
    condition = weatherData.getCurrentCondition();
    backgroundImage = weatherData.getCurrentBackground();
    backgroundColor = kBackgroundColor[backgroundImage];

    windData = weatherData.getCurrentWindInfo();
    if (windData[0] >= 50) {
      windColor = 'Gale-force';
    } else if (windData[0] < 50 && windData[0] >= 38) {
      windColor = 'Strong';
    } else if (windData[0] < 38 && windData[0] >= 29) {
      windColor = 'Fresh';
    } else if (windData[0] < 29 && windData[0] >= 20) {
      windColor = 'Moderate';
    } else if (windData[0] < 20 && windData[0] >= 6) {
      windColor = 'Light';
    } else {
      windColor = 'Calm';
    }

    for (int i = 1; i <= 15; i++) {
      String time = weatherData.getFutureTime(type: 'hourly', index: i);
      String icon = weatherData.getFutureIcon(type: 'hourly', index: i);
      int temp = weatherData.getFutureTemperature(type: 'hourly', index: i);
      hourlyEntries.add(HourlyForcast(time: time, icon: icon, temp: temp));
    }

    for (int i = 1; i <= 15; i++) {
      String time = weatherData.getFutureTime(type: 'hourly', index: i);
      int percent = weatherData.getFuturePop(type: 'hourly', index: i);
      double amount = weatherData.getRainAmount(type: 'hourly', index: i);
      String icon;
      if (percent > 75) {
        icon = '100';
      } else if (percent <= 75 && percent > 50) {
        icon = '75';
      } else if (percent <= 50 && percent < 25) {
        icon = '50';
      } else {
        icon = '25';
      }
      precipitationEntries.add(Precipitation(
          time: time, percent: percent, icon: icon, amount: amount));
    }

    for (int i = 1; i <= 15; i++) {
      String time = weatherData.getFutureTime(type: 'hourly', index: i);
      List windData = weatherData.getFutureWindInfo(index: i);
      int speed = windData[0];
      String direction = windData[1];
      String windColor;
      if (speed >= 50) {
        windColor = 'Gale-force';
      } else if (speed < 50 && speed >= 38) {
        windColor = 'Strong';
      } else if (speed < 38 && speed >= 29) {
        windColor = 'Fresh';
      } else if (speed < 29 && speed >= 20) {
        windColor = 'Moderate';
      } else if (speed < 20 && speed >= 6) {
        windColor = 'Light';
      } else {
        windColor = 'Calm';
      }
      windEntries.add(Wind(
          time: time,
          speed: speed,
          windColor: windColor,
          direction: direction));
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF2298da),
      child: FutureBuilder(
        future: getLocationData(),
        builder: (context, snapshot) {
          //Has Data

          if (snapshot.hasData) {
            return Container(
              color: backgroundColor,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    textTheme: TextTheme(headline1: kLocationTextStyle),
                    backgroundColor: backgroundColor,
                    title: Text('Kingston, ON'),
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    snap: false,
                    floating: false,
                    pinned: true,
                    stretch: true,
                    expandedHeight: 725,
                    elevation: 0,
                    shadowColor: null,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/$backgroundImage.png'),
                              fit: BoxFit.cover),
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 525),
                            Text('$currentTemp°', style: kTemperatureTextStyle),
                            Text('$condition', style: kFeelsLikeTextStyle),
                            Text('Feels like $feelsLikeTemp°',
                                style: kFeelsLikeTextStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        color: Color(0xFFE6E6E5),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 4.0),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.0)),
                              color: Colors.grey[400],
                            ),
                            height: 2.0,
                            width: 80.0,
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child: SizedBox(
                              height: 115.0,
                              child: ListView.builder(
                                itemCount: hourlyEntries.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return hourlyEntries[index];
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Divider(
                            thickness: 1.0,
                          ),
                          Container(
                            child: Text('Current Details',
                                style: kBlackTextStyle,
                                textAlign: TextAlign.left),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            child: CurrentDetails(
                              humidity: humidity,
                              pressure: pressure,
                              visibility: visibilty,
                              uvIndex: uvi,
                              sunrise: sunriseSunset[0],
                              sunset: sunriseSunset[1],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Divider(
                            thickness: 1.0,
                          ),
                          Container(
                            child: Text('Precipitation',
                                style: kBlackTextStyle,
                                textAlign: TextAlign.left),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            child: SizedBox(
                              height: 110.0,
                              child: ListView.builder(
                                itemCount: precipitationEntries.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return precipitationEntries[index];
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Divider(
                            thickness: 1.0,
                          ),
                          Container(
                            child: Text('Wind', style: kBlackTextStyle),
                          ),
                          SizedBox(height: 8.0),

                          ////////////////////////// WIND  ////////////////////////////////
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${windData[0]}',
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Column(
                                children: <Widget>[
                                  Transform.rotate(
                                    angle: windAngle[windData[1]],
                                    child: Icon(
                                      Icons.navigation,
                                      color: windStrength[windColor],
                                      size: 18.0,
                                    ),
                                  ),
                                  Text(
                                    'km/h',
                                    style: TextStyle(
                                        color: Color(0xFF5E5E5F),
                                        fontSize: 12.0),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    windColor,
                                    style: kSmallBlackTextStyle,
                                  ),
                                  Text(
                                    'From ${windData[1]}',
                                    style: kGreyTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            child: SizedBox(
                              height: 75.0,
                              child: ListView.builder(
                                itemCount: windEntries.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return windEntries[index];
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),

                          SizedBox(height: 150.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          //Else Does Not have Data
          else {
            return Center(
              child: Container(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

//  Classes //

class HourlyForcast extends StatelessWidget {
  String time, icon;
  int temp;
  HourlyForcast({this.time, this.icon, this.temp});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: <Widget>[
            Text(
              '$temp°',
              style: TextStyle(
                  decoration: null,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            SizedBox(height: 8.0),
            Image.asset('images/$icon.png', width: 50, height: 50),
            SizedBox(height: 8.0),
            Text(
              '$time',
              style: kGreyTextStyle,
            ),
            SizedBox(width: 65),
          ],
        ),
        VerticalDivider(thickness: 1.0),
      ],
    );
  }
}

class Precipitation extends StatelessWidget {
  String time;
  String icon;
  int percent;
  double amount;
  Precipitation({this.time, this.icon, this.percent, this.amount});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: <Widget>[
            Text(
              '$percent%',
              style: TextStyle(
                  decoration: null,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            Text(
              '${amount}mm',
              style: TextStyle(
                  decoration: null,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
            ),
            Image.asset('images/$icon.png', width: 50, height: 50),
            SizedBox(height: 4.0),
            Text(
              '$time',
              style: kGreyTextStyle,
            ),
            SizedBox(width: 65),
          ],
        ),
        VerticalDivider(thickness: 1.0),
      ],
    );
  }
}

class CurrentDetails extends StatelessWidget {
  int humidity, pressure, visibility, uvIndex;
  String sunrise, sunset;
  CurrentDetails(
      {this.humidity,
      this.pressure,
      this.visibility,
      this.uvIndex,
      this.sunrise,
      this.sunset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Humidity', style: kGreyTextStyle),
                Text('$humidity%', style: kSmallBlackTextStyle),
              ],
            ),
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Pressure', style: kGreyTextStyle),
                Text('$pressure mb', style: kSmallBlackTextStyle),
              ],
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Visibility', style: kGreyTextStyle),
                Text('$visibility km', style: kSmallBlackTextStyle),
              ],
            ),
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('UV Index', style: kGreyTextStyle),
                Text('$uvIndex, low', style: kSmallBlackTextStyle),
              ],
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Sunrise', style: kGreyTextStyle),
                Text('$sunrise', style: kSmallBlackTextStyle),
              ],
            ),
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Sunset', style: kGreyTextStyle),
                Text('$sunset', style: kSmallBlackTextStyle),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class Wind extends StatelessWidget {
  String time, windColor, direction;
  int speed;
  Wind({this.time, this.speed, this.direction, this.windColor});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: <Widget>[
            Text(
              '$speed km/h',
              style: TextStyle(
                  decoration: null,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            SizedBox(height: 8.0),
            Transform.rotate(
              angle: windAngle[direction],
              child: Icon(
                Icons.navigation,
                color: windStrength[windColor],
                size: 24.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '$time',
              style: kGreyTextStyle,
            ),
            SizedBox(width: 65),
          ],
        ),
        VerticalDivider(thickness: 1.0),
      ],
    );
  }
}