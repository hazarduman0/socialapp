import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/users.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:socialapp/services/storageservisi.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici profil;
  const ProfiliDuzenle({Key? key, required this.profil}) : super(key: key);

  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String? _kullaniciAdi;
  String? _hakkinda;
  File? _secilmisFoto;
  bool _yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            color: Colors.black,
            onPressed: _kaydet,
          ),
        ],
      ),
      body: ListView(
        children: [
          _yukleniyor == true
              ? const LinearProgressIndicator()
              : const SizedBox(
                  height: 0.0,
                ),
          _profilFoto(),
          _kullaniciBilgileri()
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _yukleniyor = true;
      });
      _formKey.currentState!.save();

      String profilFotuUrl;
      if (_secilmisFoto == null) {
        profilFotuUrl = widget.profil.fotoUrl;
      } else {
        profilFotuUrl = await StorageServisi().profilResmiYukle(_secilmisFoto!);
      }

      String? aktifKullaniciId =
          Provider.of<AuthService>(context, listen: false).aktifKullaniciId;

      FireStoreServis().kullaniciGuncelle(
          kullaniciId: aktifKullaniciId,
          kullaniciAdi: _kullaniciAdi,
          hakkinda: _hakkinda,
          fotoUrl: profilFotuUrl);

      setState(() {
        _yukleniyor = false;
      });

      Navigator.pop(context);    
    }
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        child: InkWell(
          onTap: _galeridenSec,
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: _secilmisFoto == null
                ? NetworkImage(widget.profil.fotoUrl)
                : FileImage(_secilmisFoto!) as ImageProvider,
            radius: 55.0,
          ),
        ),
      ),
    );
  }

  _galeridenSec() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _secilmisFoto = File(image!.path);
    });
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            TextFormField(
              initialValue: widget.profil.kullaniciAdi,
              decoration: const InputDecoration(labelText: "Kullanıcı Adı"),
              validator: (value) {
                return value!.trim().length <= 3
                    ? "Kullanıcı adı en az 4 karakter olmalı"
                    : null;
              },
              onSaved: (newValue) {
                _kullaniciAdi = newValue;
              },
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda,
              decoration: const InputDecoration(labelText: "Hakkında"),
              validator: (value) {
                return value!.trim().length > 100
                    ? "100 Karakterden fazla olmamalı"
                    : null;
              },
              onSaved: (newValue) {
                _hakkinda = newValue;
              },
            ),
          ],
        ),
      ),
    );
  }
}
