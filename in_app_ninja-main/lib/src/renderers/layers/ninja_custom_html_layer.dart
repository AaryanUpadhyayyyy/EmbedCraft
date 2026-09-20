import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ninja_layer_utils.dart';

class NinjaCustomHtmlLayer extends StatefulWidget {
  final Map<String, dynamic> layer;
  final Size? parentSize;
  final double scale;
  final Function(Map<String, dynamic> action)? onAction;

  const NinjaCustomHtmlLayer({
    Key? key,
    required this.layer,
    this.parentSize,
    this.scale = 1.0,
    this.onAction,
  }) : super(key: key);

  @override
  State<NinjaCustomHtmlLayer> createState() => _NinjaCustomHtmlLayerState();
}

class _NinjaCustomHtmlLayerState extends State<NinjaCustomHtmlLayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final content = widget.layer['content'] as Map<String, dynamic>? ?? {};
    
    // Data Binding Interpolation
    String htmlContent = content['html']?.toString() ?? '';
    final dataBinding = widget.layer['dataBinding'] as Map<String, dynamic>?;
    
    if (dataBinding != null) {
      // Very basic interpolation implementation, mimicking the dashboard's interpolateDataBinding
      // For a robust implementation, this should pull from a global state or passed-in data item
      // For now, we leave the placeholders or you can inject a static payload
    }

    final cssContent = content['css']?.toString() ?? '';
    final jsContent = content['javascript']?.toString() ?? '';
    final bridgeEventName = content['bridgeEventName']?.toString() ?? 'ninjaAction';

    final srcDoc = '''
      <!DOCTYPE html>
      <html>
      <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
              body { margin: 0; padding: 0; overflow: hidden; background: transparent; }
              $cssContent
          </style>
          <script>
              window.ninja = {
                  triggerAction: function(actionName, actionData) {
                      if (window.$bridgeEventName) {
                          window.$bridgeEventName.postMessage(JSON.stringify({
                              action: actionName,
                              data: actionData
                          }));
                      }
                  },
                  dismiss: function() { this.triggerAction('dismiss', {}); },
                  openUrl: function(url) { this.triggerAction('open_url', { url: url }); }
              };
          </script>
      </head>
      <body>
          $htmlContent
          <script>$jsContent</script>
      </body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        bridgeEventName,
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final Map<String, dynamic> data = jsonDecode(message.message);
            final String actionName = data['action'] ?? '';
            final actionPayload = data['data'] ?? {};
            
            if (actionName == 'dismiss' && widget.onAction != null) {
               widget.onAction!({'type': 'dismiss'});
            } else if (actionName == 'open_url' && widget.onAction != null) {
               widget.onAction!({'type': 'open_url', 'url': actionPayload['url']});
            } else if (widget.onAction != null) {
               // Custom action pass-through
               widget.onAction!({
                 'type': 'custom_html_action',
                 'name': actionName,
                 'payload': actionPayload
               });
            }
          } catch (e) {
            debugPrint('Error parsing $bridgeEventName message: $e');
          }
        },
      )
      ..loadHtmlString(srcDoc);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.layer['style'] as Map<String, dynamic>? ?? {};

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(NinjaLayerUtils.parseDouble(style['borderRadius']?['topLeft']) ?? 0),
        topRight: Radius.circular(NinjaLayerUtils.parseDouble(style['borderRadius']?['topRight']) ?? 0),
        bottomLeft: Radius.circular(NinjaLayerUtils.parseDouble(style['borderRadius']?['bottomLeft']) ?? 0),
        bottomRight: Radius.circular(NinjaLayerUtils.parseDouble(style['borderRadius']?['bottomRight']) ?? 0),
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}
