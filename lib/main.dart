import 'package:flutter/material.dart';
import 'MenuItem.dart';
import 'villes-page.dart';
import 'setting-page.dart';

void main()=>runApp(MaterialApp(
  theme: ThemeData(
    appBarTheme: AppBarTheme(
      color: Color(0xFF151C26),
    ),
  ),
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final menus = [
    {'title':'Home', 'icon':Icon(Icons.home),'page':VillePage()},
    {'title':'Setting', 'icon':Icon(Icons.settings),'page':SettingPage()},
    {'title':'Contact', 'icon':Icon(Icons.contact_mail),'page':SettingPage()},
  ];
 @override
 Widget build(BuildContext context){
   return Scaffold(
     appBar: AppBar(title: Center(child: Text("Cinema Page")),),
     body: Center(
       child: Text("Home Cinema..."),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/profile.png"),
                  radius: 30,
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFF151C26),] 
                )
              ),
            ),
            ...this.menus.map((item){
              return new Column(
                children: <Widget>[
                  Divider(color: Color(0xFF151C26),),
                  //je dois creer une widget
                  MenuItem(item['title'], item['icon'], (context){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>item['page'])
                    );
                  })
                ],
              );
            }),
          ],
            
        )
      ),
    );
  }
}
