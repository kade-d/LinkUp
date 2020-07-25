import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techpointchallenge/model/recognition.dart';

class RecognitionFirestore {

  static Future<void> addRecognition(Recognition recognition, String userId, String orgId) async {

    List<Recognition> recognitions = await getRecognitionsForUser(userId);

    recognitions.add(recognition);

    await Firestore.instance.collection('recognitions').document(userId).setData(
      {
        "org_id" : orgId,
        "recognitions": recognitions.map((recognition) => recognition.toJson()).toList()
      },
      merge: true)
      .catchError((e) {
      print("Add recognition error: " + e.toString());
      }
    );
  }

  static Future<List<Recognition>> getRecognitionsForUser(String userId) async {

    List<Recognition> recognitions = List();

    await Firestore.instance.collection('recognitions').document(userId).get().then((snapshot){
      if(snapshot.exists){
        for(var recognitionJson in snapshot.data['recognitions']){
          recognitions.add(Recognition.fromJson(recognitionJson));
        }
      }
    }).catchError((e) => print("Get rec. error : " + e));

    return recognitions;
  }

  static Future<List<Recognition>> getOrganizationRecognitions(String orgId) async {

    List<Recognition> recognitions = List();

    await Firestore.instance.collection('recognitions').where("org_id", isEqualTo: orgId).getDocuments().then((snapshots){
      snapshots.documents.forEach((snapshot){
        for(var recognitionJson in snapshot.data['recognitions']){
          recognitions.add(Recognition.fromJson(recognitionJson));
        }
      });
    }).catchError((e) => print("Get rec. error : " + e));

    return recognitions;
  }

}