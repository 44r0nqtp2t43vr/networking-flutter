import 'package:flutter/material.dart';
import 'package:networking/helpers/album_helpers.dart';
import 'package:networking/helpers/photo_helpers.dart';
import 'package:networking/models/album.dart';
import 'package:networking/models/photo.dart';
import 'package:http/http.dart' as http;
import 'package:networking/widgets/photos_list.dart';

void main() => runApp(const NetworkingApp());

class NetworkingApp extends StatefulWidget {
  const NetworkingApp({super.key});

  @override
  State<NetworkingApp> createState() => _NetworkingAppState();
}

class _NetworkingAppState extends State<NetworkingApp> {
  late Future<Album> futureAlbum;
  final TextEditingController _controller = TextEditingController();
  Future<Album>? _futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Networking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Networking'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 80.0,
              width: double.infinity,
              child: Center(
                child: FutureBuilder<Album>(
                  future: futureAlbum,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!.title);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 120.0,
              width: double.infinity,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: (_futureAlbum == null)
                    ? buildColumn()
                    : buildFutureBuilder(),
              ),
            ),
            SizedBox(
              height: 120.0,
              width: double.infinity,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<Album>(
                  future: _futureAlbum,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Enter Title',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _futureAlbum = updateAlbum(_controller.text);
                                });
                              },
                              child: const Text('Update Data'),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                    }

                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 80.0,
              width: double.infinity,
              child: Center(
                child: FutureBuilder<Album>(
                  future: _futureAlbum,
                  builder: (context, snapshot) {
                    // If the connection is done,
                    // check for response data or an error.
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              child: const Text('Delete Data'),
                              onPressed: () {
                                setState(() {
                                  _futureAlbum =
                                      deleteAlbum(snapshot.data!.id.toString());
                                  _futureAlbum = createAlbum('default');
                                });
                              },
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FutureBuilder<List<Photo>>(
                  future: fetchPhotos(http.Client()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('An error has occurred!'),
                      );
                    } else if (snapshot.hasData) {
                      return PhotosList(photos: snapshot.data!);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter Title'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureAlbum = createAlbum(_controller.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<Album> buildFutureBuilder() {
    return FutureBuilder<Album>(
      future: _futureAlbum,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.title);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
