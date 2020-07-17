import 'package:cinema_mobile_app/services/ticket-service.dart';
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
  List<int> reservedTicket = new List();
  Map<String, bool> ticketStates = {}; //pressed or not

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final nbTicketController = TextEditingController();
   
  String currentProjectionID = "";

  
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    codeController.dispose();
    nbTicketController.dispose();
    super.dispose();
  }

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
                          unpressTickets();
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
                                unpressTickets();
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
                        controller: nameController,
                        decoration: InputDecoration(hintText: 'Your Name'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                      child: TextField(
                        controller: codeController,
                        decoration: InputDecoration(hintText: 'Code Payement'),
                        keyboardType: TextInputType.number
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                      child: TextField(
                        controller: nbTicketController,
                        decoration: InputDecoration(hintText: 'Nombre de tickets'),
                        keyboardType: TextInputType.number,
                        onChanged: (text) => unpressTickets(),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        //color: Color(0xFF151C26),
                        color: Colors.blue,
                        child: Text("Réserver les places", style: TextStyle(color:Colors.white),),
                        onPressed: (){
                          //Reservation tickets
                          setState(() {
                            this.currentProjectionID = "${this.listSalles[index]['currentProjection']['id']}";
                          });
                          reserveTickets(context);
                        },
                      ),
                    ),
                    Wrap(children: <Widget>[
                    ...this.listSalles[index]['currentProjection']['listTickets'].map((ticket){

                      String ticketId = "${ticket['id']}";
                      if(ticket['reserve']==false){
                        if( ! ticketStates.containsKey(ticketId)){                          
                          ticketStates[ticketId] = false;
                        }
                        
                        return Container(
                          width: 50,
                          padding: EdgeInsets.all(2),
                          child: RaisedButton(
                            color: !ticketStates[ticketId] ? Color.fromRGBO(73, 51, 61, 1) : Colors.green,
                            child: Text("${ticket['place']['numero']}",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            onPressed: (){
                              setState(() {
                                ticketStates[ticketId] = ! ticketStates[ticketId];
                                
                              });
                              
                            },
                          ),
                        );
                      } 
                      else return Container(
                          width: 50,
                          padding: EdgeInsets.all(2),
                          child: RaisedButton(
                            color:  Colors.grey,
                            child: Text("${ticket['place']['numero']}",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            onPressed: (){
                            },
                          ),
                        );
                      
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

  void unpressTickets(){
    setState(() {
      ticketStates.forEach((key, value) {
        ticketStates[key] = false;
      });
    });
  }
  
  //RESERVATION TICKETS
  void reserveTickets(context){

    //VERIFICATION DES CHAMPS OBLIGATOIRES 
    if(!validFields()){
      print("not valid");
      alertRequiredFields();
      return;
    }

    if(!ticketStates.containsValue(true) && nbTicketController.text == "")
    {
      alertChoosePlace();
    }
    else if (ticketStates.containsValue(true) && nbTicketController.text == "")
    {
      // IF BUTTON ARE PRESSED = MANUAL 
      reseveTicketManually(context);
    }
    else
    {
      // IF NB TICKETS FIELD IS NOT EMPTY  = AUTO 
      reserveTicketsAuto(context);
    }
    
  }

  void alertChoosePlace(){
    //ALERT
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Veuillez selectionner les places à reserver !"),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      )
    );
  }

  bool validFields(){
   
    if(nameController.text == "" || codeController.text == ""){
      return false;
    }
    return true;
  }

  void alertRequiredFields(){
    //ALERT
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Les champs : Nom & Code paiement sont obligatoirs !"),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      )
    );
  }

  reseveTicketManually(context){
    // RESERVATION MANUELLE
      List<String> ids = ticketStates.keys.where((k) => ticketStates[k] == true).toList();
      
      print(ids);
      print("name :" + nameController.text);
      print("code :" + codeController.text);
      
      TicketService.updateTicket(ids, nameController.text, codeController.text)
      .then(
        (result) {
          print(result);
        }
      );

      showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("La reservion est bien éffectuée !"),
          actions: <Widget>[
            FlatButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>new SallesPage(widget.cinema) ));
              },
            )
          ],
        )
      );

  }
  
  void reserveTicketsAuto(context){

    // RESERVATION AUTOMATIQUE
    unpressTickets();
    print("name :" + nameController.text);
    print("code :" + codeController.text);
    print("nb Tickets :" + nbTicketController.text);
    print("P :" + currentProjectionID);

    
    TicketService.updateTicketAuto(nameController.text, codeController.text, nbTicketController.text, currentProjectionID)
      .then(
        (result) {
          print(result);
        }
      );

    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("La reservion de ${nbTicketController.text} tickets est bien éffectuée !"),
        actions: <Widget>[
          FlatButton(
            child: Text('Fermer'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=>new SallesPage(widget.cinema) ));
            },
          )
        ],
      )
    );

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