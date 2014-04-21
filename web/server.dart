import 'dart:async';
import 'dart:io';

List clients = [];
List<String> messages = [];

void main() {
  runZoned((){
    HttpServer.bind('127.0.0.1', 4040)
    .then((server){
      server.listen((req){
        print('Incoming Request...$req');
        if(req.uri.path == '/ws'){
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
      });
    });
  }, onError: (e) => print(e.toString()));
}