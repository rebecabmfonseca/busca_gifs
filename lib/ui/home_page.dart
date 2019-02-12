import 'package:buscador_gifs/ui/git_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String search;
  int offset = 0;

  Future<Map> _getGifs () async {
    http.Response response;

    if( search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=AQL1QwD8i2H7hhEjGdAwcWy5kZPzSoJT&limit=9&rating=G");
    else
     response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=AQL1QwD8i2H7hhEjGdAwcWy5kZPzSoJT&q=$search&limit=9&offset=$offset&rating=G&lang=pt");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(
                      color: Colors.white
                  ),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  search = text;
                  offset = 0;
                });


              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                    );
                  default:
                    if(snapshot.hasError) {
                      return Container(
                        child: Text("Deu ruim :/"),
                      );
                    }else{
                       return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data){
    if( search == null ){
      return data.length;
    }else{
      return data.length + 1;
    }
  }
  Widget _createGifTable(BuildContext context,AsyncSnapshot snapshot){
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0
        ),
        padding: EdgeInsets.all(10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index){
          if( search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]) ));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);

              },
            );
          else
             return Container(
                child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.white, size: 70.0,),
                      Text("Carregar +", style: TextStyle( color: Colors.white, fontSize: 22.0),)
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      offset += 9;
                    });
                  },
                ),
             );
        }
    );
  }
}
