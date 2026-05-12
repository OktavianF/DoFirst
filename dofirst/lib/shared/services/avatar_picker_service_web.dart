import 'dart:html' as html;

Future<String?> pickAvatarDataUrlImpl() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  input.click();

  await input.onChange.first;
  if (input.files == null || input.files!.isEmpty) {
    return null;
  }

  final file = input.files!.first;
  final reader = html.FileReader();
  reader.readAsDataUrl(file);
  await reader.onLoadEnd.first;
  return reader.result as String?;
}
