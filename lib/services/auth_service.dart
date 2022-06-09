import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/models/users.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? aktifKullaniciId;

  Kullanici? _kullaniciOlustur(User? kullanici) {
    return kullanici == null ? null : Kullanici.firebasedenUret(kullanici);
  }

  Stream<Kullanici?> get durumTakipcisi {
    return _firebaseAuth.authStateChanges().map<Kullanici?>(_kullaniciOlustur);
  }

  Future<Kullanici?> mailKayit(String email, String password) async {
    var girisKarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _kullaniciOlustur(girisKarti.user);
  }

  Future<Kullanici?> mailGiris(String email, String password) async {
    var girisKarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _kullaniciOlustur(girisKarti.user);
  }

  Future<void> cikisYap() async {
    return await _firebaseAuth.signOut();
  }

  Future<void> sifremiSifirla(String eposta)async{
    await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }

  Future<Kullanici?> googleGiris() async {
    GoogleSignInAccount? googleHesap = await GoogleSignIn()
        .signIn(); //Google hesabı ile ilgili bilgileri içerir.

    GoogleSignInAuthentication googleYetkiKarti = await googleHesap!
        .authentication; //yetki kartı, kayıtlı google kullanıcısı olduğunu kanıtlar.

    OAuthCredential sifresizGirisBelgesi = GoogleAuthProvider.credential(
        idToken: googleYetkiKarti.idToken,
        accessToken: googleYetkiKarti.accessToken); //yetki kartı onaylatma

    UserCredential girisKarti = await _firebaseAuth.signInWithCredential(
        sifresizGirisBelgesi); //firebase Auth servisinde düz mail harici hesaplarında kayıt olabilmesini sağlar.

    return _kullaniciOlustur(girisKarti.user); //kullanıcı objesi döndürür.
    
    // print(googleHesap.id);
    // print(googleHesap.displayName);

    // print(girisKarti.user!.uid);
    // print(girisKarti.user!.displayName);
    // print(girisKarti.user!.photoURL);
    // print(girisKarti.user!.email);
    
  }
}
