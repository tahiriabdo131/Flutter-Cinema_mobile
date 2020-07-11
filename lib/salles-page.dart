import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globalVariable.dart';

class SallesPage extends StatefulWidget{
  dynamic cinema;
  //hadi nadya kat3ni bli jbna ga3 les cinemas li kynin f la ville li klikina 3liha.
  SallesPage(this.cinema);
  //
  @override
  _SallesPageState createState() => _SallesPageState();
}

class _SallesPageState extends State<SallesPage> {
  List<dynamic> listSalles;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Salles de ${widget.cinema['name']}"),),
      body: Center(
        child: this.listSalles==null?CircularProgressIndicator():
          ListView.builder(
            itemCount: (this.listSalles==null)?0:this.listSalles.length,
            itemBuilder: (context, index){
              return 
              Card(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Color(0xFF151C26),
                        child: Text(this.listSalles[index]['name'], style: TextStyle(color: Colors.white)),
                        onPressed: (){
                          loadProjections(this.listSalles[index]);
                        },
                      ),
                    ),
                  ),
                  if(this.listSalles[index]['projections']!=null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Image.network(GlobalData.host+"/imageFilm/${this.listSalles[index]['currentProjection']['film']['id']}", width:150),
                      Column(
                        children: <Widget>[
                          ...(this.listSalles[index]['projections'] as List<dynamic>).map((projection){
                            return RaisedButton(
                              color: (this.listSalles[index]['currentProjection']['id']==projection['id'])?Color.fromRGBO(73, 51, 61, 1):Colors.grey,
                              child: Text("${projection['seance']['heureDebut']}   (${projection['film']['duree']} H/ ${projection['prix']} DH)", style: TextStyle(color: Colors.white,fontSize: 12)),
                              onPressed: (){
                                loadTickets(projection, this.listSalles[index]);
                              },
                            );
                          })
                        ],
                      ),
                    ],
                    ),
                  ),

                  if(this.listSalles[index]['currentProjection']!=null &&
                    this.listSalles[index]['currentProjection']['listTickets']!=null &&
                    this.listSalles[index]['currentProjection'].length>0
                  )
                  Column(children: <Widget>[
                    Row(children: <Widget>[
                      Text("Nombre de place dispo:${this.listSalles[index]['currentProjection']['nombrePlacesDisponibles']}")
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Your Name'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Code Payement'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Nombre de tickets'),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        //color: Color(0xFF151C26),
                        color: Colors.blue,
                        child: Text("Réserver les places", style: TextStyle(color:Colors.white),),
                        onPressed: (){
                          //vous devez envoyer une requete pour modifier le champs reservee des tickets selectionner vers true
                        },
                      ),
                    ),
                    Wrap(children: <Widget>[
                    ...this.listSalles[index]['currentProjection']['listTickets'].map((ticket){
                    if(ticket['reserve']==false)
                      return Container(
                        width: 50,
                        padding: EdgeInsets.all(2),
                        child: RaisedButton(
                          color: Color.fromRGBO(73, 51, 61, 1),
                          child: Text("${ticket['place']['numero']}",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: (){},
                        ),
                      );
                      else return Container();
                    })
                  ],)
                  ],)
                  ],
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
    loadSalles();
  }

  void loadSalles(){
    String url = this.widget.cinema['_links']['salles']['href'];
    http.get(url)
      .then((resp){
        setState((){
          this.listSalles = json.decode(resp.body)['_embedded']['salles'];
        });
      }).catchError((err){
        print(err);
      });
  }

  void loadProjections(salle){
    String url = salle['_links']['projections']['href'].toString()
          .replaceAll("{?projection}", "?projection=p1");
    print(url);

    http.get(url)
    .then((resp){
      setState((){
        salle['projections']=json.decode(resp.body)['_embedded']['projections'];
        salle['currentProjection']= salle['projections'][0];
        print(salle['projections']);
      });
    }).catchError((err){
      print(err);
    });
  }

  void loadTickets(projection, salle){
    String url = projection['_links']['tickets']['href'].toString().replaceAll("{?projection}", "?projection=ticketProj");
    http.get(url).then((resp) {
      setState((){
      projection['listTickets'] = json.decode(resp.body)['_embedded']['tickets'];
      salle['currentProjection']= projection;
      projection['nombrePlacesDisponibles'] = nombrePlaceDisponible(projection);
      });
    }).catchError((err){
      print(err);
    });
  }
 
 nombrePlaceDisponible(projection){
   int nombre=0;
    for(int i=0;i<projection['tickets'].length;i++){
      if(projection['tickets'][i]['reserve']==false)++nombre;
    }
    return nombre;
 }


}