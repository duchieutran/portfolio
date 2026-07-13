import 'package:flutter/material.dart';

class TabHome extends StatelessWidget {
  const TabHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // header
              Center(
                child: Text("Hieu"),
              )
              // body
            ],
          ),
        ),
      ),
    );
  }
}
