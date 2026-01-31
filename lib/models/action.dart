

class Action {
  String? actionName;
  DateTime? startTime;
  int? durationInSeconds;
  String? status;
  List<Map<String, dynamic>> options = [];

  Action({this.actionName, this.durationInSeconds, this.status, required this.options});


}


class Option {
  String? optionName;
  int? votes;

  Option({this.optionName, this.votes});

}
