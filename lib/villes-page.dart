import 'package:cinema_mobile_app/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CinemasPage.dart';
import 'globalVariable.dart';

class VillePage extends StatefulWidget {
  @override
  _VillePageState createState() => _VillePageState();
}

class _VillePageState extends State<VillePage>{
  List<dynamic> listVilles;
  String url;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("List Des Villes")),),
      body: Center(
        child: this.listVilles==null?CircularProgressIndicator():
          ListView.builder(
            itemCount: (this.listVilles==null)?0:this.listVilles.length,
            itemBuilder: (context, index){
              return Card(
                color: Color(0xFF151C26),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text(this.listVilles[index]['name']),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>new CinemasPage(this.listVilles[index]) ));
                    },
                  ),
                )
              );
            }
          )
      ),
    );
  }


  @override
  void initState(){
    super.initState();
    loadVilles();
  }

  void loadVilles(){
    //url = "http://192.168.1.41:8080/villes";
    url = GlobalData.host+"/villes";
    http.get(url)
      .then((resp){
        setState((){
          this.listVilles = json.decode(resp.body)['_embedded']['villes'];
        });
      }).catchError((err){
        print(err);
      });
  }

}

