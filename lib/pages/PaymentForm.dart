import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:emet/pages/AppLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'ReceiptsPage.dart';
import 'SendSms.dart';

class PaymentForm extends StatefulWidget {
  final Map<String, dynamic> clientDetails;

  const PaymentForm({super.key, required this.clientDetails});

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final SendSMS smsSender = SendSMS();
  int? _receiptNumber;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController amountInWordsController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController nextDateController = TextEditingController();

  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    reasonController.text =
        'Rent for ${DateTime.now().month}/${DateTime.now().year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          const Text("CREATE RECEIPT",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('For: ${widget.clientDetails["name"]}',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20.0),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: amountController,
                  decoration:
                      const InputDecoration(labelText: 'Amount (Figures)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Required Field' : null,
                ),
                TextFormField(
                  controller: amountInWordsController,
                  decoration:
                      const InputDecoration(labelText: 'Amount in Words'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required Field' : null,
                ),
                TextFormField(
                  controller: reasonController,
                  decoration:
                      const InputDecoration(labelText: 'Reason for payment'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required Field' : null,
                ),
                TextFormField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: 'Balance'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: nextDateController,
                  decoration:
                      const InputDecoration(labelText: 'Next Payment on:'),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (picked != null) {
                      nextDateController.text =
                          "${picked.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                const SizedBox(height: 30.0),
                if (_isSubmitting)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(value: _uploadProgress),
                  ),
                const SizedBox(height: 10.0),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitPayment,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("Create & Save Receipt"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      // Get and increment receipt number from Firestore
      int receiptNumber = await _getAndIncrementReceiptNumber();
      setState(() {
        _receiptNumber = receiptNumber;
      });

      final pdfFile = await _createReceipt(receiptNumber);
      if (pdfFile == null) throw Exception("Failed to create PDF.");

      final String downloadUrl = await _uploadPdf(pdfFile);

      await _saveReceiptToFirestore(downloadUrl, receiptNumber);

      // --- SMS Section ---
      String name = widget.clientDetails['name'] ?? '';
      String phoneRaw = widget.clientDetails['phone']?.toString() ?? '';
      String balance = balanceController.text;
      String nextDate = nextDateController.text;

      // Format phone number to 256XXXXXXXXX
      String phone = phoneRaw.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.startsWith('0')) {
        phone = '256' + phone.substring(1);
      } else if (phone.length == 9) {
        phone = '256' + phone;
      } else if (phone.length == 10 && phone.startsWith('256')) {
        // already correct
      } else if (phone.length == 12 && phone.startsWith('256')) {
        // already correct
      } else {
        phone = '256773913902'; // fallback
      }

      String message =
          'Dear $name, thanks for your rent payment! Balance: UGX $balance. Next payment due $nextDate. We appreciate you. – Emet Property Management.';
      await smsSender.sendSms(message, phone);
      // --- End SMS Section ---

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Receipt created and saved successfully!'),
            backgroundColor: Colors.green),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ReceiptsPage()),
        (route) => false,
      );
    } catch (e) {
      print("An error occurred during payment submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<String> _uploadPdf(File file) async {
    try {
      final int year = DateTime.now().year;
      final int month = DateTime.now().month;
      const List<String> monthNames = [
        'january',
        'february',
        'march',
        'april',
        'may',
        'june',
        'july',
        'august',
        'september',
        'october',
        'november',
        'december'
      ];
      final String monthName = monthNames[month - 1];
      String clientName = (widget.clientDetails['name'] ?? 'client')
          .toString()
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .toLowerCase();
      // fileName is now in filePath, so no need for a separate variable
      final String apartment =
          (widget.clientDetails['propertyName'] ?? 'unknown_apartment')
              .toString()
              .replaceAll('/', '_');
      final String filePath =
          '$apartment/$year/$monthName/${clientName}_$monthName-$year.pdf';
      final ref = FirebaseStorage.instance.ref().child(filePath);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading PDF to Firebase Storage: $e");
      rethrow; // Rethrow to be caught by the main handler
    }
  }

  Future<void> _saveReceiptToFirestore(String pdfUrl, int receiptNumber) async {
    try {
      await FirebaseFirestore.instance.collection('receipts').add({
        'clientId': widget.clientDetails['id'],
        'clientName': widget.clientDetails['name'],
        'propertyId': widget.clientDetails['propertyId'],
        'propertyName': widget.clientDetails['propertyName'],
        'amount': double.tryParse(amountController.text) ?? 0,
        'amountInWords': amountInWordsController.text,
        'reason': reasonController.text,
        'balance': double.tryParse(balanceController.text) ?? 0,
        'nextPaymentDate': nextDateController.text,
        'receiptPdfUrl': pdfUrl,
        'createdAt': Timestamp.now(),
        'month': DateTime.now().month,
        'year': DateTime.now().year,
        'receiptNumber': receiptNumber,
      });
    } catch (e) {
      print("Error saving receipt to Firestore: $e");
      rethrow; // Rethrow to be caught by the main handler
    }
  }

  Future<File?> _createReceipt(int receiptNumber) async {
    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      // Draw background image
      final ByteData imageData = await rootBundle.load('assets/receipt.png');
      final List<int> imageBytes = imageData.buffer.asUint8List();
      final PdfBitmap bgImage = PdfBitmap(imageBytes);
      page.graphics.drawImage(
          bgImage,
          Rect.fromLTWH(
              0, 0, page.getClientSize().width, page.getClientSize().height));

      // Add 250px top gap, plus extra 20px below receipt number
      double tableTop = 250 + 20;

      // Draw date at top left and receipt number at top right, both on same line
      String receiptDate = "${DateTime.now().toLocal()}".split(' ')[0];
      double headerTop = tableTop - 40;
      // Date top left
      page.graphics.drawString(
        'Date: $receiptDate',
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        brush: PdfSolidBrush(PdfColor(128, 128, 128)),
        bounds: Rect.fromLTWH(40, headerTop, 200, 20),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.top,
        ),
      );
      // 'Receipt number' and actual number on same row, right-aligned
      String receiptLabel = 'Receipt number: ';
      String receiptNumStr = receiptNumber.toString().padLeft(6, '0');
      // Draw label
      page.graphics.drawString(
        receiptLabel,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        brush: PdfSolidBrush(PdfColor(128, 128, 128)),
        bounds:
            Rect.fromLTWH(page.getClientSize().width - 300, headerTop, 120, 20),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.top,
        ),
      );
      // Draw number right next to label, bold and red
      page.graphics.drawString(
        receiptNumStr,
        PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(220, 0, 0)),
        bounds: Rect.fromLTWH(
            page.getClientSize().width - 180, headerTop - 2, 160, 30),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.top,
        ),
      );

      // Prepare table data (no header row, no date)
      final List<List<String>> tableData = [
        ['Client', widget.clientDetails['name'] ?? ''],
        ['Property', widget.clientDetails['propertyName'] ?? ''],
        ['Amount', 'UGX ${_formatMoney(amountController.text)}'],
        ['In Words', amountInWordsController.text],
        ['Month', reasonController.text],
        ['Balance', 'UGX ${_formatMoney(balanceController.text)}'],
        ['Next Payment', nextDateController.text],
      ];

      // Create PdfGrid (no header)
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 2);
      for (final row in tableData) {
        final gridRow = grid.rows.add();
        gridRow.cells[0].value = row[0];
        gridRow.cells[1].value = row[1];
      }

      // Style
      grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 8, right: 8, top: 6, bottom: 6),
        font: PdfStandardFont(PdfFontFamily.helvetica, 13),
        borderOverlapStyle: PdfBorderOverlapStyle.inside,
        cellSpacing: 0,
      );
      // Enable text wrapping for all data cells
      for (int r = 0; r < grid.rows.count; r++) {
        for (int c = 0; c < grid.rows[r].cells.count; c++) {
          grid.rows[r].cells[c].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle,
            wordWrap: PdfWordWrapType.word,
          );
        }
      }

      // Draw the grid at 250px from the top
      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(40, tableTop, page.getClientSize().width - 80, 0),
      );

      final List<int> bytes = await document.save();
      document.dispose();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error creating PDF: $e");
      return null;
    }
  }

  // Get and increment receipt number from Firestore
  Future<int> _getAndIncrementReceiptNumber() async {
    final settingsDoc =
        FirebaseFirestore.instance.collection('settings').doc('receipt_number');
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(settingsDoc);
      int currentNumber = 1;
      if (snapshot.exists &&
          snapshot.data() != null &&
          snapshot.data()!.containsKey('current')) {
        currentNumber = snapshot.data()!['current'] as int;
      } else if (snapshot.exists &&
          snapshot.data() != null &&
          snapshot.data()!.containsKey('start')) {
        currentNumber = snapshot.data()!['start'] as int;
      }
      transaction.set(
          settingsDoc, {'current': currentNumber + 1}, SetOptions(merge: true));
      return currentNumber;
    });
  }

  String _formatMoney(String value) {
    try {
      final n = double.tryParse(value.replaceAll(',', '')) ?? 0;
      return n
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    } catch (_) {
      return value;
    }
  }
}
