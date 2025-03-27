import 'package:sci_tercen_client/sci_client_service_factory.dart' as tercen;
import 'package:sci_tercen_client/sci_client.dart' as sci;

class CommunicationService {
  static final CommunicationService _singleton = CommunicationService._internal();

  factory CommunicationService() {
    return _singleton;
  }

  CommunicationService._internal();


  Stream<sci.Event> openEventChannel(){
    var factory = tercen.ServiceFactory();

    var stream = factory.eventService.channel("WebappChannel").asBroadcastStream();

    return stream;
  }
}