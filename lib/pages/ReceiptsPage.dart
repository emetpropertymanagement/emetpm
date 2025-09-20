import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'AppLayout.dart';

class ReceiptsPage extends StatelessWidget {
  const ReceiptsPage({super.key});

  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<String> searchQuery = ValueNotifier('');
    return AppLayout(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by client name or month...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                onChanged: (value) {
                  searchQuery.value = value.trim().toLowerCase();
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: searchQuery,
                builder: (context, query, _) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('receipts')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading receipts.'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final clientName =
                            (data['clientName'] ?? '').toString().toLowerCase();
                        final monthNum = data['month'] ?? 1;
                        final monthStr = monthNames[(monthNum - 1).clamp(0, 11)]
                            .toLowerCase();
                        return query.isEmpty ||
                            clientName.contains(query) ||
                            monthStr.contains(query);
                      }).toList();
                      if (docs.isEmpty) {
                        return const Center(child: Text('No receipts found.'));
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final clientName = data['clientName'] ?? 'N/A';
                          final monthNum = data['month'] ?? 1;
                          final monthStr =
                              monthNames[(monthNum - 1).clamp(0, 11)];
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(child: Text(clientName)),
                                Text(monthStr,
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  tooltip: 'View Details',
                                  onPressed: () => _showReceiptDetails(
                                      context, data, docs[index].id),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDetails(
      BuildContext context, Map<String, dynamic> data, String docId) {
    final numberFormat = NumberFormat('#,##0');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Receipt Details'),
          content: SingleChildScrollView(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside:
                    BorderSide(width: 1, color: Colors.grey.shade300),
              ),
              children: [
                _tableRow('Client', data['clientName']),
                _tableRow('Property', data['propertyName']),
                _tableRow(
                    'Amount',
                    data['amount'] != null
                        ? 'UGX ${numberFormat.format(data['amount'])}'
                        : ''),
                _tableRow('Amount in Words', data['amountInWords']),
                _tableRow('Reason', data['reason']),
                _tableRow(
                    'Balance',
                    data['balance'] != null
                        ? 'UGX ${numberFormat.format(data['balance'])}'
                        : ''),
                _tableRow('Next Payment', data['nextPaymentDate']),
                _tableRow('Month', data['month']?.toString()),
                _tableRow('Year', data['year']?.toString()),
                if (data['receiptPdfUrl'] != null)
                  TableRow(children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                      child: Text('PDF:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 4.0),
                      child: TextButton(
                        onPressed: () =>
                            launchUrl(Uri.parse(data['receiptPdfUrl'])),
                        child: const Text('Open PDF'),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Receipt'),
                    content: const Text(
                        'Are you sure you want to delete this receipt?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await FirebaseFirestore.instance
                      .collection('receipts')
                      .doc(docId)
                      .delete();
                  Navigator.of(context).pop();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              tooltip: 'Download',
              onPressed: () async {
                final url = data['receiptPdfUrl'];
                if (url != null) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  TableRow _tableRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Text(value ?? ''),
        ),
      ],
    );
  }

  // Download logic handled in the details dialog above.
}
