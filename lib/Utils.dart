import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tech_pool/pages/HomePage.dart';

/// Apps default settings
MaterialColor mainColor =  Colors.cyan;
Color secondColor = Color(0xff308ea1);
BorderRadius containerBorderRadius = BorderRadius.all(Radius.circular(8));
final tomTomKey = "UR1weKNyAuCWxJIB64AUrpiB8TDhdc6N";

double fontTextsSize = 17;
double lablesTextsSize = 19;
///user repository for the app, should be supplied at the very top of the widget tree
///will manage the User state, info and Authentication.
///[auth] is the entry point for firebase Authentication.
///[user] is the current user using the app.
class UserRepository extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  Image _profilePicture;
  User _user;

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  set profilePicture(Image pic){
    _profilePicture = pic;
    notifyListeners();
  }

  User get user => _user;

  Image get profilePicture => _profilePicture;
}

/// A container class for Drive event.
class Drive{
  String info;
  int numberOfSeats;
  int numberOfPassengers;
  DateTime dateTime;
  Drive(this.info,this.numberOfSeats,this.numberOfPassengers,this.dateTime);
}

/// A container class for Lift event.
class Lift{
  String info;
  int numberOfSeats;
  int numberOfPassengers;
  DateTime dateTime;
  Lift(this.info,this.numberOfSeats,this.numberOfPassengers,this.dateTime);
}
/*
/// A container class for DesiredLift event.
class DesiredLift{
  String info;
  DesiredLift(this.info);
}

/// A container class for DesiredDrive event.
class DesiredDrive{
  String info;
  DesiredDrive(this.info);
}*/

class LocationsResult{
  Address fromAddress;
  Address toAddress;
  List<Address> stopAddresses;
  int numberOfStops;
  LocationsResult(this.fromAddress, this.toAddress,this.stopAddresses,this.numberOfStops);
}

/// A util function for the calendar, returns the desired event container to
/// display under the calendar, according to the type of event received.
Widget transformEvent(dynamic event){
  if (event is Drive) {
    return calendarListTile(event, Icon(Icons.directions_car,size: 30, color: mainColor,));
  } else if (event is Lift) {
    return calendarListTile(event, Transform.rotate(angle: 0.8,child: Icon(Icons.thumb_up_rounded,size: 30, color: mainColor)));
    /*return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin:
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(leading: Transform.rotate(angle: 0.8,child: Icon(Icons.thumb_up_rounded,size: 30, color: mainColor,)),
        title: Text(event?.info),
        onTap: () => print('$event tapped!'),
      ),
    );*/
  /*} else if (event is DesiredLift) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin:
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(leading: Transform.rotate(angle: 0.8,child: Icon(Icons.thumb_up_rounded,size: 30, color: mainColor,)),
        title: Text(event?.info),
        onTap: () => print('$event tapped!'),
      ),
    );*/
  }
  else{
    return null;
  }
}

Container calendarListTile(dynamic event,Widget leadingWidget) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black,blurRadius: 2.0,
        spreadRadius: 0.0,offset: Offset(2.0, 2.0))],
      border: Border.all(color: Colors.green, width: 0.8),
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin:
    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: ListTile(leading: leadingWidget,
      title: Text(event?.info),
      onTap: () => print('$event tapped!'),
    subtitle: Row(mainAxisAlignment: MainAxisAlignment.start,children: [Text("${event.dateTime.hour}:${event.dateTime.minute}"),Spacer(),Icon(Icons.person,color: Colors.black,),Text(": ${event.numberOfPassengers} / ${event.numberOfSeats}",style: TextStyle(color: Colors.black),)],),
    trailing: Icon(Icons.chevron_right_sharp,color: Colors.black,size:30,)),
  );
}

double clacDis(GeoPoint from,Coordinates to){
  return (Geolocator.distanceBetween(from.latitude,from.longitude,to.latitude,to.longitude).abs());
}

class MyLift{
  String destCity;
  String startCity;
  String destAddress;
  String startAddress;
  String note;
  int dist;
  List<String> passengers;
  int numberOfSeats;
  int price;
  DateTime time;
  String driver;
  MyLift(this.driver,this.destCity,this.startCity,this.numberOfSeats);
  GeoPoint  destPoint;
  GeoPoint startPoint;
  bool bigTrunk;
  bool backSeat;
  var stops = new Map();

