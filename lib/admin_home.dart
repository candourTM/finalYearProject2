import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final dbRef = FirebaseDatabase.instance.reference();

  String driverUniqueId;

  int freeSlots = 0;
  String totalslots;

  getUid(driver) {
    this.driverUniqueId = driver;
  }

  String driver = '';
  String park = '';
  String plate = '';

  readBookings() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Car Park").doc(driver);
    documentReference.get().then((datasnapshot) {
      setState(() {
        driver = (datasnapshot["driverId"].toString());
        park = (datasnapshot["parkID"].toString());
        plate = (datasnapshot["plateID"].toString());

      });
    });
  }

  deleteBooking() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Car Park").doc(driverUniqueId);
    documentReference.delete().whenComplete(() {
      print('$driverUniqueId deleted');
    });
  }

  TextStyle ktext = TextStyle(color: Colors.white, fontSize: 17);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(14),
          color: Colors.teal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driver Name: $driver', style: ktext,),
              Text('Park: $park', style: ktext,),
              Text('Number Plate: $plate', style: ktext,),
              SizedBox(height: 15), 
              TextFormField(
                decoration: InputDecoration(
                  labelText: "4-Digit ID",
                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                  ),
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onChanged: (String uniqueId) {
                  getUid(uniqueId);
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  'Retrieve Booking!',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  readBookings();
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  'Delete Booking!',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  deleteBooking();
                  if (freeSlots <= 9){
                    slotCounter();
                  } else{
                    return null;
                  }
                },
              ),
              SizedBox(height: 30),
              Center(child: Text('RECENT BOOKINGS', style: ktext,)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text('NUMBER PLATE', style: ktext),
                  ),
                  Container(
                    child: Text('CAR PARK', style: ktext),
                  ),
                  Container(
                    child: Text('DRIVER NAME', style: ktext),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 250,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Car Park")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot documentSnapshot =
                                  snapshot.data.docs[index];
                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Text(
                                        documentSnapshot["driverId"].toString(),
                                        style: ktext,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        documentSnapshot["parkID"].toString(),
                                        style: ktext,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        documentSnapshot["plateID"].toString(),
                                        style: ktext,
                                      ),
                                    ),
                                  ]);
                            });
                      } else
                        return Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: CircularProgressIndicator(),
                        );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  void slotCounter() {
    dbRef
        .child('CarPark')
        .child('open slots')
        .once()
        .then((DataSnapshot dataSnapShot) {
      totalslots = dataSnapShot.value.toString();
      freeSlots = int.parse(totalslots);
      setState(() {
        freeSlots++;
      });
      dbRef.child('CarPark').set({'open slots': '$freeSlots'});
    });
  }
}
