import 'dart:async';
import 'dart:typed_data';


import 'package:sci_tercen_client/sci_client_service_factory.dart' as tercen;
import 'package:sci_tercen_client/sci_client.dart' as sci;
import 'package:sci_base/value.dart';
import 'package:webapp_utils/functions/project_utils.dart';
import 'package:webapp_utils/functions/workflow_utils.dart';




class DataPrepInfo {
  late final List<Uint8List> gateOverview;
  late final sci.Table summaryInfo;
  late final String folderId;
  bool loaded = false;

  DataPrepInfo();

  bool isNotEmpty() {
    return !(gateOverview.isEmpty || summaryInfo.nRows <= 0);
  }


Future<void> load( String prepFolderId,
    {Value? options}) async {
  var factory = tercen.ServiceFactory();
  folderId = prepFolderId;
  var node = ProjectUtils().folderTreeRoot.getNodeInDescendants(prepFolderId);
  var parentNode = node!.parent;

  var wkf = sci.Workflow();
  for( var node in parentNode!.children ){
    if( node.document.name.toLowerCase().contains("data prepare")){
      wkf = await factory.workflowService.get(node.document.id);
    }
  }

  if( wkf.id == ""){
    throw Exception("Data prep workflow not found");
  }

  
  

  for (var stp in wkf.steps) {
    if (stp.id == "db85654a-461b-4548-b094-5f3adbcd919f") {
      sci.DataStep dataPrepStep = stp as sci.DataStep;

      List<sci.SimpleRelation> relations =
          WorkflowUtils.getSimpleRelations(dataPrepStep.computedRelation);

      List<sci.Schema> schList = await factory.tableSchemaService
          .list(relations.map((e) => e.id).toList());
      sci.Schema plotSch = sci.Schema();
      for (var i = 0; i < relations.length; i++) {
        sci.Schema sch = schList[i];

        if (sch.name == "Summary") {
          List<String> colNames = [];
          for (var col in sch.columns) {
            if (!col.name.startsWith(".")) {
              colNames.add(col.name);
            }
          }

          summaryInfo = await factory.tableSchemaService
              .select(sch.id, colNames, 0, sch.nRows);

          for (var col in summaryInfo.columns) {
            var nameParts = col.name.split(".");
            if (nameParts[0] != ".") {
              nameParts.removeAt(0);
            }
            col.name = nameParts.join(".");

            if (col.name == "Gate Name") {
              col.name = "GateName";
            }

            if (col.name == "#Total Events") {
              col.name = "#TotalEvents";
            }
          }
        }
        if (sch.name == "Plots") {
          plotSch = sch;
        }
      }

      gateOverview = await _getImageBytes(plotSch);
    }
  }
  loaded = true;
  // return DataPrepInfo(imageBytes, summaryTable, prepFolderDoc.id);
}

  Future<List<Uint8List>> _getImageBytes(sci.Schema plotSch,
      {String mimepart = "image", List<String>? includeNameParts}) async {
    var factory = tercen.ServiceFactory();
    List<Uint8List> bytes = [];
    //Read content
    List<String> colNames = [];
    for (var col in plotSch.columns) {
      if (col.name.contains("mimetype") || col.name.contains("filename")) {
        colNames.add(col.name);
      }
    }

    colNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    sci.Table plotTbl = await factory.tableSchemaService
        .select(plotSch.id, colNames, 0, plotSch.nRows);

    for (var i = 0; i < plotSch.nRows; i++) {
      if (plotTbl.columns[1].values[i].contains(mimepart)) {
        if (includeNameParts != null) {
          var hasPart = false;
          for (var namePart in includeNameParts) {
            hasPart = hasPart ||
                (plotTbl.columns[0].values[i].contains(namePart + "_"));
          }

          if (!hasPart) {
            continue;
          }
        }

        var bytesStream = factory.tableSchemaService
            .getFileMimetypeStream(plotSch.id, plotTbl.columns[0].values[i]);
        var imgBytes = await bytesStream.toList();
        bytes.add(Uint8List.fromList(imgBytes[0]));
      }
    }

    return bytes;
  }

  // Future<sci.Workflow> _fetchPrepWorkflow( sci.FolderDocument prepFolderDoc) async {
  //   var factory = tercen.ServiceFactory();

  //   var prepFolderObjects = ProjectUtils().getFolderDocuments(prepFolderDoc.folderId, prepFolderDoc.projectId);

  //   for (var obj in prepFolderObjects) {
  //     if (obj.id == "e4cb261d072e68f714e0ff3cdb06b336") {
  //       return await factory.workflowService.get(obj.id);
  //     }
  //   }

  //   return sci.Workflow();
  // }
}
