import 'package:flutter/material.dart';
import 'package:socialapp/models/gonderi.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';

class TekliGonderi extends StatefulWidget {
  final String gonderiId;
  final String gonderiSahibiId;
  const TekliGonderi(
      {Key? key, required this.gonderiId, required this.gonderiSahibiId})
      : super(key: key);

  @override
  _TekliGonderiState createState() => _TekliGonderiState();
}

class _TekliGonderiState extends State<TekliGonderi> {
  Gonderi? _gonderi;
  Kullanici? _gonderiSahibi;
  bool _yukleniyor = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gonderiGetir();
  }

  gonderiGetir() async {
    Gonderi gonderi = await FireStoreServis()
        .tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiId);

    if (gonderi != null) {
      Kullanici? gonderiSahibi =
          await FireStoreServis().kullaniciGetir(widget.gonderiSahibiId);

      setState(() {
        _gonderi = gonderi;
        _gonderiSahibi = gonderiSahibi;
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          "Gönderi",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: !_yukleniyor
          ? GonderiKarti(gonderi: _gonderi!, yayinlayan: _gonderiSahibi!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
