import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:number_to_words/number_to_words.dart';
import 'package:alove_vera/model/service_data.dart';
import 'package:flutter/services.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:string_extensions/string_extensions.dart';
import 'helper_function/helper_function.dart';

class CustomRow {
  final String description;
  final String amount;
  final String qty;
  final String total;
  CustomRow(this.description, this.amount, this.qty, this.total);
}

class PdfInvoiceService {
  // createInvoice();
  Future<Uint8List> createInvoice(
    List<ServiceData> soldProducts,
    double subTotle,
    String customerName,
    String customerTrn,
    String invoiceNo,
    String address,
    String mobile,
    DateTime selectedDate,
  ) async {
    final pdf = pw.Document();
    final List<CustomRow> elements = [
      for (var i = 0; i < soldProducts.length; i++)
        CustomRow(
            soldProducts[i].description,
            soldProducts[i].amount.toString(),
            soldProducts[i].qty.toString(),
            soldProducts[i].getTotal.toString()),
    ];
    final image =
        (await rootBundle.load("assets/images/logo.png")).buffer.asUint8List();
    final arabicTax =
        (await rootBundle.load("assets/images/tax.png")).buffer.asUint8List();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.only(
          left: 20.0, right: 20.0, top: 0, bottom: 26.0),
      build: (pw.Context context) {
        return pw.Column(children: [
          pw.Container(
              width: 420,
              height: 71,
              child: pw.Stack(children: [
                pw.Container(
                  width: 420,
                  height: 80,
                  child: pw.Image(pw.MemoryImage(image)),
                ),
                pw.Positioned(
                    top: 58,
                    right: 0,
                    child: pw.Container(
                        width: 420,
                        child: pw.Divider(
                          color: PdfColors.green,
                          thickness: 1,
                        ))),
                pw.Positioned(
                    top: 60,
                    right: 0,
                    child: pw.Container(
                        width: 420,
                        child: pw.Divider(
                          color: PdfColors.black.shade(300),
                          thickness: 1,
                        ))),
                headerElements("Mob: +971 55 906 6980 ", 10),
                headerElements("Tel: 971 4 252 9414 ", 85),
                headerElements("P.O.Box 237725. Dubai - U.A.E", 211),
                headerElements("Email: s_meo2010@yahoo.com", 293),
              ])),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                  height: 40,
                  alignment: pw.Alignment.bottomLeft,
                  child: pw.Text("Customer details:",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ))),
              pw.Column(
                children: [
                  pw.Image(pw.MemoryImage(arabicTax), width: 100, height: 100),
                  pw.Text("Tax Invoice",
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("TRN # 100033495100003",
                      style: const pw.TextStyle(
                        fontSize: 10,
                      )),
                ],
              ),
              pw.RichText(
                  text: pw.TextSpan(
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                      children: [
                    const pw.TextSpan(text: "Invoice No: "),
                    pw.TextSpan(
                        text: invoiceNo,
                        style: const pw.TextStyle(
                            color: PdfColors.red, fontSize: 10)),
                  ])),
            ],
          ),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    alignText("Mr./M/s: $customerName", pw.TextAlign.left,
                        pw.FontWeight.bold),
                    alignText("Mob: ${(mobile == '' ? '__________' : mobile)}",
                        pw.TextAlign.left, pw.FontWeight.normal),
                    alignText("Address: $address ", pw.TextAlign.left,
                        pw.FontWeight.normal),
                    alignText(
                        "Customer TRN: ${(customerTrn == '' ? '__________' : customerTrn)}",
                        pw.TextAlign.left,
                        pw.FontWeight.normal),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                        height: 60,
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(
                            "Date: ${DateFormat.yMd().format(selectedDate)}",
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ))),
                  ],
                ),
              ]),
          pw.SizedBox(height: 4),
          itemColumn(elements, subTotle),
          pw.SizedBox(height: 7),
          pw.Text(
            "This is Computer Generated Invoice,does not require signature",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
        ]);
      },
    ));

    return pdf.save();
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getApplicationDocumentsDirectory();
    var dir = Directory("${output.path}/AloveVeraPdf");
    if (!dir.existsSync()) {
      dir.createSync();
    }
    var filePath = "${dir.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    await OpenDocument.openDocument(filePath: filePath);
  }

  pw.Container alignText(
      String text, pw.TextAlign align, pw.FontWeight weight) {
    return pw.Container(
      width: 220,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: weight,
        ),
      ),
    );
  }

  pw.Positioned headerElements(String text, double left) {
    return pw.Positioned(
        top: 54,
        left: left,
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 5.5)));
  }

  pw.Expanded itemColumn(List<CustomRow> elements, double subTotle) {
    int temp = 0;
    String? wordTotal =
        decimalToWord(subTotle == 0 ? 0 : subTotle + (subTotle * 0.05));
    // wordTotal = wordTotal.toTitleCase;
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                  flex: 1,
                  child: pw.Text("S.N.",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
              pw.Expanded(
                  flex: 6,
                  child: pw.Text("Description",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text("Qty.",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text("Price",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text("Amount",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
            ],
          ),
          pw.Divider(
            color: PdfColors.grey700,
            thickness: 1,
          ),
          for (; temp < 8; temp++)
            pw.Container(
              height: 26,
              color: (temp >= elements.length)
                  ? PdfColors.white
                  : temp % 2 == 0
                      ? PdfColors.white
                      : PdfColors.grey200,
              child: (temp >= elements.length)
                  ? pw.Row(children: [
                      pw.Expanded(child: pw.Text("")),
                      pw.Expanded(child: pw.Text("")),
                      pw.Expanded(child: pw.Text("")),
                      pw.Expanded(child: pw.Text("")),
                    ])
                  : pw.Row(
                      children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              "${temp + 1}",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontSize: 12, fontWeight: pw.FontWeight.bold),
                            )),
                        pw.Expanded(
                            flex: 6,
                            child: pw.Text(
                              elements[temp].description,
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(fontSize: 10),
                            )),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              elements[temp].qty,
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              formatNumber(double.parse(elements[temp].amount)),
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              formatNumber(double.parse(elements[temp].total)),
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            )),
                      ],
                    ),
            ),
          pw.Divider(
            color: PdfColors.grey700,
            thickness: 1,
          ),
          pw.Row(
            children: [
              pw.Expanded(
                  flex: 4,
                  child: pw.Text("",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
              pw.Expanded(
                  flex: 1,
                  child: pw.Text("",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text("Sub Total",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text(formatNumber(subTotle),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                  flex: 4,
                  child: pw.Text("",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 1,
                  child: pw.Text("",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text("VAT 5%",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text(formatNumber((subTotle * 0.05)),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
            ],
          ),
          pw.Divider(
            color: PdfColors.grey700,
            thickness: 1,
          ),
          pw.Row(
            children: [
              pw.Expanded(
                  flex: 4,
                  child: pw.Text("Total In Words:   \n${(wordTotal)}",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(
                  flex: 1,
                  child: pw.Text("",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      height: 30,
                      child: pw.Text("Grand Total",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      height: 30,
                      child: pw.Text(formatNumber(subTotle + (subTotle * 0.05)),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)))),
            ],
          ),
          pw.Divider(
            color: PdfColors.grey700,
            thickness: 1,
          ),
        ],
      ),
    );
  }
}
