import 'dart:async';
import 'dart:html';

import 'dart:typed_data';

class ImageUploader {

  static Future<File> startFilePicker() async {
    final readBytesFromFiles = Completer<List<Uint8List>>();
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = false;
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

    return files[0];
  }
}
