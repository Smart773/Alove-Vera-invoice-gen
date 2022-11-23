import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final IconData iconZ;
  const CustomAlert({super.key, required this.title, required this.iconZ});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        height: 400,
        width: 500,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: Icon(
                  iconZ,
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
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 200,
                          height: 50,
                          color: Colors.white,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 18)),
                          ),
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
  }
}
