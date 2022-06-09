import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  String? resimId;
  final Reference _storage = FirebaseStorage.instance
      .ref(); //Depolama Alanına Ulaşılabilmeyi Sağlayan Obje Oluşturulmuş Oldu.

  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();

    UploadTask yuklemeYoneticisi = _storage
        .child("resimler/gonderiler")
        .child("gonderi_$resimId.jpg")
        .putFile(
            resimDosyasi); // yükleme //her bir gönderi eşsiz isim almalı yoksa siler üzerine kaydeder.
    // _storage.child("resimler").child("gonderiler").child("gonderi.jpg").putFile(resimDosyasi);

    TaskSnapshot snapshot = await yuklemeYoneticisi; //tam anlamadım

    String yuklenenResimUrl = await yuklemeYoneticisi.snapshot.ref
        .getDownloadURL(); // yükleme bilgileri
        
    print(yuklenenResimUrl);
    return yuklenenResimUrl;
  }

  Future<String> profilResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();

    UploadTask yuklemeYoneticisi = _storage
        .child("resimler/profil")
        .child("profil_$resimId.jpg")
        .putFile(
            resimDosyasi); // yükleme //her bir gönderi eşsiz isim almalı yoksa siler üzerine kaydeder.
    // _storage.child("resimler").child("gonderiler").child("gonderi.jpg").putFile(resimDosyasi);

    TaskSnapshot snapshot = await yuklemeYoneticisi; //tam anlamadım

    String yuklenenResimUrl = await yuklemeYoneticisi.snapshot.ref
        .getDownloadURL(); // yükleme bilgileri
        
    print(yuklenenResimUrl);
    return yuklenenResimUrl;
  }

  void gonderiResmiSil(String gonderiResmiUrl){
    RegExp arama = RegExp(r"gonderi_.+\.jpg");
    var eslesme = arama.firstMatch(gonderiResmiUrl);
    String? dosyaAdi = eslesme![0]; //??

    if(dosyaAdi != null){
      _storage.child("resimler/gonderiler/$dosyaAdi").delete();
    }

    //_storage.storage.refFromURL(gonderiResmiUrl).delete();
  }
  
}
