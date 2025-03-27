import 'dart:async';

import 'package:flutter/material.dart';


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
        "createProject", "Run Analysis", _doCreateProject,
        blocking: false, parents: [projectInputComponent, selectTeamComponent]);
    addActionComponent(createProjectBtn);
    initScreen(widget.modelLayer as WebAppDataBase);
  }

  Future<void> _doCreateProject() async {
    openDialog(context);
    log("Creating/Loading Project", dialogTitle: "Create Project");

    var teamComponent = getComponent("team") as SelectFromListComponent;
    var selectedTeam = teamComponent.getComponentValue();

    var projectComponent = getComponent("project") as InputTextComponent;
    var projectName = projectComponent.getComponentValue();

    if (projectName != widget.modelLayer.app.projectName) {
      await widget.modelLayer
          .createOrLoadProject("", projectName, selectedTeam);
      await modelLayer.reloadProjectFiles();
    }
    closeLog();
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
