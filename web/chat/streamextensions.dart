part of chat;

typedef bool Func(dynamic e);

class StreamExtensions{
  Stream addEnterKeyListener(element, [unsubscribeAfterInitial = false]){
   var controller = new StreamController.broadcast();
   addSubscription(element.onKeyPress, (e){
      if(e.keyCode == KeyCode.ENTER){
        controller.add(new Event('EnterPressed'));
        return unsubscribeAfterInitial;
      }
      return false;
    });
    return controller.stream;
  }

  void addSubscription(Stream stream, Func handler){
    var sub = stream.listen(null);
    sub
    ..onData((e){
      if(handler(e)){
        sub.cancel();
      }
    })
    ..onError((err) => print(err.toString()))
    ..onDone(() => print('Stream has completed'));
  }
}