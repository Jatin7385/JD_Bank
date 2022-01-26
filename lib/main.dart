import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:velocity_x/velocity_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bank App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var httpClient;
  final myAddress = "0x78bA639f3BFbab0f442c3A6d3ce1Bbb78820a5a7";
  bool data = false;
  var ethClient;
  var myData;
  TextEditingController myAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    var url = "https://rinkeby.infura.io/v3/bf523ba2eeb245748fedc0a9c499749c";
    ethClient = Web3Client(url, httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");

    //Deployed Contract Address. Can be copied from Remix ide
    String contractAddress = "0x65c4d257CBcc1509eFF582d0fA674Bb0b86b6557";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "Bank"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    //For write operations, we need the private key as well
    //But for testing purposes, a random private key works

    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "36c2b151a0b8256b3acb8c803e078c2ff6d9098e00fb6780bc88623ef8d93217");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        chainId: 4);
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);

    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> deposit(String targetAddress) async {
    // print(myAmount.text);
    var Amount = BigInt.parse(myAmount.text);
    print(Amount);

    var response = await submit("deposit", [Amount]);

    print("Deposited");
    return response;
  }

  Future<String> withdraw(String targetAddress) async {
    // print(myAmount.text);
    var Amount = BigInt.parse(myAmount.text);
    print(Amount);

    var response = await submit("withdraw", [Amount]);

    print("Withdrawn");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .blue600
            .size(context.screenWidth, context.percentHeight * 30)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "JD BANK".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 6).heightBox,
          VxBox(
                  child: VStack([
            "Balance".text.gray700.xl2.semiBold.makeCentered(),
            10.heightBox,
            data
                ? "\$$myData".text.bold.xl4.makeCentered().shimmer()
                : CircularProgressIndicator().centered()
          ]))
              .p32
              .white
              .size(context.screenWidth, context.percentHeight * 25)
              .rounded
              .shadowXl
              .make(),
          30.heightBox,
          Container(
            margin: EdgeInsets.all(50.0),
            child: TextFormField(
              controller: myAmount,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter the amount',
              ),
            ).centered(),
          ),
          HStack(
            [
              TextButton.icon(
                      icon: Icon(Icons.refresh_outlined, color: Colors.white),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                      onPressed: () => getBalance(myAddress),
                      label: Text('Refresh'))
                  .h(50),
              TextButton.icon(
                      icon: Icon(
                        Icons.call_made_outlined,
                        color: Colors.white,
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                      onPressed: () => withdraw(myAddress),
                      label: Text('Withdraw'))
                  .h(50),
              TextButton.icon(
                      icon: Icon(Icons.call_received_outlined,
                          color: Colors.white),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                      onPressed: () => deposit(myAddress),
                      label: Text('Deposit'))
                  .h(50),
            ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          )
        ]),
      ]),
    );
  }
}
