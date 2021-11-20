
import 'package:assignment1/constants/dataConstants.dart';
import 'package:assignment1/constants/uiConstants.dart';
import 'package:assignment1/dataBase/dbFile.dart';
import 'package:assignment1/dataBase/dbSync.dart';
import 'package:assignment1/paymentGateWay.dart';
import 'package:assignment1/service/dataFetchService.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/size/gf_size.dart';
class ProductListView extends StatefulWidget {
  const ProductListView({Key? key}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  TextStyle appBarStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.black
  );
  TextStyle textStyle = TextStyle(
      fontFamily: 'Bahnschrift',
      fontSize: 15,
      color: Colors.black
  );
  bool isDataLoaded = false;
  dynamic dataModel;
  int itemCount = 1;
  bool added = false;
  getData(){
    InitDataBase.inst.queryAllData(InitDataBase.productDataTable).then((value) {
      if((value.length != 0) || (value.isNotEmpty) ){
        dataModel = value;
        setState(() {
          isDataLoaded = true;
          added = true;
        });
      }else {
        DataFetchRepository().dataRepository().then((value) {
          dataModel = value;
          setState(() {
            isDataLoaded = true;
          });
          DbSync().verifyAndUpdateLocalDb(value);
        });
      }
    });
  }
  @override
  void initState() {
    getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
        title: Text(DataConstants.appBarTitle,
          style: appBarStyle,),
        centerTitle: true,
      ),
      body: isDataLoaded ? _buildListView() : UiConstants().spinkit,
    );
  }
  Widget _buildListView(){
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 1, color: Colors.grey),
        itemCount: dataModel.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _showModalSheet(dataModel[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      child: CachedNetworkImage(
                          imageUrl: dataModel[index]['image'].toString(),
                          fit: BoxFit
                              .cover
                      ),
                    ),
                    SizedBox(width: 20,),
                    Flexible(child: Text(
                        dataModel[index]['title'].toString(),
                        style:textStyle
                    ),)
                  ],
                ),
              ),
            ),
          );
        });
  }
  void _showModalSheet(dynamic dataModel){
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (builder){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.transparent,
                      child: Image.network(dataModel['image'],
                        fit: BoxFit.fill,),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text(dataModel['title'],
                        style:textStyle ,
                        maxLines: 3,),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GFRating(
                        color: Colors.amber,
                        borderColor: Colors.black,
                        size: GFSize.SMALL,
                        value: added == true ? double.parse(dataModel['rate'].toString()) : double.parse(dataModel['rating']['rate'].toString()),
                        onChanged: (double rating) {  },
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: Container(
                            color: Colors.black12,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildIconButtonRemove(context,setModalState),
                                Text(itemCount.toString()),
                                buildIconButtonIncrement(context,setModalState),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(40, 15, 40, 15),
                            child: Material(
                              borderRadius: BorderRadius.circular(40.0),
                              color: Colors.red,
                              child: MaterialButton(
                                height: 40,
                                onPressed: () {
                                  InitDataBase.inst.queryData(InitDataBase.cartTable, InitDataBase.id, dataModel['id'].toString()).then((value) {
                                    if(value.isEmpty) {
                                      String amount = added == true ? ((double.parse(dataModel['amount'].toString()))*itemCount).toString() : ((double.parse(dataModel['price'].toString()))*itemCount).toString();
                                      InitDataBase.inst.insertData(
                                          InitDataBase.cartTable,
                                          {
                                            InitDataBase.id: dataModel['id']
                                                .toString(),
                                            InitDataBase.title: dataModel['title']
                                                .toString(),
                                            InitDataBase.image: dataModel['image']
                                                .toString(),
                                            InitDataBase.count: itemCount
                                                .toString(),
                                            InitDataBase.amount: amount.toString()
                                          }).then((value) {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) =>
                                                PaymentGateWay()));
                                      });
                                    }else{
                                      Fluttertoast.showToast(
                                          msg: DataConstants.toastText,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0);

                                    }
                                  });
                                },
                                minWidth: 150,
                                child: Text("ADD CART",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        letterSpacing: 1,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                            )),
                      ],
                    ),

                  ],
                );
              }
          );
        }
    );
  }
  IconButton buildIconButtonIncrement(BuildContext context, StateSetter setModalState) {
    return IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          setModalState(() {
            itemCount++;
          });

        }
    );
  }

  IconButton buildIconButtonRemove(BuildContext context, StateSetter setModalState) {
    return IconButton(
      icon: Icon(Icons.remove),
      onPressed: () {
        setModalState(() {
          if(itemCount >1) {
            itemCount--;
          }
        });

      },
    );
  }

}
