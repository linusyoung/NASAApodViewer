import 'dart:async';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/src/NASA_Api.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingDrawer extends StatefulWidget {
  // final BuildContext context;

  // SettingDrawer({this.context});

  @override
  _SettingDrawerState createState() => _SettingDrawerState();
}

class _SettingDrawerState extends State<SettingDrawer> {
  String settingApiKeyText = "Use your own NASA API key";
  String userApiKey;
  ApodDatabase db;

  @override
  Widget build(BuildContext context) {
    final db = ApodDatabase();
    return FutureBuilder(
      future: db.getUserApiKey(),
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return LinearProgressIndicator();
          default:
            userApiKey = snapshot.data;
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    // TODO: add image from unsplash
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Text(
                        "Settings",
                        style: Theme.of(context).primaryTextTheme.headline,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(settingApiKeyText),
                    subtitle: Text(userApiKey ?? ""),
                    leading: Icon(Icons.vpn_key),
                    onTap: () async {
                      await getUserApiKeyDialog(context);
                      Navigator.of(context).pop();
                    },
                  ),
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
