import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webapp_components/action_components/button_component.dart';
import 'package:webapp_components/components/input_text_component.dart';
import 'package:webapp_components/components/select_from_list.dart';
import 'package:webapp_components/screens/screen_base.dart';
import 'package:webapp_components/validators/null_validator.dart';

import 'package:webapp_model/webapp_data_base.dart';
import 'package:webapp_template/webapp_data.dart';
import 'package:webapp_ui_commons/mixin/progress_log.dart';

class ProjectScreen extends StatefulWidget {
  final WebAppData modelLayer;
  const ProjectScreen(this.modelLayer, {super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with ScreenBase, ProgressDialog {
  @override
  String getScreenId() {
    return "ProjectScreen";
  }

  @override
  void dispose() {
    super.dispose();
    disposeScreen();
  }

  @override
  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    var projectInputComponent = InputTextComponent(
        "project", getScreenId(), "Project Name",
        saveState: false);
    projectInputComponent.setComponentValue(widget.modelLayer.app.projectName);
    projectInputComponent.onChange(refresh);
    projectInputComponent.addValidator(
        NullValidator(invalidMessage: "Project Name cannot be empty"));

    var selectTeamComponent = SelectFromListComponent(
        "team", getScreenId(), "Select Team",
        user: widget.modelLayer.app.teamname, saveState: false);
    selectTeamComponent.setComponentValue(widget.modelLayer.app.teamname);
    selectTeamComponent
        .addValidator(NullValidator(invalidMessage: "Team cannot be empty"));

    addComponent("default", projectInputComponent);
    addComponent("default", selectTeamComponent);

    var createProjectBtn = ButtonActionComponent(
        "createProject", "Open New WebApp", _openNewWebApp,
        blocking: false, parents: [projectInputComponent, selectTeamComponent]);
    addActionComponent(createProjectBtn);
    initScreen(widget.modelLayer as WebAppDataBase);
  }

  Future<void> _openNewWebApp() async {
    // http://127.0.0.1:5400/thiago.monteiro/p/a76d10aa4a4e198bfaad6c65bc4b4a23?folderId=a76d10aa4a4e198bfaad6c65bc6e0cad
    var link = Uri(
        scheme: Uri.base.scheme,
        host: '127.0.0.1',
        port: 5400,
        path:
            "${widget.modelLayer.app.teamname}/p/${widget.modelLayer.app.projectId}/channel/SOME_TEST_CHANNEL");

    launchUrl(link, webOnlyWindowName: "_self");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.modelLayer.fetchUserList(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            (getComponent("team")! as SelectFromListComponent)
                .setOptions(snapshot.data!);
            return buildComponents(context);
          } else {
            // TODO fullscreen wait widget
            (getComponent("team")! as SelectFromListComponent)
                .setOptions(["Loading user list..."]);
            return buildComponents(context);
          }
        });
  }
}
