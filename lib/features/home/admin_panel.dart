import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? scannedUid;
  final TextEditingController _amountController = TextEditingController();
  
  // Kontrolery dla danych firmy
  final TextEditingController _salonNameController = TextEditingController();
  final TextEditingController _companyDetailsController = TextEditingController();
  
  bool _isSending = false;
  int _tabIndex = 0; // 0 - Terminal, 1 - Ustawienia

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  // Pobieranie aktualnych danych salonu z Firebase
  void _loadBusinessData() async {
    var doc = await FirebaseFirestore.instance.collection('settings').doc('business_info').get();
    if (doc.exists) {
      setState(() {
        _salonNameController.text = doc.data()?['salonName'] ?? '';
        _companyDetailsController.text = doc.data()?['companyDetails'] ?? '';
      });
    }
  }

  // Zapisywanie danych salonu
  void _saveBusinessData() async {
    setState(() => _isSending = true);
    try {
      await FirebaseFirestore.instance.collection('settings').doc('business_info').set({
        'salonName': _salonNameController.text,
        'companyDetails': _companyDetailsController.text,
        'lastEdit': FieldValue.serverTimestamp(),
      });
      _showMsg("DANE ZAKTUALIZOWANE", Colors.green);
    } catch (e) {
      _showMsg("BŁĄD ZAPISU: $e", Colors.red);
    } finally {
      setState(() => _isSending = false);
    }
  }

  // --- LOGIKA TRANSAKCJI I NAGRÓD (BEZ ZMIAN) ---
  void _submitTransaction(String uid) async {
    if (_amountController.text.isEmpty) return;
    double? amountInput = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amountInput == null || amountInput <= 0) {
      _showMsg("WPISZ POPRAWNĄ KWOTĘ", Colors.red);
      return;
    }

    int pointsToIncrement = (amountInput * 2).toInt();
    setState(() => _isSending = true);

    try {
      final db = FirebaseFirestore.instance;
      // Pobieramy nazwę salonu do historii
      String salon = _salonNameController.text.isEmpty ? "Koliber Lux" : _salonNameController.text;

      await db.runTransaction((transaction) async {
        final userRef = db.collection('users').doc(uid);
        final historyRef = userRef.collection('history').doc();
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          transaction.set(userRef, {'points': pointsToIncrement, 'name': 'Nowy Klient', 'tier': 'Standard'});
        } else {
          transaction.update(userRef, {'points': FieldValue.increment(pointsToIncrement)});
        }

        transaction.set(historyRef, {
          'title': 'Zakupy: $salon',
          'points': pointsToIncrement,
          'amount': amountInput,
          'date': FieldValue.serverTimestamp(),
          'type': 'purchase',
        });
      });

      _showMsg("DODANO $pointsToIncrement PKT", Colors.green);
      setState(() { scannedUid = null; _amountController.clear(); });
    } catch (e) { _showMsg("BŁĄD: $e", Colors.red); }
    finally { setState(() => _isSending = false); }
  }

  void _showClaimRewardDialog(String transactionId, String customerUid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(customerUid).collection('history').doc(transactionId).get(),
        builder: (context, snapshot) {
          String rewardTitle = snapshot.hasData ? (snapshot.data!['title'] ?? "Nagroda") : "Sprawdzam...";
          return AlertDialog(
            backgroundColor: const Color(0xFF121212),
            title: const Text("WYDAĆ NAGRODĘ?", style: TextStyle(color: Colors.amber)),
            content: Text(rewardTitle.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANULUJ")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('users').doc(customerUid).collection('history').doc(transactionId).update({
                    'status': 'claimed',
                    'claimedAt': _salonNameController.text // Zapisujemy gdzie wydano
                  });
                  Navigator.pop(context);
                  _showMsg("WYDANO!", Colors.green);
                },
                child: const Text("POTWIERDŹ", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showMsg(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: color, content: Text(text, textAlign: TextAlign.center)));
  }

  void _showScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final code = capture.barcodes.first.rawValue;
            if (code != null) {
              Navigator.pop(context);
              if (code.startsWith("REWARD|")) {
                final parts = code.split("|");
                _showClaimRewardDialog(parts[1], parts[2]);
              } else {
                setState(() { scannedUid = code; _amountController.clear(); });
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ADMIN PANEL", style: TextStyle(fontSize: 12, letterSpacing: 4, color: Colors.amber)),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton(0, "TERMINAL", Icons.qr_code_scanner),
              _tabButton(1, "USTAWIENIA", Icons.settings),
            ],
          ),
        ),
      ),
      body: _tabIndex == 0 ? _buildTerminal() : _buildSettings(),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) {
    bool active = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? Colors.amber : Colors.transparent, width: 2))),
        child: Row(children: [
          Icon(icon, size: 16, color: active ? Colors.amber : Colors.white24),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: active ? Colors.amber : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  // WIDOK 1: TERMINAL (SKANOWANIE)
  Widget _buildTerminal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (scannedUid == null) ...[
            const Icon(Icons.store, color: Colors.white10, size: 80),
            const SizedBox(height: 10),
            Text(_salonNameController.text.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _showScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("SKANUJ KLIENTA"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60)),
            ),
          ] else ...[
            const Text("NALICZANIE PUNKTÓW", style: TextStyle(color: Colors.amber, letterSpacing: 2)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 48),
              decoration: const InputDecoration(hintText: "0.00", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none),
              onChanged: (v) => setState(() {}),
            ),
            ElevatedButton(
              onPressed: _isSending ? null : () => _submitTransaction(scannedUid!),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60)),
              child: _isSending ? const CircularProgressIndicator() : const Text("ZATWIERDŹ"),
            ),
            TextButton(onPressed: () => setState(() => scannedUid = null), child: const Text("ANULUJ", style: TextStyle(color: Colors.white24))),
          ]
        ],
      ),
    );
  }

  // WIDOK 2: USTAWIENIA SALONU
  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("NAZWA SALONU", style: TextStyle(color: Colors.amber, fontSize: 10, letterSpacing: 2)),
          TextField(
            controller: _salonNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10))),
          ),
          const SizedBox(height: 30),
          const Text("DANE FIRMY / ADRES", style: TextStyle(color: Colors.amber, fontSize: 10, letterSpacing: 2)),
          TextField(
            controller: _companyDetailsController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10))),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isSending ? null : _saveBusinessData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            child: _isSending ? const CircularProgressIndicator() : const Text("ZAPISZ ZMIANY"),
          ),
        ],
      ),
    );
  }
}