part of chat;

class ChatClient {
  String _name;
  WebSocket _socket;
  StreamController _controller;

  ChatClient(String name) {
    _name = name;
    _controller = new StreamController.broadcast();
  }

  connect(String address) {
    _socket = new WebSocket(address);
    _socket.onMessage.listen((msg) {
      print('received msg: ' + msg.data);
      Map msgData = JSON.decode(msg.data);
      _controller.add(new ChatEvent(msgData['n'], msgData['m']));
    });
  }

  send(String message){
    if (_socket != null && _socket.readyState == WebSocket.OPEN) {
      _socket.send(JSON.encode({'n': _name, 'm' : message}));
    } else {
      print('Socket not ready...');
    }
  }

  Stream get onMessage => _controller.stream;
}

class ChatEvent{
  String _name;
  String _message;

  ChatEvent(this._name,this._message);

  String get name => _name;
  String get message => _message;
}