library universal_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;
import 'package:youtube_player_flutter_quill/youtube_player_flutter_quill.dart';
import 'package:webviewx/webviewx.dart';

import '../../widgets/responsive_widget.dart';
import 'shims/dart_ui.dart' as ui_instance;

class PlatformViewRegistryFix {
  void registerViewFactory(dynamic x, dynamic y) {
    if (kIsWeb) {
      ui_instance.platformViewRegistry.registerViewFactory(
        x,
        y,
      );
    }
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();

Widget defaultEmbedBuilderWeb(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    void Function(GlobalKey videoContainerKey)? onVideoInit,
    ) {
  switch (node.value.type) {
    case BlockEmbed.imageType:
    // TODO: handle imageUrl of base64
      final imageUrl = node.value.data;
      final size = MediaQuery.of(context).size;
      UniversalUI().platformViewRegistry.registerViewFactory(
          imageUrl, (viewId) => html.ImageElement()..src = imageUrl);
      return Padding(
        padding: EdgeInsets.only(
          right: ResponsiveWidget.isMediumScreen(context)
              ? size.width * 0.5
              : (ResponsiveWidget.isLargeScreen(context))
              ? size.width * 0.75
              : size.width * 0.2,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: HtmlElementView(
            viewType: imageUrl,
          ),
        ),
      );
    case BlockEmbed.videoType:
    // TODO: implement 'video' builder

      String? youtubeID = YoutubePlayer.convertUrlToId(node.value.data);
      String embedUrl;

      if (youtubeID != null) {
        embedUrl = "https://www.youtube.com/embed/${YoutubePlayer.convertUrlToId(node.value.data)}";
      } else {
        embedUrl = node.value.data;
      }

      // UniversalUI().platformViewRegistry.registerViewFactory(
      //     embedUrl,
      //         (int id) => html.IFrameElement()
      //       ..width = MediaQuery.of(context).size.width.toString()
      //       ..height = MediaQuery.of(context).size.height.toString()
      //       ..src = embedUrl
      //       ..style.border = 'none');

      return WebViewX(
          initialContent: '',
          initialSourceType: SourceType.html,
          onWebViewCreated: (controller) => controller.loadContent(
            embedUrl,
            SourceType.url,
          ), height: 500, width: MediaQuery.of(context).size.width,
      );
    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
            'embed builder of QuillEditor. You must pass your own builder function '
            'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}
