import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  late final String id;
  late final String icerik;
  late final String yayinlayanId;
  late final Timestamp olusturulmaZamani;

  Yorum(
      {required this.id,
      required this.icerik,
      required this.yayinlayanId,
      required this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    return Yorum(
        id: doc.id,
        icerik: doc["icerik"],
        yayinlayanId: doc["yayinlayanId"],
        olusturulmaZamani: doc["olusturulmaZamani"]);
  }
}
