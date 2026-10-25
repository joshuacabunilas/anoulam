import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/widgets/loading_widget.dart';

/// Loading state for a recipe search. If the wait runs long (a sleeping
/// free-tier server can take about a minute to wake up), it says so honestly
/// and offers a way out instead of an unexplained spinner.
class FindingRecipesWidget extends StatefulWidget {
  const FindingRecipesWidget({
    super.key,
    required this.onCancel,
    this.slowAfter = const Duration(seconds: 5),
  });

  final VoidCallback onCancel;

  /// How long before the wait counts as slow.
  final Duration slowAfter;

  @override
  State<FindingRecipesWidget> createState() => _FindingRecipesWidgetState();
}

class _FindingRecipesWidgetState extends State<FindingRecipesWidget> {
  Timer? _timer;
  var _slow = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.slowAfter, () => setState(() => _slow = true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      message: _slow
          ? StringHelper.wakingUpServer
          : StringHelper.findingRecipes,
      action: _slow
          ? TextButton(
              onPressed: widget.onCancel,
              child: const Text(StringHelper.cancel),
            )
          : null,
    );
  }
}
