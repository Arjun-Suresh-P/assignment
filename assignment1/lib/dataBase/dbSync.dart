
import 'package:assignment1/dataBase/dbFile.dart';
import 'package:sqflite/sqflite.dart';
class DbSync{
  List<dynamic> mobileData = [];
  verifyAndUpdateLocalDb(dynamic responseData) {
    InitDataBase.inst.initDatabase().then((dbInstance) async {
      InitDataBase.inst.queryAllData(InitDataBase.productDataTable).then((
          value) {
        mobileData = value;

        if ((mobileData == []) || (mobileData.isEmpty)) {
          for (int i = 0; i < responseData.length; i++) {
            InitDataBase.inst.insertData(InitDataBase.productDataTable, {
              InitDataBase.id: responseData[i]['id'].toString(),
              InitDataBase.title: responseData[i]['title'].toString(),
              InitDataBase.image: responseData[i]['image'].toString(),
              InitDataBase.rate: responseData[i]['rating']['rate'].toString(),
              InitDataBase.amount : responseData[i]['price'].toString()
            });
          }
        }
        else if ((mobileData != []) || (mobileData.isNotEmpty)) {
          compareData(responseData,dbInstance);
        }
      });
    });
  }
  compareData(dynamic serverDbVersion,Database dbInstance) {
    for (int i = 0; i < serverDbVersion.length; i++) {
      String configTableName = (serverDbVersion[i]['id'].toString());
      loop2:
      for (int j = 0; j < mobileData.length; j++) {
        if (configTableName !=  mobileData[j]['id']) {
          InitDataBase.inst.insertData(InitDataBase.productDataTable, {
            InitDataBase.id : serverDbVersion[i]['id'].toString(),
            InitDataBase.title : serverDbVersion[i]['title'].toString(),
            InitDataBase.image : serverDbVersion[i]['image'].toString(),
            InitDataBase.rate : serverDbVersion[i]['rating']['rate'].toString()
          });
        }else{
          for(int i=0; i<serverDbVersion.length; i++) {
            InitDataBase.inst.updateTask(serverDbVersion[i], dbInstance);
          }
        }
      }
    }

  }

}
