import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 시간공제 사유 한 줄. 선택 입력. 완료 키·바깥 탭이면 키보드를 내린다.
class ReasonField extends StatefulWidget {
  const ReasonField({super.key, required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  static const maxLength = 20;

  @override
  State<ReasonField> createState() => _ReasonFieldState();
}

class _ReasonFieldState extends State<ReasonField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.reasonFieldRadius),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLength: ReasonField.maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      // 입력칸 아래 저장 버튼까지 키보드 위로 끌어올린다.
      scrollPadding: EdgeInsets.only(bottom: AppSizes.reasonScrollPadding),
      style: AppTextStyles.reasonInput,
      cursorColor: AppColors.brand,
      decoration: InputDecoration(
        hintText: RecordEditTexts.reasonHint,
        hintStyle: AppTextStyles.reasonHint,
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: AppColors.cardInner,
        contentPadding: AppSizes.reasonFieldPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
