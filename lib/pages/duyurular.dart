import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/duyuru.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/pages/profil.dart';
import 'package:socialapp/pages/tekligonderi.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurular extends StatefulWidget {
  const Duyurular({Key? key}) : super(key: key);

  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  late List<Duyuru> _duyurular;
  String? _aktifKullaniciId;
  bool _yukleniyor = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<AuthService>(context, listen: false).aktifKullaniciId;
    duyurulariGetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurulariGetir() async {
    List<Duyuru> duyurular =
        await FireStoreServis().duyurulariGetir(_aktifKullaniciId!);
    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  duyurulariGoster() {
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_duyurular.isEmpty) {
      return const Center(child: Text("Hiç duyurunuz yok."));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: RefreshIndicator(
        onRefresh: duyurulariGetir,
        child: ListView.builder(
          itemCount: _duyurular.length,
          itemBuilder: (context, index) {
            Duyuru duyuru = _duyurular[index];
            return duyuruSatiri(duyuru);
          },
        ),
      ),
    );
  }

  duyuruSatiri(Duyuru duyuru) {
    String mesaj = mesajOlustur(duyuru.aktiviteTipi);
    return FutureBuilder(
      future: FireStoreServis().kullaniciGetir(duyuru.aktiviteYapanId),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 0.0,
          );
        }

        Kullanici aktiviteYapan = snapshot.data;

        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Profil(profilSahibiId: duyuru.aktiviteYapanId),
                  ));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(aktiviteYapan.fotoUrl),
            ),
          ),
          title: RichText(
            text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Profil(profilSahibiId: duyuru.aktiviteYapanId),
                        ));
                  },
                text: "${aktiviteYapan.kullaniciAdi} ",
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: duyuru.yorum == null ? " $mesaj" : "$mesaj ${duyuru.yorum}",
                      style: const TextStyle(fontWeight: FontWeight.normal)),             
                ]),
          ),
          subtitle: Text(timeago.format(duyuru.olusturulmaZamani.toDate(), locale: "tr"), style: TextStyle(fontSize: 12.0),),
          trailing: gonderiGorsel(
              duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId),
        );
      },
    );
  }

  gonderiGorsel(String aktiviteTipi, String gonderiFoto, String gonderiId) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TekliGonderi(
                    gonderiId: gonderiId, gonderiSahibiId: _aktifKullaniciId!),
              ));
        },
        child: Image.network(
          gonderiFoto,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  mesajOlustur(String aktiviteTipi) {
    if (aktiviteTipi == "begeni") {
      return "gönderini beğendi";
    } else if (aktiviteTipi == "takip") {
      return "seni takip etti.";
    } else if (aktiviteTipi == "yorum") {
      return "gönderine yorum yaptı.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          "Duyurular",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: duyurulariGoster(),
    );
  }
}
