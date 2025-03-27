import 'package:webapp_model/webapp_data_base.dart';

import 'package:webapp_template/webapp.dart';
import 'package:webapp_ui_commons/webapp_base.dart';


class WebAppData extends WebAppDataBase {
  WebApp webapp;
  WebAppData(this.webapp) : super(webapp as WebAppBase);



}
