import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather.dart';
import 'package:weatherapp/constants.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:weatherapp/services/keys.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _MainScreenState extends State<MainScreen> {
  bool refreshUI;
  bool citySearch = false;
  IconData gpsOn = Icons.gps_fixed;
  String address;
  double lat, lng;
  int currentTemp;
  int feelsLikeTemp;
  int humidity, pressure, visibilty, uvi;
  List<String> sunriseSunset;
  int condition;
  String backgroundImage;
  List windData;
  String windColor;
  Color backgroundColor;
  String displayDate;
  bool isNightTime;

  String wind = 'Calm';
  String angle = 'North East';
  final List<Precipitation> precipitationEntries = <Precipitation>[];
  final List<HourlyForcast> hourlyEntries = <HourlyForcast>[];
  final List<Wind> windEntries = <Wind>[];
  final List<DailyForcast> dailyForcastEntries = <DailyForcast>[];

  @override
  void initState() {
    refreshUI = true;
    citySearch = false;
    lat = 0;
    lng = 0;
    backgroundColor = kColorDay;
    super.initState();
  }

  Future getLocationData() async {
    if (refreshUI) {
      WeatherData weatherData =
          WeatherData(citySearch: citySearch, latitude: lat, longitude: lng);
      await weatherData.getLocationData();
      setState(() {
        address = weatherData.getAddress();
        precipitationEntries.clear();
        hourlyEntries.clear();
        windEntries.clear();
        dailyForcastEntries.clear();
        currentTemp = weatherData.getCurrentTemperature();
        feelsLikeTemp = weatherData.getCurrentFeelsLikeTemperature();
        humidity = weatherData.getCurrentHumidity();
        pressure = weatherData.getCurrentPressure();
        visibilty = weatherData.getCurrentVisibility();
        uvi = weatherData.getCurrentUVI();
        sunriseSunset = weatherData.getCurrentSunriseSunrset();
        condition = weatherData.getCurrentCondition(type: 'current', index: 0);
        windData = weatherData.getCurrentWindInfo();

        isNightTime = weatherData.isNightTime();
        if (isNightTime) {
          if (kWeatherCondition[condition][1] == 'clear' ||
              kWeatherCondition[condition][1] == 'partly_cloudy') {
            backgroundImage = kWeatherCondition[condition][1] + '_n';
          } else {
            backgroundImage = kWeatherCondition[condition][1];
          }
          backgroundColor = kColorNight;
        } else {
          backgroundColor = kColorDay;
          backgroundImage = kWeatherCondition[condition][1];
        }

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

        //Daily Forcast Entry Builder
        for (int i = 0; i <= 7; i++) {
          String date = weatherData.getFutureTime(type: 'daily', index: i);
          int pop = weatherData.getFuturePop(type: 'daily', index: i);
          List<int> temp = weatherData.getDailyMinDay(index: i);
          int condition =
              weatherData.getCurrentCondition(type: 'daily', index: i);
          if (i == 0) {
            displayDate = date;
            date = 'Today';
          }
          dailyForcastEntries.add(DailyForcast(
              date: date,
              pop: pop,
              tempL: temp[0],
              tempH: temp[1],
              icon: kWeatherCondition[condition][1],
              condition: kWeatherCondition[condition][0]));
        }

        //Hourly Temp Builder
        for (int i = 1; i <= 15; i++) {
          String time = weatherData.getFutureTime(type: 'hourly', index: i);
          time = time.toLowerCase();
          int condition =
              weatherData.getCurrentCondition(type: 'hourly', index: i);
          String icon;
          if (weatherData.nightOrDayIcon(i)) {
            icon = kWeatherCondition[condition][1] + '_n';
          } else {
            icon = kWeatherCondition[condition][1];
          }
          int temp = weatherData.getFutureTemperature(type: 'hourly', index: i);
          hourlyEntries.add(HourlyForcast(
            time: time,
            icon: icon,
            temp: temp,
            condition: kWeatherCondition[condition][0],
          ));
        }

        //Hourly Rain Builder
        for (int i = 1; i <= 15; i++) {
          String time = weatherData.getFutureTime(type: 'hourly', index: i);
          int percent = weatherData.getFuturePop(type: 'hourly', index: i);
          double amount = weatherData.getRainAmount(type: 'hourly', index: i);
          String icon;
          if (percent >= 75) {
            icon = '75';
          } else if (percent < 75 && percent >= 50) {
            icon = '50';
          } else if (percent < 50 && percent >= 25) {
            icon = '25';
          } else {
            icon = '0';
          }
          precipitationEntries.add(Precipitation(
              time: time.toLowerCase(),
              percent: percent,
              icon: icon,
              amount: amount));
        }

        //Hourly Wind Builder
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
              time: time.toLowerCase(),
              speed: speed,
              windColor: windColor,
              direction: direction));
        }
        refreshUI = false;
      });
    }
    return 1;
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      //onError: onError,
      mode: Mode.fullscreen,
      logo: Row(),
      language: "en",
      components: [
        Component(Component.country, "ca"),
        Component(Component.country, "us")
      ],
    );
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      lat = detail.result.geometry.location.lat;
      lng = detail.result.geometry.location.lng;
      setState(() {
        gpsOn = Icons.gps_not_fixed;
      });
      citySearch = true;
      refreshUI = true;
      getLocationData();
    }
  }

  void _gpsButton() async {
    refreshUI = true;
    citySearch = false;
    getLocationData();
    setState(() {
      gpsOn = Icons.gps_fixed;
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    refreshUI = true;
    await getLocationData();
    //await Future.delayed(Duration(milliseconds: 1000));
    print('onRefresh Called');
    _refreshController.refreshCompleted();
  }

  PageController controller;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Material(
      color: backgroundColor,
      child: FutureBuilder(
        future: getLocationData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SmartRefresher(
              enablePullUp: false,
              enablePullDown: true,
              header: MaterialClassicHeader(
                color: Color(0xFFF8F16C),
                backgroundColor: backgroundColor,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    key: homeScaffoldKey,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(gpsOn),
                        onPressed: () {
                          _gpsButton();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _handlePressButton();
                        },
                      ),
                    ],
                    backgroundColor: backgroundColor,
                    automaticallyImplyLeading: false,
                    snap: false,
                    floating: false,
                    pinned: true,
                    stretch: false,
                    primary: true,
                    expandedHeight: height * 0.75,
                    elevation: 0,
                    shadowColor: null,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '$address',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                                '${kWeatherCondition[condition][0]}, Feels Like $feelsLikeTemp°',
                                style: kFeelsLikeTextStyle),
                            SizedBox(height: 8.0),
                            Text('$currentTemp°', style: kTemperatureTextStyle),
                            SizedBox(height: 40.0),
                            SvgPicture.asset(
                              'assets/images/$backgroundImage.svg',
                              height: height * 0.10,
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/humidity.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Humidity',
                                      style: kWhiteTextStyle,
                                    ),
                                    Text(
                                      '$humidity%',
                                      style: kFeelsLikeTextStyle,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/pressure.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Pressure',
                                      style: kWhiteTextStyle,
                                    ),
                                    Text(
                                      '${pressure}mBar',
                                      style: kFeelsLikeTextStyle,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/wind.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Wind',
                                      style: kWhiteTextStyle,
                                    ),
                                    Text(
                                      '${windData[0]}km/h',
                                      style: kFeelsLikeTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/sunrise.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Sunrise',
                                      style: kWhiteTextStyle,
                                    ),
                                    Text(
                                      '${sunriseSunset[0]}',
                                      style: kFeelsLikeTextStyle,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/sunset.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Sunset',
                                      style: kWhiteTextStyle,
                                    ),
                                    Text(
                                      '${sunriseSunset[1]}',
                                      style: kFeelsLikeTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        //color: Color(0xFFE6E6E5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                                color: Colors.grey[600],
                              ),
                              height: 2.0,
                              width: 40.0,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text('$displayDate', style: kTitleTextStyle),
                          SizedBox(height: 16.0),
                          Container(
                            child: SizedBox(
                              height: 120.0,
                              child: ListView.builder(
                                itemCount: hourlyEntries.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return hourlyEntries[index];
                                },
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.0,
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child:
                                Text('Precipitation', style: kTitleTextStyle),
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child: SizedBox(
                              height: 120.0,
                              child: ListView.builder(
                                itemCount: precipitationEntries.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return precipitationEntries[index];
                                },
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.0,
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child: Text('Wind', style: kTitleTextStyle),
                          ),
                          SizedBox(height: 16.0),
                          Row(
                            children: <Widget>[
                              Text(
                                '${windData[0]}',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: windStrength[windColor],
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Column(
                                children: <Widget>[
                                  Transform.rotate(
                                    angle: -windAngle[windData[1]],
                                    child: SvgPicture.asset(
                                      'assets/wind.svg',
                                      color: windStrength[windColor],
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  Text('km/h',
                                      style: TextStyle(
                                        color: windStrength[windColor],
                                        fontFamily: 'Nunito',
                                        fontSize: 11.0,
                                      )),
                                ],
                              ),
                              SizedBox(width: 24.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    windColor,
                                    style: kBlackTextStyle,
                                  ),
                                  Text(
                                    'From ${windData[1]}',
                                    style: kGreyTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child: SizedBox(
                              height: 100.0,
                              child: ListView.builder(
                                itemCount: windEntries.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return windEntries[index];
                                },
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.0,
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child:
                                Text('Daily Forcast', style: kTitleTextStyle),
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            child: SizedBox(
                              height: 300.0,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: dailyForcastEntries.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return dailyForcastEntries[index];
                                },
                              ),
                            ),
                          ),

                          //SizedBox(height: 150.0),
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
                color: backgroundColor,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8F16C)),
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
  String time, icon, condition;
  int temp;
  HourlyForcast({this.time, this.icon, this.temp, this.condition});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: <Widget>[
            Text(
              '$time',
              style: kBlackTextStyle,
            ),
            SizedBox(height: 16.0),
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              width: 20,
              height: 20,
              color: Colors.grey[500],
            ),
            SizedBox(height: 16.0),
            Text(
              '$temp°',
              style: kTitleTextStyle,
            ),
            //SizedBox(height: 8.0),
            Text(
              '$condition',
              style: TextStyle(
                  color: const Color(0xFF5E5E5F),
                  fontFamily: 'Nunito',
                  fontSize: 11.0),
            ),
            SizedBox(width: 95),
          ],
        ),
        //VerticalDivider(thickness: 0.5),
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
              '$time',
              style: kBlackTextStyle,
            ),
            SizedBox(height: 16.0),
            SvgPicture.asset('assets/$icon.svg', width: 20, height: 20),
            SizedBox(height: 16.0),
            Text(
              '$percent%',
              style: kTitleTextStyle,
            ),
            Text(
              '${amount}mm',
              style: TextStyle(
                  color: Color(0xFF2CA4CC),
                  fontFamily: 'Nunito',
                  fontSize: 11.0),
            ),
            SizedBox(width: 95),
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
              '$time',
              style: kBlackTextStyle,
            ),
            SizedBox(height: 16.0),
            Transform.rotate(
              angle: -windAngle[direction],
              child: SvgPicture.asset(
                'assets/wind.svg',
                color: windStrength[windColor],
                width: 20,
                height: 20,
              ),
            ),
            SizedBox(height: 16.0),
            Text('$speed km/h', style: kTitleTextStyle),
            SizedBox(width: 95),
          ],
        ),
      ],
    );
  }
}

class DailyForcast extends StatelessWidget {
  String date, icon, condition;
  int tempH, tempL, pop;
  String _pop(pop) {
    if (pop != 0) {
      return '$pop%';
    } else {
      return '';
    }
  }

  DailyForcast(
      {this.icon, this.tempH, this.tempL, this.date, this.pop, this.condition});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$date', style: kBlackTextStyle),
                SizedBox(height: 4.0),
                Text(
                  '$condition',
                  style: kGreyTextStyle,
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _pop(pop),
                    style: TextStyle(
                      color: Color(0xFF2CA4CC),
                      fontFamily: 'Nunito',
                      fontSize: 11.0,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  SvgPicture.asset(
                    'assets/icons/$icon.svg',
                    width: 30,
                    height: 30,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    children: [
                      Text(
                        '$tempH°',
                        style: kTitleTextStyle,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '$tempL°',
                        style: kGreyTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(
            thickness: 0.5,
            indent: 5.0,
            endIndent: 5.0,
          ),
        ),
      ],
    );
  }
}
