import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/pages/anasayfa.dart';
import 'package:socialapp/pages/girissayfasi.dart';
import 'package:socialapp/services/auth_service.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final _authServis = Provider.of<AuthService>(context,listen: false);

    return StreamBuilder(
      stream: _authServis.durumTakipcisi,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          Kullanici aktifKullanici = snapshot.data;
          _authServis.aktifKullaniciId = aktifKullanici.id;
          return AnaSayfa();
        } else {
          return GirisSayfasi();
        }
      },
    );
  }
}
