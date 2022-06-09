import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/services/auth_service.dart';
import 'package:socialapp/services/firestore_service.dart';
import 'package:socialapp/services/storageservisi.dart';

class Yukle extends StatefulWidget {
  const Yukle({Key? key}) : super(key: key);

  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File? dosya;
  bool yukleniyor = false;

  TextEditingController? aciklamaTextKumandasi = TextEditingController();
  TextEditingController? konumTextKumandasi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        onPressed: () {
          fotografSec();
        },
        icon: const Icon(
          Icons.file_upload,
          size: 50.0,
        ));
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              setState(() {
                dosya = null;
              });
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        actions: [
          IconButton(
              onPressed: _gonderiOlustur,
              icon: const Icon(
                Icons.send,
                color: Colors.black,
              ))
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? const LinearProgressIndicator()
              : const SizedBox(
                  height: 0.0,
                ),
          AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Image.file(
                dosya!,
                fit: BoxFit.cover,
              )),
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: aciklamaTextKumandasi,
            validator: (value) {},
            decoration: const InputDecoration(
                hintText: "Açıklama Ekle",
                contentPadding: EdgeInsets.only(left: 15.0, right: 15.0)),
          ),
          TextFormField(
            controller: konumTextKumandasi,
            decoration: const InputDecoration(
                hintText: "Fotoğraf Nerede Çekildi?",
                contentPadding: EdgeInsets.only(left: 15.0, right: 15.0)),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      //Butona 1 den fazla kere basıldığında işlem yapmaması için önlem
      setState(() {
        yukleniyor = true;
      });
      
      String resimUrl = await StorageServisi().gonderiResmiYukle(dosya!);
      String? aktifKullaniciId =
          Provider.of<AuthService>(context, listen: false).aktifKullaniciId;

      await FireStoreServis().gonderiOlustur(
          gonderiResmiUrl: resimUrl,
          aciklama: aciklamaTextKumandasi!.text,
          yayinlayanId: aktifKullaniciId,
          konum: konumTextKumandasi!.text);

      setState(() {
        yukleniyor = false;
        aciklamaTextKumandasi!.clear();
        konumTextKumandasi!.clear();  //Text alanlarına girilen bilgilerin silinmesini sağlar.
        dosya = null;
      });    
    }
  }

  fotografSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Gönderi Oluştur"),
            children: [
              SimpleDialogOption(
                child: const Text("Fotoğraf Çek"),
                onPressed: () {
                  fotoCek();
                  
                },
              ),
              SimpleDialogOption(
                child: const Text("Galeriden Yükle"),
                onPressed: () {
                  galeridenSec();
                },
              ),
              SimpleDialogOption(
                child: const Text("İptal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  fotoCek() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image!.path);
      Navigator.pop(context);
    });
  }

  galeridenSec() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image!.path);
      Navigator.pop(context);
    });
  }
}
