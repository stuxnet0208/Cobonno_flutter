import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../../common/color_values.dart';
import '../../common/styles.dart';
import '../../routes/router.gr.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final List<dynamic> _itemList = [
    'assets/onboading_step1.png',
    'assets/onboading_step2.png',
    'assets/onboading_step3.png',
  ];
  List<String> _textList = ['', '', ''];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          _initTextList();
        });
      } else {
        _initTextList();
      }
    });
  }

  void _initTextList() {
    _textList = [
      AppLocalizations.of(context).onBoarding1,
      AppLocalizations.of(context).onBoarding2,
      AppLocalizations.of(context).onBoarding3,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
        ),
      ),
      body: _buildIntroductionScreen(),
    );
  }

  Widget _buildIntroductionScreen() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(flex: 6, child: Container()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            children: [Expanded(child: _buildCarousel())],
          ),
        ),
      ],
    );
  }

  Column _buildCarousel() {
    double fontSize = MediaQuery.of(context).size.width <= 600 ? 16.sp : 14.sp;
    final List<Widget> imageSliders = _itemList
        .map((item) => Column(
              children: [
                Expanded(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[Image.asset(item, width: double.infinity)],
                      )),
                ),
                SizedBox(height: 3.h),
                Expanded(
                  child: Column(
                    children: [
                      _current == 0
                          ? Flexible(
                              child: Text(AppLocalizations.of(context).titleOnBoarding1,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                                  textAlign: TextAlign.center),
                            )
                          : const SizedBox.shrink(),
                      _current == 0 ? SizedBox(height: 4.h) : const SizedBox.shrink(),
                      Flexible(
                        child: Text(_textList[_current],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                )
              ],
            ))
        .toList();

    return Column(children: [
      Expanded(child: Container()),
      MediaQuery.of(context).size.width > 600
          ? Expanded(flex: 100, child: _buildCarouselSlider(imageSliders))
          : _buildCarouselSlider(imageSliders),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _itemList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12.0,
              height: 12.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorValues.darkGrey.withOpacity(_current == entry.key ? 0.9 : 0.4)),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      Expanded(child: Container()),
      ElevatedButton(
          onPressed: () {
            if (_current != _itemList.length - 1) {
              _controller.nextPage();
            } else {
              AutoRouter.of(context).replace(const LoginRoute());
            }
          },
          child: Text(_current == _itemList.length - 1
              ? AppLocalizations.of(context).start
              : AppLocalizations.of(context).next))
    ]);
  }

  CarouselSlider _buildCarouselSlider(List<Widget> imageSliders) {
    return CarouselSlider(
      items: imageSliders,
      carouselController: _controller,
      options: CarouselOptions(
          viewportFraction: 1,
          autoPlay: false,
          aspectRatio: 0.8,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
    );
  }
}
