import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/shared/models/asset.dart';

class AdvancedBottomSheet extends HookConsumerWidget {
  final Asset assetDetail;

  const AdvancedBottomSheet({Key? key, required this.assetDetail})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        margin: const EdgeInsets.all(0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // One column
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32.0),
                  const Align(
                    child: Text(
                      "ADVANCED INFO",
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 16.0,
                        left: 16,
                        top: 8,
                        bottom: 16,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: assetDetail.toString()),
                                ).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Copied to clipboard"),
                                    ),
                                  );
                                });
                              },
                              icon: Icon(
                                Icons.copy,
                                size: 16.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SelectableText(
                            assetDetail.toString(),
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Inconsolata",
                            ),
                            showCursor: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
