import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/gonderi.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/pages/profil.dart';
import 'package:socialapp/pages/yorumlar.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;
  const GonderiKarti(
      {Key? key, required this.gonderi, required this.yayinlayan})
      : super(key: key);

  @override
  State<GonderiKarti> createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  late String _aktifKullaniciId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<AuthService>(context, listen: false).aktifKullaniciId!;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi =
        await FireStoreServis().begeniVarmi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [_gonderiBasligi(), _gonderiResmi(context), _gonderiAlt()],
        ));
  }

  gonderiSecenekleri() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Seçiminiz Nedir?"),
          children: [
            SimpleDialogOption(
              child: const Text("Gönderiyi Sil"),
              onPressed: () {
                FireStoreServis().gonderiSil(
                    aktifKullaniciId: _aktifKullaniciId,
                    gonderi: widget.gonderi);
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: const Text(
                "Vazgeç",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Profil(profilSahibiId: widget.gonderi.yayinlayanId)));
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
                ? NetworkImage(widget.yayinlayan.fotoUrl)
                : AssetImage("assets/images/earth.png") as ImageProvider,
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Profil(profilSahibiId: widget.gonderi.yayinlayanId)));
        },
        child: Text(
          widget.yayinlayan.kullaniciAdi,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayanId
          ? IconButton(
              onPressed: () => gonderiSecenekleri(),
              icon: const Icon(Icons.more_vert))
          : null,
      contentPadding: const EdgeInsets.all(
          0.0), //default ayarlarda ListTile nin padding i var
    );
  }

  Widget _gonderiResmi(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: _begeniDegistir,
                icon: !_begendin
                    ? const Icon(
                        Icons.favorite_border,
                        size: 35.0,
                      )
                    : const Icon(
                        Icons.favorite,
                        size: 35.0,
                        color: Colors.red,
                      )),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Yorumlar(gonderi: widget.gonderi),
                    ));
              },
              icon: const Icon(
                Icons.comment,
                size: 35.0,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                      text: widget.yayinlayan.kullaniciAdi + " ",
                      style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text: widget.gonderi.aciklama,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14.0)
                            // style girmezsen bir önceki textin stylesini alır.
                            ),
                      ]),
                ),
              )
            : const SizedBox(
                height: 0.0,
              )
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FireStoreServis().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    } else {
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServis().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}
