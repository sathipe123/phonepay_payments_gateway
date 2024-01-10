import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonepePayment extends StatefulWidget {
  const PhonepePayment({super.key});

  @override
  State<PhonepePayment> createState() => _PhonepePaymentState();
}

class _PhonepePaymentState extends State<PhonepePayment> {
  String environment = "SANDBOX";
  String appId = "null";
  String merchantId = "PGTESTPAYUAT";
  bool enableLogging = true;
  String checkSum = "";
  String saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String saltIndex = "1";
  String callbackUrl =
      "https://webhook.site/c76ecbf8-9601-491a-96e7-08793aeb4829";
  String body = "";
  Object? result;
  String apiEndPoint = "/pg/v1/pay";
  bool isLoading = false;

  getCheckSum() {
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": "MT7850590068188104",
      "merchantUserId": "MUID123",
      "amount": 10000,
      "callbackUrl": callbackUrl,
      "mobileNumber": "9999999999",
      "paymentInstrument": {
        "type": "PAY_PAGE",
      }
    };

    String base64body = base64.encode(utf8.encode(json.encode(requestData)));
    checkSum =
        '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';
    return base64body;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phonepeinit();
    body = getCheckSum().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(51, 158, 68, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 86, 16, 161),
        title: const Text("PhonePe Payment Gateway"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                startPgTransaction();
              },
              child: SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Pay",
                      style: TextStyle(fontSize: 22),
                    )),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 170,
              width: MediaQuery.of(context).size.width,
              child: Card(
                color: Colors.purple.shade100,
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Result :-\n\n\n $result",
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void phonepeinit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void startPgTransaction() async {
    try {
      await PhonePePaymentSdk.startTransaction(body, callbackUrl, checkSum, "")
          .then((response) {
        setState(() {
          if (response != null) {
            String status = response['status'].toString();
            String error = response['error'].toString();
            if (status == 'SUCCESS') {
              result = "Flow Completed - status : SUCCESS";
            } else {
              result = "Flow Completed - Status: $status and Error : $error";
            }
          } else {
            result = "Flow Incomplete";
          }
        });
      });
    } catch (error) {
      result = {"error": error};
    }
  }

  void handleError(error) {
    setState(() {
      result = {"error": error};
    });
  }
}
