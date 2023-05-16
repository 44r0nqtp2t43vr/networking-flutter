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
            const SizedBox(width: double.infinity),
            Expanded(
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
}
