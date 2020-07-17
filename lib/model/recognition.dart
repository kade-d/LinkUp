import 'package:techpointchallenge/model/user.dart';

class Recognition {

  String message;
  String toUserId;
  String fromUserId;
  String fromUserName;
  String toUserName;
  DateTime postDate;

  Recognition(this.message, this.toUserId, this.fromUserId, this.postDate);

  Recognition.fromNothing();

  Recognition.fromJson(dynamic json){

    assert (json != null);

    message = json['message'];
    toUserId = json['to_user_id'];
    fromUserId = json['from_user_id'];
    fromUserName = json['from_user_name'];
    toUserName = json['to_user_name'];
    postDate = DateTime.parse(json['post_date']);

  }

  dynamic toJson(){
    return Map.of(
      {
        "message" : message,
        "to_user_id" : toUserId,
        "from_user_id" : fromUserId,
        "to_user_name" : toUserName,
        "from_user_name" : fromUserName,
        "post_date" : postDate.toIso8601String()
      }
    );
  }

}