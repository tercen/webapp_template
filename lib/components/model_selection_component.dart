import 'package:flutter/material.dart';
import 'package:webapp_components/abstract/single_value_component.dart';
import 'package:webapp_components/components/selectable_list.dart';
import 'package:webapp_model/id_element.dart';
import 'package:webapp_model/id_element_table.dart';
import 'package:webapp_ui_commons/styles/styles.dart';
import 'package:webapp_utils/functions/list_utils.dart';

class ModelSelectionComponent extends SelectableListComponent {
  ModelSelectionComponent(super.id, super.groupId, super.componentLabel, super.dataFetchFunc, {super.pathTransformCallback});


  @override
  Widget createTable(BuildContext context, IdElementTable dataTable) {

    List<Widget> tableRows = [];
    var dataList = dataTable.getValuesByIndex(0) ?? [];

   

    var indices = List<int>.generate(dataList.length, (i) => i);
    if (sortByLabel) {
      indices =
          ListUtils.getSortedIndices(dataList.map((e) => e.label).toList());
    }

    var selectedDataPrepLabel = "";
    if( ancestors.isNotEmpty ){
      var parentComponent = ancestors.first;
      if( parentComponent is SingleValueComponent ){
        selectedDataPrepLabel = parentComponent.getValue().label.split("/").first;
      }
    }

    for (var i in indices) {
      String lbl = dataList[i].label;

      var highlight = lbl.contains(selectedDataPrepLabel);
      lbl =
          labelTransformCallback(IdElement(dataList[i].id, dataList[i].label));

      tableRows.add(createRowWithHighlight(dataList[i].id, lbl, i % 2 == 0, highlight, context));
    }

    return Column(children: tableRows);
  }

  Widget createRowWithHighlight(String id, String name, bool isEven, bool highlight, BuildContext context) {
    var isSelected =
        [selected.id, selected.label].join("_") == [id, name].join("_");

    var checkboxWidget = checkBox(id, name, isSelected);

    var rowWdg = Row(
      children: [
        const SizedBox(
          width: 15,
        ),
        SizedBox(
          width: 50,
          child: checkboxWidget,
        ),
        buildInfoBoxIcon(id, name, context),
        //Flexible allows text wrapping in the row
        Flexible(
            child: Text(
          name,
          style: highlight ? Styles.textBold : Styles.text,
        )),
      ],
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      color: isEven ? Styles.evenRow : Styles.oddRow,
      child: rowWdg,
    );
  }

}