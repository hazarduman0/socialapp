import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/gonderi.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/models/yorum.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;


class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;
  const Yorumlar({Key? key, required this.gonderi}) : super(key: key);

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  final TextEditingController _yorumKontrolcusu = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          "Yorumlar",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [_yorumlariGoster(), _yorumEkle()],
      ),
    );
  }

  _yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FireStoreServis().yorumlariGetir(widget.gonderi.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Yorum yorum = Yorum.dokumandanUret(snapshot.data!.docs[index]);
            //her bir yorum dökümanını gönderiyoruz.
            return _yorumSatiri(yorum);
          },
        );
      },
    ));
  }

  _yorumSatiri(Yorum yorum) {
    return FutureBuilder<Kullanici?>(
        future: FireStoreServis().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {

          if(!snapshot.hasData){
            return const SizedBox(height: 0.0,);
          }

          Kullanici yayinlayan = snapshot.data!;

          return ListTile(
            leading:  CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan.fotoUrl),
            ),
            title: RichText(
              text: TextSpan(
                  text: yayinlayan.kullaniciAdi + " ",
                  style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: yorum.icerik,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14.0)
                        // style girmezsen bir önceki textin stylesini alır.
                        ),
                  ]),
            ),
            subtitle: Text(timeago.format(yorum.olusturulmaZamani.toDate(), locale: "tr")),
          );
        });
  }

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrolcusu,
        decoration: const InputDecoration(hintText: "Yorumu buraya yazın"),
      ),
      trailing: IconButton(onPressed: _yorumGonder, icon: Icon(Icons.send)),
    );
  }

  void _yorumGonder() {
    String? aktifKullaniciId =
        Provider.of<AuthService>(context, listen: false).aktifKullaniciId;
    FireStoreServis().yorumEkle(
        aktifKullaniciId: aktifKullaniciId,
        gonderi: widget.gonderi,
        icerik: _yorumKontrolcusu.text);
    _yorumKontrolcusu.clear();
  }
}
