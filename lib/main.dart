import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(
  MaterialApp(
    title: "Weather App",
    home: Home(),
  )
);

class Home extends  StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var temp;
  var deskripsi;
  var saat_ini;
  var kelembapan;
  var kecepatan_angin;
  var myLocation;

  Position currentPosition;
  String currentAddress;

  getCurrentLocation(){
    Geolocator
    .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then ((Position position){
          setState(() {
            currentPosition = position;
            getAddressFromLatLng();

          });
    }).catchError((e){
      print(e.toString());
    });
  }

  getAddressFromLatLng() async{
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        currentAddress = "${place.subLocality}";
        myLocation = currentAddress != null ? currentAddress : "JAKARTA";
        getWeather();
    });

    }catch (e) {
      print(e.toString());
    }
  }

  getWeather() async {
    http.Response response = await http.get("https://api.openweathermap.org/data/2.5/weather?q="+myLocation.toString()+"&units=metric&lang=id&appid=ca6fb85bcfa0fd62360994d036a31b04");
    var result = jsonDecode(response.body);
      setState((){
        this.temp = result['main']['temp'];
        this.deskripsi = result['weather'][0]['description'];
        this.saat_ini = result['weather'][0]['main'];
        this.kelembapan = result['main']['humidity'];
        this.kecepatan_angin = result['wind']['speed'];
    });
  }

  @override
  void initState (){
    super.initState();
    this.getCurrentLocation();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 100, left: 20, right: 20),
              child: TextField(
                onChanged: (value) {},
                style: TextStyle(
                  color: Colors.blue,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {},
                decoration: InputDecoration(
                  suffix: Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  hintStyle: TextStyle(color: Colors.blue),
                  hintText: 'Search'.toUpperCase(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 3,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.lightGreenAccent,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(myLocation != null ? "Wilayah "+ myLocation.toString() : "Wilayah DEPOK",
                        style: TextStyle(color: Colors.red,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text(temp != null ? temp.toString() +"\u00B0" : "Loading",
                      style: TextStyle(color: Colors.red,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w600)),
                  Padding(padding: EdgeInsets.only(top: 10.0),
                    child: Text(saat_ini != null ? saat_ini.toString() : "Loading",
                      style: TextStyle(color: Colors.red,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.thermometerHalf),
                      title: Text("TEMPERATUR"),
                      trailing: Text(temp != null ? temp.toString() +"\u00B0" : "Loading")
                    ),
                    ListTile(
                        leading: FaIcon(FontAwesomeIcons.cloud),
                        title: Text("CUACA"),
                        trailing: Text(deskripsi != null ? deskripsi.toString() +"\u00B0" : "Loading")
                    ),
                    ListTile(
                        leading: FaIcon(FontAwesomeIcons.sun),
                        title: Text("KELEMBAPAN"),
                        trailing: Text(kelembapan != null ? kelembapan.toString() +"\u00B0" : "Loading")
                    ),
                    ListTile(
                        leading: FaIcon(FontAwesomeIcons.wind),
                        title: Text("KECEPATAN ANGIN"),
                        trailing: Text(kecepatan_angin != null ? kecepatan_angin.toString() +"\u00B0" : "Loading")
                    ),
                  ],
                ),
              ),
            ),
          ],
        )

    );
  }
}