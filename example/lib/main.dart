import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spear_menu/spear_menu.dart';
import 'CustomData.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spear Menu Demo',
      home: MyHomePage(title: 'Spear Menu Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpearMenu menu;
  GlobalKey btnKey = GlobalKey();
  GlobalKey btnKey1 = GlobalKey();

  List<CustomData> menuList = new List<CustomData>();

  @override
  Widget build(BuildContext context) {
    SpearMenu.context = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 70,
                  child: MaterialButton(
                    height: 10.0,
                    key: btnKey,
                    onPressed: () {
                      menuData(btnKey);
                    },
                    child: Icon(
                      Icons.filter_center_focus,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  "Filter",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    "Click Left (or) Right Button",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                Text(
                  "Filter",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(
                  width: 70,
                  child: MaterialButton(
                    height: 10.0,
                    key: btnKey1,
                    onPressed: () {
                      menuData(btnKey1);
                    },
                    child: Icon(
                      Icons.filter_center_focus,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _myListView(context))
        ],
      ),
    );
  }

  void menuData(GlobalKey btnKey) {
    if (menuList.isEmpty) {
      menuList.clear();
      menuList.add(CustomData('Copy', false));
      menuList.add(CustomData('Power', false));
      menuList.add(CustomData('Setting', true));
      menuList.add(CustomData('test_4', false));
      menuList.add(CustomData('test_5', false));
      menuList.add(CustomData('test_6', false));
      menuList.add(CustomData('test_7', false));
      menuList.add(CustomData('test_8', false));
      menuList.add(CustomData('test_9', false));
      menuList.add(CustomData('test_10', false));
      menuList.add(CustomData('test_11', false));
      menuList.add(CustomData('test_12', false));
      menuList.add(CustomData('test_13', false));
      menuList.add(CustomData('test_14', false));
      menuList.add(CustomData('test_15', false));
      menuList.add(CustomData('test_16', false));
    }

    List<MenuItemProvider> setData = new List<MenuItemProvider>();
    setData.clear();
    for (var io in menuList) {
      print("Result : " + io.name);
      setData.add(MenuItem(title: io.name, isActive: io.isShow));
    }

    SpearMenu menu = SpearMenu(
        //backgroundColor: Colors.teal,
        // lineColor: Colors.tealAccent,
        items: setData,
        onClickMenu: onClickMenu,
        stateChanged: stateChanged,
        onDismiss: onDismiss);
    menu.show(widgetKey: btnKey);
  }

  void onClickMenu(MenuItemProvider item) {
    menuList.map((element) {
      if (item.menuTitle == element.name) {
        element.isShow = true;
      } else {
        element.isShow = false;
      }
    }).toList();

    print('Click menu -> ${item.menuTitle}');
  }

  void stateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onDismiss() {
    print('Menu is dismiss');
  }


  //List Body Data
  Widget _myListView(BuildContext context) {

    // backing data
    final europeanCountries = ['Albania', 'Andorra', 'Armenia', 'Austria',
      'Azerbaijan', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria',
      'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland',
      'France', 'Georgia', 'Germany', 'Greece', 'Hungary', 'Iceland', 'Ireland',
      'Italy', 'Kazakhstan', 'Kosovo', 'Latvia', 'Liechtenstein', 'Lithuania',
      'Luxembourg', 'Macedonia', 'Malta', 'Moldova', 'Monaco', 'Montenegro',
      'Netherlands', 'Norway', 'Poland', 'Portugal', 'Romania', 'Russia',
      'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden',
      'Switzerland', 'Turkey', 'Ukraine', 'United Kingdom', 'Vatican City'];

    return ListView.separated(
      itemCount: europeanCountries.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(europeanCountries[index]),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );

  }
}
