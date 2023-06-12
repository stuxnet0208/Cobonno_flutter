import 'package:flutter/material.dart';

import '../../widgets/web_view.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WebViewWidget(url: 'https://whatis.cobonno.com/feedback.html');
  }
}
