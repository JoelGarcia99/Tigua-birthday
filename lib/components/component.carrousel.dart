import 'package:flutter/material.dart';

/// @author: Joel Garcia
/// @version: 1.0
///
/// A carrousel component
class CarrouselComponent extends StatelessWidget {
  static const titleFontSize = 20.0;
  static const initialPage = 0;
  static const keepPage = true;
  static const viewportFraction = 0.5;

  final String title;
  final String emptyTag;
  final IconData? prefixIcon;
  final List<Widget> data;
  final Size size;
  final Future<void> Function()? onRefresh;

  /// @param {String} title - The title of the carrousel
  /// @param {String} emptyTag - The tag to show when the carrousel is empty
  /// @param {IconData} prefixIcon - The icon to show before the title
  /// @param {List<Widget>} data - The data to show in the carrousel
  /// @param {Size} size - The size of the carrousel
  /// @param {Future<void> Function()} onRefresh - The function to call when the carrousel is refreshed
  const CarrouselComponent({
    Key? key,
    required this.title,
    required this.emptyTag,
    required this.data,
    required this.size,
    this.prefixIcon,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: Column(
          children: [
			  const Divider(),
            ListTile(
              // prefix icon & title
              leading: Icon(prefixIcon),
              title: Text(title,
                  style: const TextStyle(fontSize: titleFontSize)),
            ),
            const Divider(),
            SizedBox(
				width: size.width,
				height: size.height,
              child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: PageController(
                      initialPage: initialPage,
                      keepPage: keepPage,
                      viewportFraction: viewportFraction),
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  children: data.isNotEmpty ? data : [Text(emptyTag)]),
            ),
          ],
        ));
  }
}
