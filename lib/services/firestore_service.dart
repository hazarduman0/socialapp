import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/models/duyuru.dart';
import 'package:socialapp/models/gonderi.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/services/storageservisi.dart';

class FireStoreServis {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();

  kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _fireStore.collection("kullanicilar").doc(id).set({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<Kullanici?> kullaniciGetir(id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _fireStore.collection("kullanicilar").doc(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle(
      {required String? kullaniciId,
      required String? kullaniciAdi,
      String? fotoUrl = "",
      required String? hakkinda}) {
    _fireStore.collection("kullanicilar").doc(kullaniciId).update({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _fireStore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .get();

    List<Kullanici> kullanicilar =
        snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();

    return kullanicilar;
  }

  void takipEt(
      {required String aktifKullaniciId, required String profilSahibiId}) {
    _fireStore
        .collection("takipciler")
        .doc(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .doc(aktifKullaniciId)
        .set({});

    _fireStore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .doc(profilSahibiId)
        .set({});

    takipDuyuruEkle(
        aktiviteYapanId: aktifKullaniciId,
        profilSahibiId: profilSahibiId,
        aktiviteTipi: "takip");
  }

  void takiptenCik(
      {required String aktifKullaniciId, required String profilSahibiId}) {
    _fireStore
        .collection("takipciler")
        .doc(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .doc(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    _fireStore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .doc(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipKontrol(
      {required String aktifKullaniciId,
      required String profilSahibiId}) async {
    DocumentSnapshot doc = await _fireStore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .doc(profilSahibiId)
        .get();

    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _fireStore
        .collection("takipciler")
        .doc(kullaniciId)
        .collection("kullanicininTakipcileri")
        .get();
    return snapshot.docs.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _fireStore
        .collection("takipedilenler")
        .doc(kullaniciId)
        .collection("kullanicininTakipleri")
        .get();
    return snapshot.docs.length;
  }

  void duyuruEkle(
      {required String aktiviteYapanId,
      required String profilSahibiId,
      required String aktiviteTipi,
      String yorum = "",
      required Gonderi gonderi}) {
    if(aktiviteYapanId == profilSahibiId){
      return;
    }    
    _fireStore
        .collection("duyurular")
        .doc(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi.id,
      "gonderiFoto": gonderi.gonderiResmiUrl,
      "yorum": yorum,
      "olusturulmaZamani": zaman
    });
  }

  void takipDuyuruEkle(
      {required String aktiviteYapanId,
      required String profilSahibiId,
      required String aktiviteTipi,
      }) {
    _fireStore
        .collection("duyurular")
        .doc(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": "",
      "gonderiFoto": "",
      "yorum": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _fireStore
        .collection("duyurular")
        .doc(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .orderBy("olusturulmaZamani", descending: true)
        .limit(20)
        .get();

    List<Duyuru> duyurular = [];

    snapshot.docs.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });

    return duyurular;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _fireStore
        .collection("gonderiler")
        .doc(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman,
    });
  }

  Future<void> gonderiSil({required String aktifKullaniciId, required Gonderi gonderi}) async {
    _fireStore
        .collection("gonderiler")
        .doc(aktifKullaniciId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id)
        .get().then((DocumentSnapshot doc){
          if(doc.exists){
            doc.reference.delete();
          }});
    
    //Gönderiye ait yorumlar silinecek

    QuerySnapshot yorumlarSnapshot = await _fireStore
        .collection("yorumlar")
        .doc(gonderi.id)
        .collection("gonderiYorumlari")
        .get();

    yorumlarSnapshot.docs.forEach((DocumentSnapshot doc) { 
        if(doc.exists){
          doc.reference.delete();
        }
      });

    //Silinen gönderiyle ilgili duyurular silinecek

    QuerySnapshot duyurularSnapshot = await _fireStore
        .collection("duyurular")
        .doc(gonderi.yayinlayanId)
        .collection("kullanicininDuyurulari").where("gonderiId", isEqualTo: gonderi.id).get();

    duyurularSnapshot.docs.forEach((DocumentSnapshot doc) { 
        if(doc.exists){
          doc.reference.delete();
        }
      });

    //Storage servisinden gönderi resmi silinecek
    
    StorageServisi().gonderiResmiSil(gonderi.gonderiResmiUrl);  

  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _fireStore
        .collection("gonderiler")
        .doc(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();

    List<Gonderi> gonderiler = await snapshot.docs
        .map((doc) => Gonderi.dokumandanUret(doc))
        .toList(); //dökümanları gönderi objesine dönüştürmüş olduk.

    return gonderiler;
  }

  Future<List<Gonderi>> akisGonderileriniGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _fireStore
        .collection("akislar")
        .doc(kullaniciId)
        .collection("kullaniciAkisGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();

    List<Gonderi> gonderiler = await snapshot.docs
        .map((doc) => Gonderi.dokumandanUret(doc))
        .toList(); //dökümanları gönderi objesine dönüştürmüş olduk.

    return gonderiler;
  }

  Future<Gonderi> tekliGonderiGetir(
      String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _fireStore
        .collection("gonderiler")
        .doc(gonderiSahibiId)
        .collection("kullaniciGonderileri")
        .doc(gonderiId)
        .get();

    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _fireStore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      //Kullanıcı gönderiyi beğenmeden hemen önce gönderi silinmiş olabilirdi.
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      _fireStore //döndüreceği herhangi bir değere ihtiyaç olmadığı için beklemek gerekmiyor.
          .collection("gonderiler")
          .doc(gonderi.yayinlayanId)
          .collection("kullaniciGonderileri")
          .doc(gonderi.id)
          .update({"begeniSayisi": yeniBegeniSayisi});

      //Kullanıcı-Gönderi İlişkisini Beğeniler Koleksiyonuna Ekle
      _fireStore //döndüreceği herhangi bir değere ihtiyaç olmadığı için beklemek gerekmiyor.
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .set({});
      //dökümanın içersinde Id dışında bir bilgi olmayacak bu yüzden parantezilerin içi boş
      duyuruEkle(
          aktiviteYapanId: aktifKullaniciId,
          profilSahibiId: gonderi.yayinlayanId,
          aktiviteTipi: "begeni",
          gonderi: gonderi);
    }
  }

  Future<void> gonderiBegeniKaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _fireStore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      //Kullanıcı gönderiyi beğenmeden hemen önce gönderi silinmiş olabilirdi.
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      await _fireStore
          .collection("gonderiler")
          .doc(gonderi.yayinlayanId)
          .collection("kullaniciGonderileri")
          .doc(gonderi.id)
          .update({"begeniSayisi": yeniBegeniSayisi});

      //Kullanıcı-Gönderi İlişkisini Beğeniler Koleksiyonundan Sil
      DocumentSnapshot docBegeni = await _fireStore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        //Böyle bir döküman var mı kontrol et
        docBegeni.reference.delete(); //Döküman böyle siliniyor.
      }
    }
  }

  Future<bool> begeniVarmi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _fireStore
        .collection("begeniler")
        .doc(gonderi.id)
        .collection("gonderiBegenileri")
        .doc(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _fireStore
        .collection("yorumlar")
        .doc(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEkle({String? aktifKullaniciId, Gonderi? gonderi, String? icerik}) {
    _fireStore
        .collection("yorumlar")
        .doc(gonderi!.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman
    }); //metodun tamamlanmasını beklemeye gerek yok

    duyuruEkle(
        aktiviteYapanId: aktifKullaniciId!,
        profilSahibiId: gonderi.yayinlayanId,
        aktiviteTipi: "yorum",
        gonderi: gonderi,
        yorum: icerik!);
  }
}
