import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/pages/hesap_olustur.dart';
import 'package:socialapp/pages/sifremiunuttum.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key? key}) : super(key: key);

  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  String? email, sifre;
  bool _yukleniyor = false;

  final _formState = GlobalKey<FormState>();
  final _scaffoldM = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [_sayfaElemanlari(), _yuklemeAnimasyonu()],
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (_yukleniyor) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return const SizedBox(
        height: 0.0,
      );
    }
  }

  Widget _sayfaElemanlari() {
    return ScaffoldMessenger(
      key: _scaffoldM,
      child: Scaffold(
          body: Form(
        key: _formState,
        child: ListView(
          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 60.0),
          children: [
            const FlutterLogo(
              size: 90.0,
            ),
            const SizedBox(
              height: 80.0,
            ),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.mail,
                  color: Color.fromARGB(105, 105, 105, 105),
                ),
                hintText: "Email Adresinizi Giriniz.",
                errorStyle: TextStyle(fontSize: 16.0),
              ),
              validator: (value) {
                if (value == null) {
                  return "Lütfen Email Adresinizi Giriniz.";
                } else if (!value.contains("@")) {
                  return "Email Formatında Olmalı.";
                } else if (value.length < 5) {
                  return "Email 5 haneden küçük olamaz";
                }
              },
              onSaved: (newValue) {
                email = newValue;
              },
              autocorrect: true,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 40.0,
            ),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color.fromARGB(105, 105, 105, 105),
                ),
                hintText: "Şifrenizi Giriniz.",
                errorStyle: TextStyle(fontSize: 16.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Şifre alanı boş bırakılamaz";
                } else if (value.trim().length < 4) {
                  return "Şifre 4 karakterden az olamaz";
                }
              },
              onSaved: (newValue) {
                sifre = newValue;
              },
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 40.0,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HesapOlustur()));
                  },
                  child: const Text("Hesap Oluştur"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor)),
                )),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: ElevatedButton(
                  onPressed: girisYap,
                  child: const Text("Giriş Yap"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColorDark)),
                )),
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            const Center(child: Text("veya")),
            const SizedBox(
              height: 20.0,
            ),
            Center(
                child: GestureDetector(
                    onTap: () {},
                    child: InkWell(
                      onTap: _googleGiris,
                      child: const Text(
                        "Google ile Giriş Yap",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ))),
            const SizedBox(
              height: 20.0,
            ),
            Center(
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SifremiUnuttum(),
                          ));
                    },
                    child: Text("Şifremi Unuttum"))),
          ],
        ),
      )),
    );
  }

  void girisYap() async {
    var _authServis = Provider.of<AuthService>(context, listen: false);
    if (_formState.currentState!.validate()) {
      _formState.currentState!.save();
      setState(() {
        _yukleniyor = true;
      });

      try {
        await _authServis.mailGiris(email!, sifre!);
      } catch (hata) {
        if (mounted) {
          setState(() {
            _yukleniyor = false;

            uyariGoster(hataKodu: hata.hashCode);
          });
        }
      }
    }
  }

  void _googleGiris() async {
    var _authServis = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _yukleniyor = true;
    });

    try {
      Kullanici? kullanici = await _authServis.googleGiris();
      if (kullanici != null) {
        Kullanici? firestoreKullanici =
            await FireStoreServis().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FireStoreServis().kullaniciOlustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciAdi: kullanici.kullaniciAdi,
              fotoUrl: kullanici.fotoUrl);
          print("Kullanıcı dökümanı oluşturuldu");
        }
      }
      await _authServis.googleGiris();
    } catch (hata) {
      if (mounted) {
        setState(() {
          _yukleniyor = false;

          uyariGoster(hataKodu: hata.hashCode);
        });
      }
    }
  }

  uyariGoster({hataKodu}) {
    String? hataMesaji;
    print("deneme");

    if (hataKodu == "invalid-email".hashCode) {
      hataMesaji = "Böyle bir kullanıcı bulunmuyor.";
    } else if (hataKodu == 505284406) {
      hataMesaji = "Kullanıcı bulunamadı.";
    } else if (hataKodu == 185768934) {
      hataMesaji = "Girilen şifre hatalı.";
    } else if (hataKodu == 446151799) {
      hataMesaji = "Kullanıcı engellenmiş.";
    } else if (hataKodu == 0) {
      hataMesaji = "İnternet bağlantınızı kontrol edin.";
    } else {
      hataMesaji = "Bir hata oluştu. Birkaç dakika içinde tekrar deneyin.";
    }

    // 474761051 The service is currently unavailable. This is a most likely a transient condition and may be corrected by retrying with a backoff.

    var snackBar = SnackBar(
      content: Text(hataMesaji),
      backgroundColor: Colors.red,
    );
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // }

    _scaffoldM.currentState!.showSnackBar(snackBar);
  }
}
