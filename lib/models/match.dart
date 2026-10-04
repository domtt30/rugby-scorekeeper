enum EventType { tryScore, conversion, penalty, dropGoal, yellowCard, redCard }

extension EventTypeInfo on EventType {
  String get label => switch (this) {
    EventType.tryScore => 'Try',
    EventType.conversion => 'Conversion',
    EventType.penalty => 'Penalty',
    EventType.dropGoal => 'Drop Goal',
    EventType.yellowCard => 'Yellow Card',
    EventType.redCard => 'Red Card',
  };
  int get points => switch (this) {
    EventType.tryScore => 5,
    EventType.conversion => 2,
    EventType.penalty => 3,
    EventType.dropGoal => 3,
    EventType.yellowCard || EventType.redCard => 0,
  };
}

class MatchEvent {
  final String id;
  final EventType type;
  final bool homeTeam;
  final int minute;
  final String player;
  MatchEvent({required this.id, required this.type, required this.homeTeam, required this.minute, required this.player});
  Map<String,dynamic> toJson()=>{'id':id,'type':type.name,'homeTeam':homeTeam,'minute':minute,'player':player};
  factory MatchEvent.fromJson(Map<String,dynamic> j)=>MatchEvent(id:j['id'],type:EventType.values.byName(j['type']),homeTeam:j['homeTeam'],minute:j['minute'],player:j['player']??'');
}

class RugbyMatch {
  final String id, homeTeam, awayTeam;
  final DateTime createdAt;
  final List<MatchEvent> events;
  final bool finished;
  RugbyMatch({required this.id,required this.homeTeam,required this.awayTeam,required this.createdAt,List<MatchEvent>? events,this.finished=false}):events=events??[];
  int get homeScore=>events.where((e)=>e.homeTeam).fold(0,(s,e)=>s+e.type.points);
  int get awayScore=>events.where((e)=>!e.homeTeam).fold(0,(s,e)=>s+e.type.points);
  RugbyMatch copyWith({List<MatchEvent>? events,bool? finished})=>RugbyMatch(id:id,homeTeam:homeTeam,awayTeam:awayTeam,createdAt:createdAt,events:events??List.of(this.events),finished:finished??this.finished);
  Map<String,dynamic> toJson()=>{'id':id,'homeTeam':homeTeam,'awayTeam':awayTeam,'createdAt':createdAt.toIso8601String(),'events':events.map((e)=>e.toJson()).toList(),'finished':finished};
  factory RugbyMatch.fromJson(Map<String,dynamic> j)=>RugbyMatch(id:j['id'],homeTeam:j['homeTeam'],awayTeam:j['awayTeam'],createdAt:DateTime.parse(j['createdAt']),events:(j['events'] as List? ?? []).map((e)=>MatchEvent.fromJson(Map<String,dynamic>.from(e))).toList(),finished:j['finished']??false);
}
