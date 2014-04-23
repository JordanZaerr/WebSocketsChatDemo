library chat;

import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async' show Stream, StreamController, Future, Completer;

part 'chatclient.dart';
part 'streamextensions.dart';

class ChatProgram extends Object with StreamExtensions{
  void Execute(){
    getName()
      .then((name){
        querySelector('div:first-of-type').text = 'Hello $name';
        querySelector('div:nth-of-type(2)').hidden = false;
        return new ChatClient(name);
      })
      .then(setupClient)
      .then((client){
        InputElement msgBox = querySelector('#msg');
        attachSendMessageHandler(client, addEnterKeyListener(msgBox), msgBox);
        attachSendMessageHandler(client, querySelector('#sendMsg').onClick, msgBox);
        msgBox.focus();
      })
      .catchError((e) => print(e.toString()));
  }

  Future<String> getName(){
    var completer = new Completer();
    InputElement nameElement = querySelector('#name');

    addEnterKeyListener(nameElement, true)
      .listen((_) => completer.complete(nameElement.value));

    addSubscription(querySelector('#setName').onClick, (_){
      completer.complete(nameElement.value);
      return true;
    });
    return completer.future;
  }

  ChatClient setupClient(client){
    //client.connect('ws://websocketschatdemo.herokuapp.com/ws');
    client.connect('ws://127.0.0.1:4040/ws');
    client.onMessage.listen((ChatEvent data) =>
    querySelector('#container').children
      .add(new LIElement()..text = "${data.name} - ${data.message}"));
    return client;
  }

  void attachSendMessageHandler(ChatClient client, Stream stream, InputElement msgBox){
    stream
      .where((_) => msgBox.value.isNotEmpty)
      .listen((_){
        client.send(msgBox.value);
        msgBox.value = "";
      });
  }
}