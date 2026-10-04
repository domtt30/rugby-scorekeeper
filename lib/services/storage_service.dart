import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

class StorageService {
  static const key='rugby_matches';
  late SharedPreferences prefs;
  Future<void> init() async => prefs=await SharedPreferences.getInstance();
  Future<List<RugbyMatch>> loadMatches() async {
    final raw=prefs.getString(key); if(raw==null)return [];
    try{return (jsonDecode(raw) as List).map((e)=>RugbyMatch.fromJson(Map<String,dynamic>.from(e))).toList();}catch(_){return [];}
  }
  Future<void> saveMatch(RugbyMatch match) async {
    final list=await loadMatches(); final i=list.indexWhere((m)=>m.id==match.id);
    if(i<0) list.insert(0,match); else list[i]=match;
    await prefs.setString(key,jsonEncode(list.map((m)=>m.toJson()).toList()));
  }
  Future<void> deleteMatch(String id) async { final list=await loadMatches(); list.removeWhere((m)=>m.id==id); await prefs.setString(key,jsonEncode(list.map((m)=>m.toJson()).toList())); }
}
