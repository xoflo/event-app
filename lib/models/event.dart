

class Event {
  String? eventName;
  DateTime? eventCreated;
  int? participants;
  String? status;


  Event({this.eventName, this.eventCreated, this.participants, this.status});

  toFirebase() {
    return {
      'eventName' : eventName,
      'eventCreated' : eventCreated,
      'participants' : participants,
      'status' : status
    };
  }


  fromJson(Map<String, dynamic> json) {
    eventName = json['eventName'];
    eventCreated = json['eventCreated'].toDate();
    participants = json['participants'];
    status = json['status'];
  }

}

