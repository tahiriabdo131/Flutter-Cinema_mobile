import 'package:http/http.dart' as http;

class TicketService {
  static const ROOT = 'http://192.168.1.2/cinema_mobile_app/actions.php';
  static const String _UPDATE_TICKET_ACTION = 'UPDATE_TICKET';
 



  static Future<String> updateTicket(
      List<String> ids,  String nomClient, String codePayement) async {

      print("Service has started ..............");
      
        try {
          var map = new Map<String, dynamic>();
          map["action"] = _UPDATE_TICKET_ACTION;
          map["ids"] = ids.toString();
          map["code_payement"] = codePayement;
          map["nom_client"] = nomClient;
          final response = await http.post(ROOT, body: map);
          if(response.statusCode == 200){
            print("update Ticket >> Response:: ${response.body}");
            return response.body;
          }else return "ERROR";
          
        } catch (e) {
          return 'error : '+ e.toString();
        }

  }

  static Future<String> updateTicketAuto(String nomClient, String codePayement, String nbTickets, String projectionId) async {

      print("Service has started ..............");
      
        try {
          var map = new Map<String, dynamic>();
          map["action"] = "UPDATE_TICKET_AUTO";
          map["nb_tickets"] = nbTickets;
          map["code_payement"] = codePayement;
          map["nom_client"] = nomClient;
          map["projection_id"] = projectionId;
          final response = await http.post(ROOT, body: map);
          if(response.statusCode == 200){
            print("update Ticket >> Response:: ${response.body}");
            return response.body;
          }else return "ERROR";
          
        } catch (e) {
          return 'error : '+ e.toString();
        }

  }

 
}
