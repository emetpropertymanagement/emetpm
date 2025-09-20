import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:emet/pages/AppLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PaymentForm extends StatefulWidget {
  final Map<String, dynamic> clientDetails;

  const PaymentForm({super.key, required this.clientDetails});

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
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
    reasonController.text = 'Rent for ${DateTime.now().month}/${DateTime.now().year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          const Text("CREATE RECEIPT", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('For: ${widget.clientDetails["name"]}', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20.0),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount (Figures)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required Field' : null,
                ),
                TextFormField(
                  controller: amountInWordsController,
                  decoration: const InputDecoration(labelText: 'Amount in Words'),
                  validator: (value) => value!.isEmpty ? 'Required Field' : null,
                ),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Reason for payment'),
                  validator: (value) => value!.isEmpty ? 'Required Field' : null,
                ),
                TextFormField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: 'Balance'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: nextDateController,
                  decoration: const InputDecoration(labelText: 'Next Payment on:'),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                        context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
                    if (picked != null) {
                      nextDateController.text = "${picked.toLocal()}".split(' ')[0];
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
      final pdfFile = await _createReceipt();
      if (pdfFile == null) throw Exception("Failed to create PDF.");

      final String downloadUrl = await _uploadPdf(pdfFile);

      await _saveReceiptToFirestore(downloadUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt created and saved successfully!'), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop();

    } catch (e) {
      print("An error occurred during payment submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<String> _uploadPdf(File file) async {
    try {
      final String fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = 'receipts/${DateTime.now().year}/${DateTime.now().month}/$fileName';
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

  Future<void> _saveReceiptToFirestore(String pdfUrl) async {
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
      });
    } catch (e) {
      print("Error saving receipt to Firestore: $e");
      rethrow; // Rethrow to be caught by the main handler
    }
  }

  Future<File?> _createReceipt() async {
    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      page.graphics.drawString('RECEIPT', PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold));
      
      double y = 50;
      void drawLine(String label, String value) {
        page.graphics.drawString('$label: $value', PdfStandardFont(PdfFontFamily.helvetica, 12), bounds: Rect.fromLTWH(0, y, 500, 20));
        y += 25;
      }

      drawLine('Client', widget.clientDetails['name']);
      drawLine('Property', widget.clientDetails['propertyName']);
      drawLine('Amount', amountController.text);
      drawLine('In Words', amountInWordsController.text);
      drawLine('For', reasonController.text);
      drawLine('Balance', balanceController.text);
      drawLine('Next Payment', nextDateController.text);
      drawLine('Date', "${DateTime.now().toLocal()}".split(' ')[0]);

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
}
