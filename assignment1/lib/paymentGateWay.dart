
import 'package:assignment1/constants/dataConstants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'constants/uiConstants.dart';
import 'dataBase/dbFile.dart';
class PaymentGateWay extends StatefulWidget {
  const PaymentGateWay({Key? key}) : super(key: key);

  @override
  _PaymentGateWayState createState() => _PaymentGateWayState();
}

class _PaymentGateWayState extends State<PaymentGateWay> {
  Razorpay _razorpay = Razorpay();
  var options;
  TextStyle appBarStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.black
  );
  TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      color: Colors.black
  );
  bool isDataLoaded = false;
  dynamic dataModel;
  List<String> itemCount = [];
  List<String> amount = [];
  @override
  void initState() {
    getData();

    super.initState();
  }
  getData() {
    InitDataBase.inst.queryAllData(InitDataBase.cartTable).then((value) {
      dataModel = value;
      setState(() {
        isDataLoaded = true;
        for(int i=0;i<dataModel.length;i++) {
          itemCount.add(dataModel[i]['count']);
          amount.add(dataModel[i]['amount']);
        }
      });
    });
  }
  Future payData(String amount) async {
    options = {
      'key': "rzp_test_FFS7hhaXY5uhTh", // Enter the Key ID generated from the Dashboard

      'amount': amount, //in the smallest currency sub-unit.
      'name': 'organization',

      'currency': "INR",
      'theme.color': "#F37254",
      'buttontext': "Pay with Razorpay",
      'description': 'RazorPay example',
      'prefill': {
        'contact': '8943988261',
        'email': 'arjunsuresh0003@gmail.com',
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print("errror occured here is ......................./:$e");
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("payment has succedded");
    _razorpay.clear();
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _razorpay.clear();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("payment has externalWallet33333333333333333333333333");
    _razorpay.clear();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DataConstants.payment,
          style: appBarStyle,),
        centerTitle: true,
        leading:  IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          return Container(
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
                    style:textStyle,
                    maxLines: 3,
                  ),),
                  SizedBox(width: 10,),
                  Container(
                    color: Colors.black12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        buildIconButtonRemove(context,itemCount[index],index),
                        Text(itemCount[index].toString()),
                        buildIconButtonIncrement(context,itemCount[index],index,dataModel),
                      ],
                    ),
                  ),
                  _payButton(dataModel,index)
                ],
              ),
            ),
          );
        });
  }
  IconButton buildIconButtonIncrement(BuildContext context,String itemValue,int index,dynamic dataModel) {
    return IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          setState(() {
            int item = int.parse(itemValue);
            itemCount[index] = (item + 1).toString();
            amount[index] = (double.parse(amount[index])/int.parse(itemCount[index])).toString();
          });

        }
    );
  }

  IconButton buildIconButtonRemove(BuildContext context,String itemValue,int index ) {
    return IconButton(
      icon: Icon(Icons.remove),
      onPressed: () {
        setState(() {
          int item = int.parse(itemValue);
          if(item>1) {
            itemCount[index] = (item - 1).toString() ;
            amount[index] = (double.parse(amount[index])/int.parse(itemCount[index])).toString();
          } else {
            InitDataBase.inst.deleteData(InitDataBase.cartTable,
                InitDataBase.id, InitDataBase.title,
                dataModel[index]['id'], dataModel[index]['title']).then((value) {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentGateWay()));
            });
          }
        });

      },
    );
  }

  Widget _payButton(dynamic dataModel,int index){
    return  Padding(
        padding: EdgeInsets.fromLTRB(40, 15, 40, 15),
        child: Material(
          borderRadius: BorderRadius.circular(40.0),
          color: Colors.red,
          child: MaterialButton(
            height: 40,
            onPressed: () {
              String amount1 = (double.parse(amount[index])*1000).toString();
              payData(amount1);

            },
            minWidth: 30,
            child: Text("PAY",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    letterSpacing: 1,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
          ),
        ));
  }

}
