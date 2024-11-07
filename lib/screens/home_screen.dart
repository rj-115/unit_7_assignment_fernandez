import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var content;
  bool? loading;

  Future getList() async {
    setState(() {
      loading = true;
    });

    var data = await getContent();

    setState(() {
      loading = false;
      content = data['results'];
    });
  }

  Future<Map<String, dynamic>> getContent() async {
    var url = 'https://pokeapi.co/api/v2/pokemon/?limit=30&offset=0';
    var uri = Uri.parse(url);
    var response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    List<dynamic> results = json['results'];

    for (var pokemon in results) {
      var pokemonUrl = pokemon['url'];
      var pokemonResponse = await http.get(Uri.parse(pokemonUrl));
      var pokemonData = jsonDecode(pokemonResponse.body);

      List<String> types = [];
      for (var type in pokemonData['types']) {
        types.add(type['type']['name']);
      }

      pokemon['types'] = types;
    }

    return {'results': results}; // Return the results with types added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder(
        // setup the URL for your API here
        future: getContent(),
        builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
          // Consider 3 cases here
          // when the process is ongoing
          // return CircularProgressIndicator();

          // when the process is completed:

          // successful
          // Use the library here

          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Oh no! Error! ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Text('Nothing to show');
          }

          var data = snapshot.data as Map;
          var results = data['results'];

          return ExpandedTileList.builder(
            itemCount: results.length,
            maxOpened: 1,
            itemBuilder: (context, index, controller) {
              return ExpandedTile(
                theme: const ExpandedTileThemeData(
                  headerColor: Color.fromARGB(255, 255, 255, 255),
                  headerPadding: EdgeInsets.all(24.0),
                  headerSplashColor: Color.fromARGB(255, 255, 255, 255),
                  contentPadding: EdgeInsets.all(24.0),
                ),
                controller: ExpandedTileController(),
                title: Text(
                  '${index + 1}. ${results[index]['name']}'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 229, 73, 65),
                        Colors.blue.shade900,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Name: ${results[index]['name']}'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 25.0,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        Image.network(
                          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${index + 1}.png",
                          height: 200,
                          width: 200,
                        ),
                        Text(
                          'Types: ${results[index]['types']}'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 25.0,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

          // error
          // return Text('Error');
        },
      ),
    );
  }
}
