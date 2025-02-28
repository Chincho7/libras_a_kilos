import 'package:flutter/cupertino.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;

  const CustomKeyboard({required this.onKeyTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemGrey6,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        shrinkWrap: true,
        children: [
          ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', '-'].map(
            (key) => CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => onKeyTap(key),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFD4CE38), // Changed from default to #d4ce38
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => onKeyTap('backspace'),
            child: const Icon(
              CupertinoIcons.delete_left,
              size: 24,
              color: Color(0xFFD4CE38), // Changed from default to #d4ce38
            ),
          ),
        ],
      ),
    );
  }
}
