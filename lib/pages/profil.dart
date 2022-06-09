import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/gonderi.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/pages/profiliduzenle.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';

class Profil extends StatefulWidget {
  final String? profilSahibiId;
  const Profil({Key? key, required this.profilSahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  late int _gonderiSayisi;
  late int _takipci;
  late int _takipEdilen;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  late String? _aktifKullaniciId;
  Kullanici? _profilSahibi;
  bool _takipEdildi = false;

  _takipciSayisiGetir() async {
    var takipciSayisi =
        await FireStoreServis().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FireStoreServis().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FireStoreServis().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = _gonderiler.length;
      });
    }
  }

  _takipKontrol() async {
    bool takipVarMi = await FireStoreServis().takipKontrol(
        aktifKullaniciId: _aktifKullaniciId!,
        profilSahibiId: widget.profilSahibiId!);

    setState(() {
      _takipEdildi = takipVarMi;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    _aktifKullaniciId =
        Provider.of<AuthService>(context, listen: false).aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.1,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(
                  onPressed: _cikisYap,
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ))
              : const SizedBox(
                  height: 0.0,
                )
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Kullanici?>(
          future: FireStoreServis().kullaniciGetir(widget.profilSahibiId),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            _profilSahibi = snapshot.data;

            return ListView(
              children: [
                _profilDetaylari(snapshot.data),
                _gonderileriGoster(snapshot.data)
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
        shrinkWrap: true,
        primary:
            false, //physics parametresi eklenerektende çözülebilirdi // üst üste 2 kaydırılabilir widget//
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });
      return GridView.count(
        physics:
            NeverScrollableScrollPhysics(), //_gonderilerigoster() listview içerisinde // gridview ve listview kaydırılabilir widgetler // iki kaydırılabilir widget üst üste geldiğinde kaydırma özelliği çalışmaz
        crossAxisCount: 3,
        scrollDirection: Axis.vertical,
        shrinkWrap: true, //sadece ihtiyacın kadar alanı kapla
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0, // fayanslar arası mesafe bırakmak için
        childAspectRatio: 1.0, // eni boyuna eşit
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
      child: Image.network(
        gonderi.gonderiResmiUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 50.0,
                backgroundImage: profilData.fotoUrl.isNotEmpty
                    ? NetworkImage(profilData.fotoUrl)
                    : AssetImage("assets/images/earth.png") as ImageProvider,
              ),
              _sayac(_gonderiSayisi, "Gönderiler"),
              _sayac(_takipci, "Takipçi"),
              _sayac(_takipEdilen, "Takip"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profilData.kullaniciAdi,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(profilData.hakkinda)
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.profilSahibiId == _aktifKullaniciId
              ? _profiliDuzenleButonu()
              : _takipButonu(),
        )
      ],
    );
  }

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCikButonu() : _takipEtButonu();
  }

  Widget _takipEtButonu() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
        ),
        onPressed: () {
          FireStoreServis().takipEt(
              profilSahibiId: widget.profilSahibiId!,
              aktifKullaniciId: _aktifKullaniciId!);

          setState(() {
            _takipEdildi = true;
            _takipci = _takipci + 1;
          });
        },
        child: const Text(
          "Takip Et",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _takiptenCikButonu() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          FireStoreServis().takiptenCik(
              aktifKullaniciId: _aktifKullaniciId!,
              profilSahibiId: widget.profilSahibiId!);

          setState(() {
            _takipEdildi = false;
            _takipci = _takipci - 1;
          });
        },
        child: const Text(
          "Takipten Çık",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _cikisYap() {
    final _authServis = Provider.of<AuthService>(context, listen: false);
    _authServis.cikisYap();
  }

  Widget _sayac(int sayi, String durum) {
    return Column(
      children: [
        Text(
          "$sayi",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(durum)
      ],
    );
  }

  Widget _profiliDuzenleButonu() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfiliDuzenle(
                        profil: _profilSahibi!,
                      )));
        },
        child: const Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
