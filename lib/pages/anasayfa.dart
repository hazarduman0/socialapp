import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/pages/akis.dart';
import 'package:socialapp/pages/ara.dart';
import 'package:socialapp/pages/duyurular.dart';
import 'package:socialapp/pages/profil.dart';
import 'package:socialapp/pages/yukle.dart';
import 'package:socialapp/services/auth_service.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _aktifSayfaNo = 0;
  PageController? sayfaKumandasi;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sayfaKumandasi!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? aktifKullaniciId =
        Provider.of<AuthService>(context, listen: false).aktifKullaniciId;
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifSayfaNo = acilanSayfaNo;
          });
        },
        controller: sayfaKumandasi,
        children: [
          const Akis(),
          const Ara(),
          const Yukle(),
          const Duyurular(),
          Profil(
            profilSahibiId: aktifKullaniciId,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifSayfaNo,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Akış"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Keşfet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), label: "Yükle"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Duyurular"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            _aktifSayfaNo = secilenSayfaNo;
            sayfaKumandasi!.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}
