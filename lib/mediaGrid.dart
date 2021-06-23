import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaGrid extends StatefulWidget {
  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  List<AssetEntity> _mediaList = [];
  bool initialized = false;
  String path = "";
  int selectedPic;
  int selectedPicList;
  Map<String, List<AssetEntity>> m = {};

  @override
  void initState() {
    _fetchNewMedia();



    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        initialized == false
            ? CircularProgressIndicator()
            : Expanded(
          child: ListView.builder(

            itemCount: m.length,
            itemBuilder: (c, index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        m.values
                            .elementAt(index)
                            .elementAt(0)
                            .createDateTime
                            .month ==
                            DateTime.now().month
                            ? 'Récent'.toUpperCase()
                            : DateFormat.MMMM()
                            .format(m.values
                            .elementAt(index)
                            .elementAt(0)
                            .createDateTime
                            .toLocal())
                            .toString()
                            .toUpperCase(),
                        //        style: AppTheme.formTitleBlackBoldTextStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      height: 285,
                      child: buildGalleryGrid(
                        indexList: index,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          height: 100,
          color: Color(0xff0060A2),
          padding: EdgeInsets.only(top: 20, left: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () {},
                  child: Text(
                    'annuler'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Multi',
                      height: 1.1,
                      letterSpacing: 0.77,
                    ),
                  )),
              IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () {}),
              TextButton(
                onPressed: () {
                //  if (path.length > 0) Get.to(PhotoPreview(path));
                },
                child: Text(
                  'confirmer'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Multi',
                    height: 1.1,
                    letterSpacing: 0.77,
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  _fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(type:RequestType.image);
      print(albums);

      List<AssetEntity> photos = await albums[0].getAssetListPaged(0, 1000);
        for (int i = 0; i < photos.length; i++) {
       print(photos[i].createDateTime.month.toString());
        if (m.keys != null) if (m.keys
            .contains(photos[i].createDateTime.month.toString()))
          m[photos[i].createDateTime.month.toString()]
              .add(photos[i]);
        else
          m.putIfAbsent(photos[i].createDateTime.month.toString(),
                  () => [photos[i]]);
        else
          m.putIfAbsent(photos[i].createDateTime.month.toString(),
                  () => [photos[i]]);

      }
      setState(() {
        initialized = true;
      });

    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      PhotoManager.openSetting();
    }
  }
  GridView buildGalleryGrid({int indexList}) {
    return GridView.builder(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // A grid view with 4 items per row
        crossAxisCount: 4,
      ),
      itemCount: m.values.elementAt(indexList).length,
      padding: EdgeInsets.all(5),
      itemBuilder: (_, index) {
        return FutureBuilder(
          future: m.values.elementAt(indexList)[index].thumbData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            final bytes = snapshot.data;
            // If we have no data, display a spinner
            if (bytes == null) return CircularProgressIndicator();
            // If there's data, display it as an image
            return InkWell(
              onTap: () {
                m.values.elementAt(indexList)[index].file.then((value) => path = value.path);
                setState(() {
                  selectedPic =index;
                  selectedPicList =indexList;
                });
              },
              child: Stack(
                children: [
                  Container(
                    height: 95,
                    width: 95,
                    padding: const EdgeInsets.all(5.0),
                    decoration: selectedPic != null
                        ? selectedPic == index && selectedPicList ==indexList
                        ? BoxDecoration(
                        border: Border.all(
                            color: Color(0xff1EC501), width: 3))
                        : null
                        : null,
                    child: Image.memory(bytes, fit: BoxFit.cover),
                  ),
                  if (selectedPic!= null)
                    if (index == selectedPic&& selectedPicList ==indexList)
                      Positioned(
                        right: 8,
                        top: 2,
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xff1EC501),
                        ),
                      )
                ],
              ),
            );
          },
        );
      },
    );

  }

}



