import 'package:flutter/services.dart';
import 'package:json_string/json_string.dart';



class WorkflowInfo {
  final String iid;
  final String name;
  final String url;
  final String version;
  bool installed = false;

  WorkflowInfo(this.iid, this.name, this.url, this.version);
}

class RepositoryConfig {

  static RepositoryConfig from(RepositoryConfig config){
    RepositoryConfig newConfig = RepositoryConfig();
    newConfig.info.addAll(config.info);
    return newConfig;
  }

  final Map<String, WorkflowInfo> info = {};
  bool loaded = false;
  
  Future<void> loadInfo() async {
    String settingsStr = await rootBundle.loadString("assets/repos.json");
    try {
      final jsonString = JsonString(settingsStr);
      final repoInfoMap = jsonString.decodedValueAsMap;

      
      for(int i = 0; i < repoInfoMap["repos"].length; i++){
        
        Map<String, dynamic> jsonEntry = repoInfoMap["repos"][i];  

        WorkflowInfo workflow = WorkflowInfo(
          jsonEntry["iid"],
          jsonEntry["name"],
          jsonEntry["url"],
          jsonEntry["version"]);

          info[ jsonEntry["iid"]] = workflow;


      }
    } on Exception catch (e) {
        print('Invalid JSON: $e');
    }
  }

  

  WorkflowInfo? markInstalled(String workflowName){
    for( var wkfInfo in info.values ){
      if( wkfInfo.name == workflowName){

        wkfInfo.installed = true;
        info[wkfInfo.iid] = wkfInfo;
        return wkfInfo;
      }
    }

    return null;
  }

  List<WorkflowInfo> getWorkflowsToInstall(){
    List<WorkflowInfo> toInstall = [];

    for( var wkfInfo in info.values ){
      if( wkfInfo.installed == false){
        toInstall.add(wkfInfo);
      }
    }

    return toInstall;

  }
}


