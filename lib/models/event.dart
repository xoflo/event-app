

class Event {
  String? eventName;
  DateTime? eventCreated;
  int? participants;
  String? status;
  String? activeAction;


  Event({this.eventName, this.eventCreated, this.participants, this.status, this.activeAction});

  toFirebase() {
    return {
      'eventName' : eventName,
      'eventCreated' : eventCreated,
      'participants' : participants,
      'status' : status,
      'activeAction' : activeAction
    };
  }


  fromJson(Map<String, dynamic> json) {
    eventName = json['eventName'];
    eventCreated = json['eventCreated'].toDate();
    participants = json['participants'];
    status = json['status'];
    activeAction = json['activeAction'];
  }

}

