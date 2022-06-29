import 'package:flutter/material.dart';
import 'package:tigua_birthday/views/components/user_card.dart';

/// A custom table to handle charge searches
class DynamicTable extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> pastoresNames;

  const DynamicTable(
      {Key? key, required this.data, required this.pastoresNames})
      : super(key: key);

  @override
  State<DynamicTable> createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  late final List<Map<String, dynamic>> pastoresNames;
  late final Map<String, dynamic> processedData;

  @override
  void initState() {
    // backend response does not caintain pastores names, so we need to inject
    // them manually
    processedData = widget.data;
    pastoresNames = widget.pastoresNames;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keys = processedData.keys.toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(keys[index]),
            children: [
              if (processedData[keys[index]] is List)
                ...List<Widget>.from(processedData[keys[index]]
                    .map((item) => _getPastorCard(item.toString()))),
              if (processedData[keys[index]] is Map)
                DynamicTable(
                    data: processedData[keys[index]],
                    pastoresNames: pastoresNames),
            ],
          );
        },
      ),
    );
  }

  Widget _getPastorCard(String id) {
    final _pastorName = pastoresNames.firstWhere((item) {
      return item['id']?.toString() == id;
    }, orElse: () => <String, dynamic>{});

    return UserCardComponent(
        userData: _pastorName, showIglesia: false, showOrdenacion: false);
  }
}
