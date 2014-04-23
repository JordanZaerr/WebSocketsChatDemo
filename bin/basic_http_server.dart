import 'dart:async';
import 'dart:io';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:path/path.dart' show join, dirname;

List clients = [];
List<String> messages = [];

void main() {
  // Assumes the server lives in bin/ and that `pub build` ran
  var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'build');

  var staticFiles = new VirtualDirectory(pathToBuild);
  staticFiles.allowDirectoryListing = true;
  staticFiles.directoryHandler = (dir, request) {
    // Redirect directory-requests to index.html files.
    var indexUri = new Uri.file(dir.path).resolve('index.html');
    staticFiles.serveFile(new File(indexUri.toFilePath()), request);
  };

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 4040 : int.parse(portEnv);
  print(port);
  runZoned((){
    HttpServer.bind('127.0.0.1', port)
    //HttpServer.bind('0.0.0.0', port)
    .then((server){
      server.listen((req){
        if(req.uri.path == '/ws'){
          print('WS request');
          WebSocketTransformer.upgrade(req)
          .then((socket){
            clients.add(socket);
            messages.forEach((msg) => socket.add(msg));
            socket.listen((msg){
              messages.add(msg);
              clients.forEach((x) => x.add(msg));
              });
          });
        }
        else{
          print('NonWsRequest');
          staticFiles.serveRequest(req);
        };
      });
    });
  }, onError: (e) => print(e.toString()));
}