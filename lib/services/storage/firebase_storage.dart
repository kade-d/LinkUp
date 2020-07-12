import 'dart:html';
import 'package:firebase/firebase.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorage {

  static Future<String> uploadImage(File file, String basePath) async{
    Uuid uuid = Uuid();
    StorageReference ref = storage().ref(basePath);

    UploadTask uploadTask = ref.child(uuid.v4().toString() + ":" + file.name).put(file, UploadMetadata(contentType: file.type));

    String filePath;
    try {
      UploadTaskSnapshot snapshot = await uploadTask.future;
      filePath = (await snapshot.ref.getDownloadURL()).toString();
    } catch (e) {
      print(e);
    }
    return filePath;
  }

}