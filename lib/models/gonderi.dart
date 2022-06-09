import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  late final String id;
  late final String gonderiResmiUrl;
  late final String aciklama;
  late final String yayinlayanId;
  late final int begeniSayisi;
  late final String konum;

  Gonderi(
      {required this.id,
      required this.gonderiResmiUrl,
      required this.aciklama,
      required this.yayinlayanId,
      required this.begeniSayisi,
      required this.konum});

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    return Gonderi(
        id: doc.id,
        gonderiResmiUrl: doc["gonderiResmiUrl"],
        aciklama: doc["aciklama"],
        yayinlayanId: doc["yayinlayanId"],
        begeniSayisi: doc["begeniSayisi"],
        konum: doc["konum"]);
  }
}
