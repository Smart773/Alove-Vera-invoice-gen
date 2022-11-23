import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PdfListScreen extends StatefulWidget {
  const PdfListScreen({super.key});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  final _searchController = TextEditingController();
  String searchString = "";

  @override
  initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    // 
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 75.0),
            child: Row(
              children: [
                Container(
                  width: 500,
                  height: 80,
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 60,
                  child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () {
                        setState(() {});
                      }),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 125,
                  child: OutlinedButton(
                    onPressed: () async {
                      // Navigator back to the home screen
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.home_filled),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Home')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar to search for a pdf file in the list
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchString = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          FutureBuilder(
            future: _getPdfList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.list_alt,
                        size: 150,
                      ),
                      Text('Try refeshing the list',
                          style: TextStyle(fontSize: 20)),
                      Text('OR', style: TextStyle(fontSize: 20)),
                      Text('Add a new Invoice', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _showPdfNameFromPath(snapshot.data![index])
                              .toLowerCase()
                              .contains(searchString)
                          ? Card(
                              child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: Text(
                                  _showPdfNameFromPath(snapshot.data![index])),
                              // trailing to open In folder Pdf
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () {
                                  _openPdf(snapshot.data![index]);
                                },
                              ),
                              onTap: () async {
                                // Open the PDF document in the mobile's default PDF viewer
                                await _openPdf(snapshot.data![index]);
                              },
                            ))
                          : Container();
                    },
                  ),
                );
              } else {
                return const Center(child: Text('Something went wrong'));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getPdfList() async {
    List<String> pdfList = [];
    final aloverVeraDir = await getApplicationDocumentsDirectory();
    var dir = Directory("${aloverVeraDir.path}/AloveVeraPdf");
    if (await dir.exists()) {
      dir.list().listen((file) {
        if (file.path.endsWith('.pdf')) {
          pdfList.add(file.path);
        }
      });
    }
    return pdfList;
  }

  _showPdfNameFromPath(String path) {
    String pdfName = path.split('\\').last;
    return pdfName;
  }

  _openPdf(String s) {
    // Open the PDF document in the Browers
    Process.run('cmd', ['/c', s]);
  }

  _openpdfFolder(String s) {}

  _deletePdf(String s) {
    File(s).delete();
  }
}
