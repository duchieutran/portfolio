import 'package:flutter/material.dart';
import 'package:portfolio/core/theme/context_extension.dart';
import 'package:portfolio/core/theme/tokens/colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // header
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                padding: EdgeInsets.all(context.spacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error,
                ),
                child: Row(
                  children: [
                    // Avatar
                    // menu
                  ],
                ),
              )
              // body
            ],
          ),
        ),
      ),
    );
  }
}
