import 'package:flutter/material.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/pages/profil.dart';
import 'package:socialapp/services/firestore_service.dart';

class Ara extends StatefulWidget {
  const Ara({Key? key}) : super(key: key);

  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanici>>? _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey.shade100,
      title: TextFormField(
        onFieldSubmitted: (value) {
          //text alanına girilen bilgiler gönderildiğinde çalış
          setState(() {
            _aramaSonucu = FireStoreServis().kullaniciAra(value);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
            size: 30.0,
          ),
          suffixIcon: IconButton(
              onPressed: () {
                _aramaController.clear();
                setState(() {
                  _aramaSonucu = null;
                });
              },
              icon: const Icon(Icons.clear)),
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          hintText: "Kullanıcı Ara...",
          contentPadding: const EdgeInsets.only(top: 16.0),
        ),
      ),
    );
  }

  aramaYok() {
    return const Center(child: Text("Kullanici Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.length == 0) {
          return const Center(child: Text("Bu arama için sonuç bulunamadı!"));
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Kullanici kullanici = snapshot.data[index];
            return kullaniciSatiri(kullanici);
          },
        );
      },
    );
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profil(profilSahibiId: kullanici.id),
            ));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
