import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';
import 'package:vnote/models/onedrive_data_model.dart';

const ONEDRIVE_ALL_DATA_URL =
    "https://graph.microsoft.com/v1.0/drive/special/approot/delta?select=id,name,lastModifiedDateTime,parentReference,file,folder";

class OnedriveDataModel {
  static void getAllData(String p_token) {
    Map<String, dynamic> headers = {"Authorization": p_token};
    HttpCore.instance.get(
        ONEDRIVE_ALL_DATA_URL,
        (data) {
          print('返回的数据如下:');
          print(data);
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }
}
