import 'package:flutter/material.dart';
import 'package:meditro/Controllers/onboarding_controller.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final OnboardingController controller = OnboardingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/img/imgBg/Backgroundelapps.jpg',
                fit: BoxFit.cover,
              ),
            ),
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: (index) {
                setState(() {
                  controller.onPageChanged(index);
                });
              },
              itemCount: controller.screens.length,
              itemBuilder: (context, index) {
                final screen = controller.screens[index];
                final double width = screen['width'] as double;
                final double height = screen['height'] as double;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width,
                      height: height,
                      child: Image.asset(screen['image']!, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 175,
                      height: 43,
                      child: Image.asset(screen['logo']!, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      screen['title']!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF565ACF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      screen['subtitle']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (index == controller.screens.length - 1)
                      SizedBox(
                        width: 270,
                        height: 51,
                        child: ElevatedButton(
                          onPressed: () => controller.finishOnboarding(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF17732),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Commecer",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Dots positionnés plus haut
            Positioned(
              bottom: 50, // ajuste cette valeur selon ta préférence
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.screens.length,
                  (index) => controller.buildDot(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
