import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/gonderi.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';
import 'package:socialapp/widgetlar/silinmeyenFutureBuilder.dart';

class Akis extends StatefulWidget {
  const Akis({Key? key}) : super(key: key);

  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];

  _akisGonderileriniGetir() async {
    String? aktifKullaniciId =
        Provider.of<AuthService>(context, listen: false).aktifKullaniciId;
    List<Gonderi> gonderiler =
        await FireStoreServis().akisGonderileriniGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _akisGonderileriniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SocialApp"),
        centerTitle: true,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        primary:
            false, //physics parametresi eklenerektende çözülebilirdi // üst üste 2 kaydırılabilir widget//
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          Gonderi gonderi = _gonderiler[index];

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SilinmeyenFutureBuilder(
              future: FireStoreServis().kullaniciGetir(gonderi.yayinlayanId),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return //const SizedBox();
                      Text("Yükleniyor");
                }

                Kullanici gonderiSahibi = snapshot.data;

                return GonderiKarti(
                  gonderi: gonderi,
                  yayinlayan: gonderiSahibi,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
