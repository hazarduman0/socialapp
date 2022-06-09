import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/services/auth_service.dart';

class SifremiUnuttum extends StatefulWidget {
  const SifremiUnuttum({ Key? key }) : super(key: key);

  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  late final String email;
  final _formState = GlobalKey<FormState>();
  final _scaffoldM = GlobalKey<ScaffoldMessengerState>();

  bool _ilkDokunma = true;
  bool _yukleniyor = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back)),
        title: const Text("Şifremi Sıfırla"),
      ),
      body: Stack(
        children: [sayfaElemanlari(), yukleniyor()],
      ),
    );
  }

  Widget yukleniyor() {
    if (_yukleniyor) {
      return const LinearProgressIndicator(
        backgroundColor: Colors.white,
      );
    } else {
      return const SizedBox(
        height: 0.0,
      );
    }
  }

  Widget sayfaElemanlari() {
    return ScaffoldMessenger(
      key: _scaffoldM,
      child: Form(
        key: _formState,
        child: ListView(
          padding: const EdgeInsets.only(top: 10, left: 15.0, right: 15.0),
          children: [
            const SizedBox(
              height: 30.0,
            ),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.mail),
                labelText: "E-Posta:",
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: "E-Postanızı Giriniz.",
                hintStyle: TextStyle(color: Colors.grey.shade700),
                errorStyle: const TextStyle(fontSize: 20.0),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Bu boş bırakamazsınız.";
                } else if (value.length < 5) {
                  return "Kullanıcı adı 5 karakterden az olamaz";
                } else if (!value.contains("@")) {
                  return "E-Posta formatına uygun olmalı";
                }
              },
              onSaved: (newValue) {
                email = newValue!;
              },
            ),
            const SizedBox(
              height: 50.0,
            ),
            ElevatedButton(
              onPressed: () {
                if(_ilkDokunma){
                  _ilkDokunma = false;
                  _sifreyiSifirla();
                }
              },
              child: const Text(
                "Şifremi Sıfırla",
                style: TextStyle(fontSize: 20.0),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor)),
            )
          ],
        ),
      ),
    );
  }

  void _sifreyiSifirla() async {
    var _form = _formState.currentState!;
    final _authService =
        Provider.of<AuthService>(context, listen: false);
    if (_form.validate()) {
      _form.save();
      setState(() {
        _yukleniyor = true;
      });
      try {
        await _authService.sifremiSifirla(email);
        Navigator.of(context).pop();
      } catch (hata) {
        setState(() {
          _yukleniyor = false;
        });
        print(hata.hashCode);
        uyariGoster(hataKodu: hata.hashCode);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String? hataMesaji;

    if (hataKodu == 505284406) {
      hataMesaji = "Böyle bir kullanıcı bulunmuyor.";
    } else if (hataKodu == 360587416) {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir.";
    } else if (hataKodu == 446151799) {
      hataMesaji = "Kullanıcı engellenmiş.";
    } else if (hataKodu == 0) {
      hataMesaji = "İnternet bağlantınızı kontrol edin.";
    }  else {
      hataMesaji = "Bir hata oluştu. Birkaç dakika içinde tekrar deneyin.";
    }

    // 474761051 The service is currently unavailable. This is a most likely a transient condition and may be corrected by retrying with a backoff.

    var snackBar = SnackBar(content: Text('$hataMesaji'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    //_scaffoldM.currentState!.showSnackBar(snackBar);
  }

}