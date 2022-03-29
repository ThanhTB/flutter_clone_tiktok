import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/comment.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);

  List<Comment> get comments => _comments.value;

  String _postId = '';

  updatePostId(String id) {
    _postId = id;
    getComment();
  }

  getComment() async {
    _comments.bindStream(firestore
        .collection('videos')
        .doc(_postId)
        .collection('comments')
        .snapshots()
        .map((QuerySnapshot query) {
      List<Comment> retVal = [];
      for (var item in query.docs) {
        retVal.add(Comment.fromSnap(item));
      }
      return retVal;
    }));
  }

  postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(authController.user.uid)
            .get();
        var allDocs = await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .get();

        int len = allDocs.docs.length;
        var user = userDoc.data()! as dynamic;
        Comment comment = Comment(
          username: user['name'],
          comment: commentText.trim(),
          datePublished: DateTime.now(),
          likes: [],
          profilePhoto: user['profilePhoto'],
          uid: authController.user.uid,
          id: 'comment $len',
        );

        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc('comment $len')
            .set(comment.toJson());

        DocumentSnapshot snap =
            await firestore.collection('videos').doc(_postId).get();

        await firestore.collection('videos').doc(_postId).update({
          'commentCount': (snap.data()! as dynamic)['commentCount'] + 1,
        });
      }
    } catch (e) {
      Get.snackbar('Error while commenting', e.toString());
    }
  }

  likeComment(String id) async {
    var uid = authController.user.uid;
    DocumentSnapshot snap = await firestore
        .collection('videos')
        .doc(_postId)
        .collection('comments')
        .doc(id)
        .get();

    if ((snap.data()! as dynamic)['likes'].contains(uid)) {
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }
}
