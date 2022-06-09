import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//android:usesCleartextTraffic="true"
class Kullanici {
  late final String id;
  late final String kullaniciAdi;
  late final String fotoUrl;
  late final String email;
  late final String hakkinda;

  Kullanici(
      {required this.id,
      required this.kullaniciAdi,
      required this.fotoUrl,
      required this.email,
      required this.hakkinda});

  factory Kullanici.firebasedenUret(User kullanici) {
    return Kullanici(
        id: kullanici.uid,
        kullaniciAdi: kullanici.displayName.toString(),
        fotoUrl: kullanici.photoURL.toString(),
        email: kullanici.email.toString(),
        hakkinda: kullanici.providerData.toString());
  }

  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    return Kullanici(
        id: doc.id,
        kullaniciAdi: doc["kullaniciAdi"],
        fotoUrl: doc["fotoUrl"],
        email: doc["email"],
        hakkinda: doc["hakkinda"]);
  }
}
