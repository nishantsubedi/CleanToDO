import 'package:flutter/material.dart';
import 'package:clean_todo/sidebar/NewCategoryDialog.dart';
import 'package:clean_todo/beans/Category.dart';
import 'package:clean_todo/beans/CategoryGroup.dart';
import 'package:clean_todo/beans/UserData.dart';
import 'package:clean_todo/beans/CategoryData.dart';
import 'package:clean_todo/settings/SettingsManager.dart';
import 'package:clean_todo/data/DataCache.dart';
import 'package:clean_todo/lists/AboutView.dart';

class AppSidebar extends StatefulWidget {

  AppSidebar(
      { Key key, this.categories, this.addCategory, this.filter, this.userData,
        this.cache, this.settings })
      : super(key: key);

  final UserData userData;

  final CategoryData categories;

  final DataCache cache;
  final SettingsManager settings;

  final ValueChanged<Category> addCategory;

  final ValueChanged<int> filter;


  @override
  _AppSidebarState createState() => new _AppSidebarState();

}

class _AppSidebarState extends State<AppSidebar> {

  ListTile getAsSystemListTile( context, Category categoryData ){

    return new ListTile(
        leading: new Icon( categoryData.icon == null ? Icons.list : categoryData.icon, color: Theme.of(context).primaryColor,  ),
        title: new SidebarText( textContent : categoryData.text ),
        onTap: () {
          this.widget.filter( categoryData.id );
        }
    );

  }

  ListTile getAsListTile( context, Category categoryData ){

    return new ListTile(
      leading: new Icon( categoryData.icon == null ? Icons.list : categoryData.icon, color: Theme.of(context).primaryColor,  ),
      title: new SidebarText( textContent : categoryData.text ),
      trailing: new Text( categoryData.count == null ? "0" : categoryData.count.toString() ),
      onTap: () {
        this.widget.filter( categoryData.id );
      }
    );

  }

  Widget getAsGroupPanel2( context, CategoryGroup categoryGroup ){
    return new Column(

        children: [
          new Divider(),
          new ListTile(
            leading: new Icon( categoryGroup.isExpanded ? Icons.folder_open : Icons.folder, color: Theme.of(context).primaryColor, ),
            title: new SidebarText( textContent: categoryGroup.text ),
            trailing: new Icon( categoryGroup.isExpanded ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor, ),
              onTap: () {
                this.setState( (){
                  categoryGroup.isExpanded = !categoryGroup.isExpanded;
                });
              }
          ),
          new Column(
            children: categoryGroup.isExpanded ?
                          this.widget.categories
                                     .getGroupMembers(categoryGroup)
                                     .map( (category){
                                        return new Padding(
                                            padding: new EdgeInsets.only( left: 20.0 ),
                                            child: getAsListTile( context, category )
                                        );
                                      }).toList()
                : [ ],
          )
        ]

    );
  }

  @override
  Widget build(BuildContext context) {

    return new Drawer(

        child: new ListView(

                padding: new EdgeInsets.only(top: 30.0),
                children: <Widget>[

                  new ListTile(
                      leading: new CircleAvatar(
                                      child: new Text( this.widget.userData.abbr, style: new TextStyle( color: Colors.white ), ),
                                      backgroundColor: Theme.of(context).primaryColor,
                                    ),
                      title: new SidebarText( textContent : this.widget.userData.userName ) ,
                      subtitle: new Text( this.widget.userData.email ),
                      onTap: () => Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (context) => new AboutView(
                              cache: widget.cache,
                              settings: widget.settings,
                            )
                        ),
                      ),
                  ),

                  new Divider(),

                  new Column(
                    children: this.widget.categories.system.map( (category){
                      return getAsSystemListTile(context, category);
                    }).toList(),
                  ),

                  new ListTile(
                    leading: new Icon( Icons.add, color: Theme.of(context).primaryColor, ),
                    title: new SidebarText( textContent : 'New List' ),
                    onTap: () =>  showDialog(
                      context: context,
                      builder: (_) => new NewCategoryDialog( addCategory: this.widget.addCategory ),
                    ),
                  ),

                  new Padding(
                      padding: new EdgeInsets.only(left:  10.0, right: 10.0),
                      child: new Column(

                        children: this.widget.categories.userGroups.map( (categoryGroup){
                          return getAsGroupPanel2(context, categoryGroup);

                        }).toList(),

                      ),
                  ),

                ],
        ),

    );
  }
}

class SidebarText extends StatelessWidget {

  SidebarText({this.textContent});

  final String textContent;

  @override
  Widget build(BuildContext context) {
    return new Text( 
      this.textContent,
      style: new TextStyle( fontSize: 18.0, fontStyle: FontStyle.normal, fontWeight: FontWeight.w300 ),
    );
  }

}