import 'package:alove_vera/custom_dialog/custom_dialog.dart';
import 'package:alove_vera/pdf_list_screen.dart';
import 'package:alove_vera/service_pdf.dart';
import 'package:alove_vera/random_trn_genrator/rand_trn_gen.dart';
import 'package:flutter/services.dart';
import 'package:alove_vera/model/service_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'helper_function/helper_function.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(1280, 800));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alove Vera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Making animated splash screen  using
      // https://pub.dev/packages/animated_splash_screen
      home: AnimatedSplashScreen(
        splash: const Image(
          image: AssetImage('assets/images/logo.png'),
        ),
        nextScreen: const MyHomePage(title: 'Alove Vera'),
        splashTransition: SplashTransition.fadeTransition,
        animationDuration: const Duration(seconds: 2),
        centered: true,
        backgroundColor: Colors.white,
        duration: 2000,
      ),

      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PdfInvoiceService service = PdfInvoiceService();
  final _customerNametxt = TextEditingController();
  final _customerTrntxt = TextEditingController();
  final _desctxt = TextEditingController();
  final _amounttxt = TextEditingController();
  final _qtytxt = TextEditingController();
  final _mobNotxt = TextEditingController();
  final _addresstxt = TextEditingController();
  String amountInWords = '';
  double subTotal = 0;
  double grandTotal = 0;
  int number = 0;
  ScrollController listScrollController = ScrollController();
  final List<ServiceData> _serviceData = [];
  UniqeTrnGenerator trnGenerator = UniqeTrnGenerator();
  int invoiceNumber = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    getInvocieNumber();

    super.initState();
  }

  @override
  void dispose() {
    _customerNametxt.dispose();
    _customerTrntxt.dispose();
    _desctxt.dispose();
    _amounttxt.dispose();
    _qtytxt.dispose();
    _addresstxt.dispose();
    _mobNotxt.dispose();
    listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //Header
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
                const Expanded(flex: 10, child: SizedBox()),
                SizedBox(
                  width: 125,
                  child: OutlinedButton(
                    onPressed: () async {
                      // Navegate to pdf list screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PdfListScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_forward),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Pdf List'),
                      ],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 125,
                  child: OutlinedButton(
                    onPressed: () async {
                      if (_customerNametxt.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CustomAlert(
                                title: "Customer Name is  Required",
                                iconZ: Icons.warning);
                          },
                        );
                        return;
                      }
                      if (_addresstxt.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CustomAlert(
                                title: "Customer Address is  Required",
                                iconZ: Icons.warning);
                          },
                        );
                        return;
                      }
                      if (_customerTrntxt.text.isNotEmpty &&
                          _customerTrntxt.text.length != 15) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CustomAlert(
                                title: "Invalid TRN Number",
                                iconZ: Icons.warning);
                          },
                        );
                        return;
                      }
                      if (_serviceData.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CustomAlert(
                                title: "Add Service In Invoice",
                                iconZ: Icons.warning);
                          },
                        );
                        return;
                      }

                      final data = await service.createInvoice(
                          _serviceData,
                          subTotal,
                          _customerNametxt.text.toString(),
                          _customerTrntxt.text.toString(),
                          (NumberFormat('0000').format(invoiceNumber)),
                          _addresstxt.text.toString(),
                          _mobNotxt.text.toString(),
                          selectedDate);
                      service.savePdfFile(
                          "Invoice${number}_${_customerNametxt.text.toString()}_${selectedDate.day}_${selectedDate.month}_${selectedDate.year}",
                          data);
                      number++;
                      trnGenerator.randTRNGenerator();
                      _customerNametxt.clear();
                      _customerTrntxt.clear();
                      _mobNotxt.clear();
                      _addresstxt.clear();
                      _desctxt.clear();
                      _amounttxt.clear();
                      _qtytxt.clear();
                      _serviceData.clear();
                      amountInWords = '';
                      subTotal = 0.0;
                      grandTotal = 0.0;
                      number = 0;
                      selectedDate = DateTime.now();
                      listScrollController.jumpTo(0);
                      setInvocieNumber();
                      setState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.picture_as_pdf_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Save Pdf')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Working Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0, right: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Card(
                              elevation: 5,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "TAX INVOICE",
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Expanded(child: SizedBox()),
                                        Text(
                                          'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              selectedDate =
                                                  (await showDatePicker(
                                                      context: context,
                                                      initialDate: selectedDate,
                                                      firstDate: DateTime(2000),
                                                      lastDate:
                                                          DateTime(2100)))!;
                                              setState(() {});
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.calendar_month),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text('Select Date'),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, bottom: 12.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "NO: ${NumberFormat('0000').format(invoiceNumber)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Expanded(child: SizedBox()),
                                        const Text(
                                          'TRN # 100033495100003',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 250.0, bottom: 12.0),
                                    child: TextField(
                                      controller: _customerNametxt,
                                      keyboardType: TextInputType.name,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[A-Za-z ]')),
                                      ],
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        labelText: 'Customer Name',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 250.0, bottom: 12.0),
                                    child: TextField(
                                      controller: _customerTrntxt,
                                      maxLength: 15,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        labelText: 'Customer TRN NO #',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 250.0, bottom: 12.0),
                                    child: TextField(
                                      controller: _addresstxt,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        labelText: 'Customer Address',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 250.0, bottom: 12.0),
                                    child: TextField(
                                      //only get phone numbers with spaces and dashes and only one +
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9-+ ]')),
                                      ],
                                      controller: _mobNotxt,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        labelText: 'Mobile No',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            flex: 2,
                            child: Card(
                              elevation: 5,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: TextField(
                                      maxLength: 70,
                                      controller: _desctxt,
                                      maxLines: 5,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                        ),
                                        labelText: 'Description',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, bottom: 12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextField(
                                            maxLength: 10,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]')),
                                            ],
                                            controller: _amounttxt,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              labelText: 'Amount',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            maxLength: 2,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            controller: _qtytxt,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              labelText: 'Qty.',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                            height: 50,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                              ),
                                              onPressed: () {
                                                ////////
                                                if (_desctxt.text.isEmpty ||
                                                    _qtytxt.text.isEmpty ||
                                                    _amounttxt.text.isEmpty) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const CustomAlert(
                                                          title:
                                                              "Some Fileds are Empty",
                                                          iconZ: Icons.error);
                                                    },
                                                  );
                                                  return;
                                                }
                                                if (_serviceData.length == 8) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const CustomAlert(
                                                          title:
                                                              "You can't add more than 8 services",
                                                          iconZ: Icons.warning);
                                                    },
                                                  );
                                                  return;
                                                }
                                                if (_amounttxt.text
                                                            .toString() ==
                                                        '0' ||
                                                    _qtytxt.text.toString() ==
                                                        '0') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const CustomAlert(
                                                          title:
                                                              "Amount and Qty. can't be 0",
                                                          iconZ: Icons.warning);
                                                    },
                                                  );
                                                  return;
                                                }
                                                if (_amounttxt.text
                                                        .toString()
                                                        .contains('.') &&
                                                    (_amounttxt.text
                                                                .toString()
                                                                .split('.'))
                                                            .length >
                                                        2) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const CustomAlert(
                                                          title:
                                                              "Amount can't have more than 1 decimal places",
                                                          iconZ: Icons.warning);
                                                    },
                                                  );
                                                  return;
                                                }
                                                subTotal = 0;
                                                grandTotal = 0;
                                                String des =
                                                    _desctxt.text.toString();
                                                double amount = double.parse(
                                                    _amounttxt.text.toString());
                                                int qty = int.parse(
                                                    _qtytxt.text.toString());
                                                _serviceData.add(ServiceData(
                                                    description: des,
                                                    amount: amount,
                                                    qty: qty));
                                                _desctxt.clear();
                                                _amounttxt.clear();
                                                _qtytxt.clear();

                                                if (listScrollController
                                                    .hasClients) {
                                                  listScrollController.jumpTo(
                                                      listScrollController
                                                              .position
                                                              .maxScrollExtent +
                                                          250);
                                                }
                                                for (var i = 0;
                                                    i < _serviceData.length;
                                                    i++) {
                                                  subTotal = subTotal +
                                                      _serviceData[i].total;
                                                }
                                                grandTotal = subTotal +
                                                    (subTotal * 0.05);
                                                amountInWords =
                                                    decimalToWord(grandTotal);

                                                setState(() {});
                                              },
                                              child: const Text('Add'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 5,
                      child: Column(children: [
                        SizedBox(
                          height: 500,
                          child: _serviceData.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.add_shopping_cart_sharp,
                                    size: 150,
                                    color: Colors.grey,
                                  ),
                                )
                              : ListView.separated(
                                  controller: listScrollController,
                                  shrinkWrap: true,
                                  itemCount: _serviceData.length,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      hoverColor: Colors.grey.shade100,
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: SizedBox(
                                                height: 400,
                                                width: 500,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                        child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 100,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.red,
                                                        child: SizedBox.expand(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(22.0),
                                                            child: Column(
                                                              children: [
                                                                const Text(
                                                                  'Are You Sure ?\nDo you want to delete this item',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          50,
                                                                      color: Colors
                                                                          .white,
                                                                      child:
                                                                          OutlinedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            "cancel",
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 18)),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 20,
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          50,
                                                                      color: Colors
                                                                          .white,
                                                                      child:
                                                                          OutlinedButton(
                                                                        onPressed:
                                                                            () {
                                                                          subTotal =
                                                                              0;
                                                                          grandTotal =
                                                                              0;

                                                                          _serviceData
                                                                              .removeAt(index);
                                                                          if (listScrollController
                                                                              .hasClients) {
                                                                            listScrollController.jumpTo(listScrollController.position.maxScrollExtent +
                                                                                250);
                                                                          }
                                                                          for (var i = 0;
                                                                              i < _serviceData.length;
                                                                              i++) {
                                                                            subTotal =
                                                                                subTotal + _serviceData[i].total;
                                                                          }
                                                                          grandTotal =
                                                                              subTotal + (subTotal * 0.05);
                                                                          amountInWords =
                                                                              decimalToWord(grandTotal);
                                                                          Navigator.pop(
                                                                              context);
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child: const Text(
                                                                            "Delete",
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 18)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      leading: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      title: Text(
                                        _serviceData[index].description,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'per unit: ${formatNumber(_serviceData[index].amount)}\nQty: ${_serviceData[index].qty}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                      isThreeLine: true,
                                      trailing: Text(
                                        'Total: ${formatNumber(_serviceData[index].amount * _serviceData[index].qty)}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(
                                      color: Colors.black,
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Total:\n$amountInWords',
                                        style: TextStyle(
                                            fontSize:
                                                (subTotal.toString()).length < 7
                                                    ? 18
                                                    : 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'SubTotal: ${formatNumber(subTotal)}',
                                            style: TextStyle(
                                                fontSize: (subTotal.toString())
                                                            .length <
                                                        7
                                                    ? 16
                                                    : 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'VAT 5%: ${formatNumber(subTotal * 0.05)}',
                                            style: TextStyle(
                                                fontSize: (subTotal.toString())
                                                            .length <
                                                        7
                                                    ? 16
                                                    : 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Grand Total: ${formatNumber(grandTotal)}',
                                            style: TextStyle(
                                                fontSize: (subTotal.toString())
                                                            .length <
                                                        7
                                                    ? 16
                                                    : 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> setInvocieNumber() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'invoice_number';
    invoiceNumber = prefs.getInt(key) ?? 1;
    invoiceNumber++;
    prefs.setInt(key, invoiceNumber);
  }

  getInvocieNumber() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'invoice_number';
    invoiceNumber = prefs.getInt(key) ?? 1;
    setState(() {});
  }
}
