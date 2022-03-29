import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  uploadVideo(String songName, String caption, String videoPath) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();

      var allDocs = await firestore.collection('videos').get();
      int len = allDocs.docs.length;
      String videoUrl = await _uploadVideoToStorage('Video $len', videoPath);
      String thumbnail = await _uploadImageToStorage('Video $len', videoPath);

      var user = userDoc.data()! as Map<String, dynamic>;
      Video video = Video(
        username: user['name'],
        uid: uid,
        id: 'Video $len',
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        thumbnail: thumbnail,
        profilePhoto: user['profilePhoto'],
      );

      await firestore
          .collection('videos')
          .doc('Video $len')
          .set(video.toJson());

      Get.back();
    } catch (e) {
      Get.snackbar('Error uploading video', e.toString());
    }
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('videos').child(id);
    UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    TaskSnapshot snap = await uploadTask;
    return await snap.ref.getDownloadURL();
  }

  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality);
    return compressedVideo!.file;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask = ref.putFile(await _getthumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    return await snap.ref.getDownloadURL();
  }

  _getthumbnail(String videoPath) async {
    return await VideoCompress.getFileThumbnail(videoPath);
  }
}
