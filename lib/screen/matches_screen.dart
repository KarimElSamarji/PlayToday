import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playtoday/screen/details_screen.dart';

class MatchesPage extends StatefulWidget {
  final String parameter;

  const MatchesPage({super.key, required this.parameter});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  late String parameter;
  late Stream<QuerySnapshot> _documentsStream;
  String filterAdmin = ''; // Store the selected admin filter value
  DateTime? filterDate; // Store the selected date filter value

  @override
  void initState() {
    parameter = widget.parameter;
    super.initState();

    // Replace 'collectionPath' with the actual path to your Firestore collection
    _documentsStream = FirebaseFirestore.instance
        .collection('matches')
        .where('StadeName', isEqualTo: parameter)
        .snapshots();
  }

  void _applyFilters() {
    // Apply the selected filters to the stream query
    Query query = FirebaseFirestore.instance
        .collection('matches')
        .where('StadeName', isEqualTo: parameter);

    // Apply admin filter
    if (filterAdmin.isNotEmpty) {
      query = query.where('Admin', isEqualTo: filterAdmin);
    } else {
      query = FirebaseFirestore.instance
          .collection('matches')
          .where('StadeName', isEqualTo: parameter);
    }

    // // Apply date filter
    // if (filterDate != null) {
    //   // Construct a DateTime range for the selected date
    //   DateTime startDate = filterDate!.subtract(const Duration(hours: 1));
    //   DateTime endDate =
    //       filterDate!.add(const Duration(hours: 23, minutes: 59));

    //   query = query.where('ReservDate',
    //       isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate);
    // }

    _documentsStream = query.snapshots();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _documentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Text(
              'No documents found with the specified field value.');
        }

        // Render the documents
        return Scaffold(
          appBar: AppBar(
            title: const Text("Available Matches"),
            titleTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (newValue) {
                          setState(() {
                            filterAdmin = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Admin',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];

                    // Access the document fields using document.data() map
                    final fieldValue =
                        (document.data() as Map<String, dynamic>);

                    return Card(
                      key: fieldValue[document.id],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: CircleAvatar(
                                    radius: 40.00,
                                    backgroundImage: NetworkImage(
                                        'https://images.lecho.be/view?iid=Elvis:2JO2Ny7-4zXBfiJNIvZbqQ&context=ONLINE&ratio=16/9&width=815'))),
                            Expanded(
                              flex: 2,
                              child: ListTile(
                                title: Text(
                                  fieldValue['Admin'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fieldValue['ReservDate'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          fieldValue['ReservHour'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          fieldValue['StadeName'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: fieldValue['Public']
                                                ? const Color.fromARGB(
                                                    255, 35, 177, 40)
                                                : const Color.fromARGB(
                                                    255, 181, 22, 22),
                                          ),
                                          child: Text(
                                            fieldValue['Public']
                                                ? 'Public'
                                                : 'Private',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailsScreen(
                                            parameter: fieldValue,
                                            docId: document.id)),
                                  );
                                },
                                child: const Text('Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
