import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart' as pd;
import 'package:webapp_components/components/image_list_component.dart';
import 'package:webapp_model/id_element_table.dart';

class KumoImageListComponent extends ImageListComponent {
  KumoImageListComponent(
      super.id, super.groupId, super.componentLabel, super.dataFetchFunc,
      {super.sortByLabel, super.collapsible});

  pd.PdfDocument _addImageEntry(
      pd.PdfDocument pdfDoc, ExportPageContent content) {
    var font = pd.PdfStandardFont(pd.PdfFontFamily.helvetica, 40);
    var titleSz = font.measureString(content.title);

    var bmp = pd.PdfBitmap(content.content);
    pdfDoc.pageSettings.size =
        Size((bmp.height as double) + 15 + titleSz.height, bmp.width as double);
    if (bmp.height > bmp.width) {
      pdfDoc.pageSettings.orientation = pd.PdfPageOrientation.portrait;
    } else {
      pdfDoc.pageSettings.orientation = pd.PdfPageOrientation.landscape;
    }

    var page = pdfDoc.pages.add();

    page.graphics.drawString(content.title, font,
        bounds: Rect.fromLTWH(0, 0, titleSz.width, titleSz.height));
    page.graphics.drawImage(
        bmp,
        Rect.fromLTWH(
            0, titleSz.height + 15, bmp.width as double, bmp.height as double));
    return pdfDoc;
  }

  pd.PdfDocument _addTextEntry(
      pd.PdfDocument pdfDoc, ExportPageContent content) {
    var titleFont = pd.PdfStandardFont(pd.PdfFontFamily.helvetica, 40);
    var font = pd.PdfStandardFont(pd.PdfFontFamily.helvetica, 12);

    var text = utf8.decode(content.content);

    var titleSz = titleFont.measureString(content.title);
    var contentSz = font.measureString(text);

    pdfDoc.pageSettings.size = Size(
        pdfDoc.pageSettings.size.width, titleSz.height + 20 + contentSz.height);
    pdfDoc.pageSettings.orientation = pd.PdfPageOrientation.portrait;

    var page = pdfDoc.pages.add();

    page.graphics.drawString(content.title, titleFont,
        bounds: Rect.fromLTWH(0, 0, titleSz.width, titleSz.height));

    page.graphics.drawString(text, font,
        bounds: Rect.fromLTWH(
            0, titleSz.height + 20, contentSz.width, contentSz.height));
    return pdfDoc;
  }

  @override
  pd.PdfDocument addEntryPage(pd.PdfDocument pdfDoc, dynamic content) {
    if (content is ExportPageContent) {
      if (content.contentType.contains("image")) {
        pdfDoc = _addImageEntry(pdfDoc, content);
      }

      if (content.contentType.contains("text")) {
        pdfDoc = _addTextEntry(pdfDoc, content);
      }
    }

    return pdfDoc;
  }

  @override
  Widget createWidget(BuildContext context, IdElementTable table) {
    widgetExportContent.clear();
    expansionControllers.clear();

    String titleColName = table.colNames
        .firstWhere((e) => e.contains("filename"), orElse: () => "");
    String dataColName =
        table.colNames.firstWhere((e) => e.contains("data"), orElse: () => "");

    String typeColName = table.colNames
        .firstWhere((e) => e.contains("contentType"), orElse: () => "");

    List<Widget> wdgList = [];

    for (var ri = 0; ri < table.nRows(); ri++) {
      var title = table.columns[titleColName]![ri].label;
      //Always include summary in report
      if (shouldIncludeEntry(title) ||
          table[typeColName][ri].label.contains("text")) {
        var imgData =
            Uint8List.fromList(table[dataColName][ri].label.codeUnits);
        Widget wdg = createImageListEntry(title, imgData);

        if (table[typeColName][ri].label.contains("text")) {
          widgetExportContent.insert(
              0,
              ExportPageContent(title, imgData,
                  contentType: table[typeColName][ri].label));
        } else {
          widgetExportContent.add(ExportPageContent(title, imgData,
              contentType: table[typeColName][ri].label));
        }

        if (!table[typeColName][ri].label.contains("text")) {
          if (collapsible == true) {
            wdg = collapsibleWrap(title, wdg);
          }
          wdgList.add(wdg);
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [createToolbar(), ...wdgList],
    );
  }
}
