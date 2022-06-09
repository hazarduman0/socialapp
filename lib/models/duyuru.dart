import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  late final String id;
  late final String aktiviteYapanId;
  late final String aktiviteTipi;
  late final String gonderiId;
  late final String gonderiFoto;
  late final String yorum;
  final Timestamp olusturulmaZamani;

  Duyuru({
    required this.id,
    required this.aktiviteYapanId,
    required this.aktiviteTipi,
    required this.gonderiId,
    required this.gonderiFoto,
    required this.yorum,
    required this.olusturulmaZamani,
  });

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    return Duyuru(
        id: doc.id,
        aktiviteYapanId: doc["aktiviteYapanId"],
        aktiviteTipi: doc["aktiviteTipi"],
        gonderiId: doc["gonderiId"],
        gonderiFoto: doc["gonderiFoto"],
        yorum: doc["yorum"],
        olusturulmaZamani: doc["olusturulmaZamani"],
        );
  }
}