  void setProperty(String key,var property){
    switch(key) {

      case "Driver": {  this.driver=property; }
      break;

      case "DestCity": {  this.destCity=property; }
      break;

      case "StartCity": {  this.startCity=property; }
      break;

      case "DestAddress": {  this.destAddress=property; }
      break;

      case "StartAddress": {
        this.startAddress=property;
      }
      break;

      case "Note": {
        this.note=property;
      }
      break;

      case "TimeStamp": {  this.time= (property as Timestamp).toDate().add(Duration(days: 0,hours: 0,minutes: 0,microseconds: 0)); }
      break;

      case "NumberSeats": {  this.numberOfSeats = property; }
      break;

      case "Price": {  this.price = property; }
      break;

      case "Passengers": {  passengers=List.from(property); }
      break;

      case "DestPoint": { destPoint = property;}
      break;

      case "StartPoint": { startPoint = property;}
      break;

      case "Stops": {stops = property;}
      break;

      case "BigTrunk": { bigTrunk = property;}
      break;

      case "BackSeatNotFull":{ backSeat = property;}
      break;


      default: { }
      break;
    }}
}

class liftRes{
  DateTime fromTime;
  DateTime toTime;
  int indexDist;
  Address startAddress;
  Address destAddress;
  bool backSeat;
  bool bigTrunk;

  liftRes({@required this.fromTime,@required this.toTime,@required this.indexDist,@required this.startAddress,@required this.destAddress, @required this.backSeat, @required this.bigTrunk});
}

/// enum to specify from which page the drawer is called
enum DrawerSections { home, profile, notifications, favorites, chats, settings }

/// returns a Drawer, with the user information from userRep, and highlithing
/// and not rebuilding the current section (page).
SafeArea techDrawer(UserRepository userRep, BuildContext context,
    DrawerSections currentSection) {
  return SafeArea(child: ClipRRect(
      borderRadius: BorderRadius.only(topRight: Radius.circular(20.0),bottomRight:Radius.circular(20.0)),child: Container(width: MediaQuery.of(context).size.width*0.7,
        child: Drawer(
        child: ListView(children: [
          /*  UserAccountsDrawerHeader(
              accountName: Text("Hello, ${userRep.user.displayName}.",style: TextStyle(color: Colors.white,fontSize: 18),),
              accountEmail: Container(height: 20,child: Row(crossAxisAlignment: CrossAxisAlignment.end,mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            Text(userRep.user.email,style: TextStyle(color: Colors.white,fontSize: 14)),
           IconButton(icon: Icon(Icons.logout,color: Colors.white,size: 25,),onPressed: () => {},)]))
     ,currentAccountPicture: CircleAvatar(backgroundColor: secondColor,))*/
          Container(
            color: mainColor,
            height: 180,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: secondColor,
                    radius: 40,
                    backgroundImage: userRep.profilePicture.image,
                  ),
                  Spacer(),
                  Row(mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(flex: 5,child: Text("Hello, ${userRep.user?.displayName}.",
                        style: TextStyle(color: Colors.white, fontSize: 20))),
                    Flexible(flex: 1,child: IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () async => await (userRep.auth
                          .signOut()
                          .then((_) {
                        Navigator.pop(context);
                        userRep.user = null;
                        Navigator.pop(context);
                      })),
                    ))
                  ])
                ],
              ),
            ),
          ),
          drawerListTile("Home",Icons.home_rounded,DrawerSections.home,currentSection, context),
          drawerListTile("Profile",Icons.person,DrawerSections.profile,currentSection, context),
          drawerListTile("Notifications",Icons.notifications,DrawerSections.notifications,currentSection, context),
          drawerListTile("Favorite Locations",Icons.favorite,DrawerSections.favorites,currentSection, context),
          drawerListTile("Chats",Icons.chat,DrawerSections.chats,currentSection, context),
          drawerListTile("Settings",Icons.settings,DrawerSections.settings,currentSection, context),
        ])),
      )));
}

/// creates a listTile for the drawer, with the relevant pageName,icon,tileSection for the tile.
/// and the currentSection of the drawer.
ListTile drawerListTile(String pageName,IconData icon,DrawerSections tileSection,DrawerSections currentSection, BuildContext context) {
  return ListTile(
    selected: currentSection == tileSection,
    leading: Icon(
      icon,
      color: mainColor,
      size: 30,
    ),
    title: Text(
      pageName,
      style: TextStyle(fontSize: 12),
    ),
    onTap: () {
      if (currentSection == tileSection) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        switch(tileSection) {
          case DrawerSections.home:
            {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()));
              break;
            }
          case DrawerSections.profile: {
            break;
          }
          case DrawerSections.notifications: {
            break;
          }
          case DrawerSections.favorites:{
            break;
          }
          case DrawerSections.chats: {
            break;
          }
          case DrawerSections.settings: {
            break;
          }
        }
      }
    },
  );
}

/// the decoration for the container inside the page body.
final pageContainerDecoration = BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(20.0)),
  boxShadow: [BoxShadow(color: Colors.black,blurRadius: 4.0,
      spreadRadius: 0.0,offset: Offset(0.0, 1.0))],);
/// the margin for the container inside the page body.
final pageContainerMargin = EdgeInsets.fromLTRB(10, 4, 10, 10);