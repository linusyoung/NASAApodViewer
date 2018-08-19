import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:club.swimmingbeaver.apodviewerflutter/database/database.dart';
import 'package:club.swimmingbeaver.apodviewerflutter/model/NASA_Api.dart';
import 'package:club.swimmingbeaver.apodviewerflutter/model/unsplash_model.dart';
import 'package:club.swimmingbeaver.apodviewerflutter/src/data_util.dart';

class SettingDrawer extends StatefulWidget {
  @override
  _SettingDrawerState createState() => _SettingDrawerState();
}

class _SettingDrawerState extends State<SettingDrawer> {
  String settingApiKeyText = "Use your own NASA API key";
  String userApiKey;
  UnsplashPhoto unsplash;
  ApodDatabase db;

  @override
  Widget build(BuildContext context) {
    final db = ApodDatabase();

    return FutureBuilder(
      future: Future.wait([db.getUserApiKey(), getRandomUnsplash()])
          .then((response) {
        userApiKey = response[0];
        unsplash = response[1];
      }),
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return LinearProgressIndicator();
          default:
            var drawerHeaderContext = Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Settings",
                      style: Theme.of(context).primaryTextTheme.headline,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Photo by ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.0,
                            ),
                          ),
                          TextSpan(
                            text: '${unsplash.userName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.0,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunch(unsplash.userHtml)) {
                                  launch(unsplash.userHtml);
                                }
                              },
                          ),
                          TextSpan(
                            text: ' on ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.0,
                            ),
                          ),
                          TextSpan(
                            text: 'Unsplash',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.0,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunch('https://unsplash.com')) {
                                  launch('https://unsplash.com');
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            var drawerHeader = GestureDetector(
              onLongPress: () async {
                if (await canLaunch(unsplash.fullUrl)) {
                  launch(unsplash.fullUrl);
                }
              },
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  image: DecorationImage(
                    fit: BoxFit.none,
                    image: NetworkImage(unsplash.smallUrl),
                  ),
                ),
                child: drawerHeaderContext,
              ),
            );

            if (userApiKey != null) {
              settingApiKeyText = "Your API Key is in used.";
            }

            var apiSetting = ListTile(
              title: Text(settingApiKeyText),
              subtitle: Text(userApiKey ?? ""),
              leading: Icon(Icons.vpn_key),
              onTap: () async {
                await getUserApiKeyDialog(context);
                Navigator.of(context).pop();
              },
            );

            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  drawerHeader,
                  apiSetting,
                ],
              ),
              semanticLabel: "Settings",
            );
        }
      },
    );
  }

  Future<String> getUserApiKeyDialog(BuildContext context) {
    final db = ApodDatabase();
    var apiKeyInput = TextField(
      decoration: InputDecoration(
        hintText: "NASA API key",
      ),
      autofocus: true,
      maxLines: 1,
      onChanged: (String key) {
        userApiKey = key;
      },
    );
    var launchNasaSite = FlatButton(
      child: Row(
        children: <Widget>[
          Icon(Icons.launch),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text("Sign up on NASA"),
          ),
        ],
      ),
      onPressed: () async {
        if (await canLaunch(NASAApi.nasaApiKeyUrl)) {
          launch(NASAApi.nasaApiKeyUrl);
        }
        Navigator.of(context).pop();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    );
    List<Widget> dialogChildren = [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: apiKeyInput,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Text("Done"),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() async {
                await db.updateApiKey(userApiKey);
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          launchNasaSite,
        ],
      ),
    ];
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Your API key below:",
          ),
          children: dialogChildren,
        );
      },
    );
  }
}
