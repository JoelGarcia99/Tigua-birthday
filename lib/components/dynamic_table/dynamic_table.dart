import 'package:flutter/material.dart';
import 'package:tigua_birthday/views/components/user_card.dart';

/// A custom table to handle charge searches
class DynamicTable extends StatefulWidget {
  final Map<String, dynamic> data;
  const DynamicTable({Key? key, required this.data}) : super(key: key);

  @override
  State<DynamicTable> createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  late final List<Map<String, dynamic>> pastoresNames;
  late final Map<String, dynamic> processedData;

  @override
  void initState() {
    // backend response does not caintains pastores names, so we need to inject
    // them manually
    pastoresNames = widget.data['pastores_names'];
    processedData = widget.data;

    processedData.remove('pastores_names');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keys = widget.data.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text(keys[index]),
          children: [
            if (widget.data[keys[index]] is List)
              ...List<Widget>.from(widget.data[keys[index]].map((item) => _getPastorCard(item.toString()))),
            if (widget.data[keys[index]] is Map)
              DynamicTable(data: widget.data[keys[index]]),
          ],
        );
      },
    );
  }

  Widget _getPastorCard(String id) {
    final _pastorName = pastoresNames.firstWhere((item) {
      return item['id']?.toString() == id;
    }, orElse: () => <String, dynamic>{});

	return UserCardComponent(
		userData: _pastorName,
		showIglesia: false,
		showOrdenacion: false
	);
  }
}
