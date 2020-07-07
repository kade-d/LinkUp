import 'dart:async';
import 'dart:html';

import 'dart:typed_data';

class ImageUploader {

  List<File> uploadedFiles = List();
  List<Uint8List> uploadedBytes = List();

  startFilePicker(bool acceptMultiple) async {

    final readBytesFromFiles = Completer<List<Uint8List>>();
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = acceptMultiple;
    uploadInput.accept = 'image/*';
    uploadInput.click();

    List<File> files;
    uploadInput.addEventListener('change', (e) async {
      files = uploadInput.files;
      Iterable<Future<Uint8List>> resultsFutures = files.map((file) {
        final reader = FileReader();
        reader.readAsArrayBuffer(file);
        reader.onError.listen((error) => readBytesFromFiles.completeError(error));
        return reader.onLoad.first.then((_) => reader.result);
      });
      final results = await Future.wait(resultsFutures);
      readBytesFromFiles.complete(results);
    });

    document.body.append(uploadInput);
    final List<Uint8List> bytes = await readBytesFromFiles.future;

    for(int x = 0; x < bytes.length; x++){
      uploadedFiles.add(files[x]);
      uploadedBytes.add(bytes[x]);
    }
  }

}