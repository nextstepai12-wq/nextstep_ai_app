import 'package:flutter/material.dart';

import '../theming/app_theme.dart';


class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'ابحث...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.semanticLabel = 'بحث',
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final TextInputAction textInputAction;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final TextEditingController? effectiveController = controller;

    return Semantics(
      label: semanticLabel,
      textField: true,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: effectiveController ?? _EmptyController.instance,
        builder: (context, value, child) {
          final bool hasText = value.text.isNotEmpty;
          return TextField(
            controller: effectiveController,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            autofocus: autofocus,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
              suffixIcon: hasText
                  ? IconButton(
                      tooltip: 'مسح البحث',
                      onPressed: () {
                        effectiveController?.clear();
                        onChanged?.call('');
                        onClear?.call();
                      },
                      icon: const Icon(Icons.close_rounded, size: 19),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyController extends TextEditingController {
  _EmptyController._();
  static final _EmptyController instance = _EmptyController._();
}
