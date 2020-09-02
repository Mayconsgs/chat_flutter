import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          !mine
              ? Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data["senderName"],
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
                  ),
                  data["imgUrl"] != null
                      ? Container(
                      padding: EdgeInsets.all(2.0),
                      width: 250,
                      child: Image.network(
                        data["imgUrl"],
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null){
                            return child;  /// Caso o carregamento tenha terminado, retorna a imagem
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes !=
                                  null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ))
                      : Text(
                    data["text"],
                    style: TextStyle(fontSize: 16),
                    textAlign: mine ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
          mine
              ? Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
