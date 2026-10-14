import 'json.dart';

/// Foto karya murid (atau dokumentasi kegiatan) dari galeri publik.
class Artwork {
  Artwork.fromJson(Json j)
      : url = j['url'] as String,
        category = j['category'] as String?;

  final String url;

  /// Slug kategori (= slug program, atau 'kegiatan').
  final String? category;
}

class GalleryPage {
  GalleryPage.fromJson(Json j)
      : items = jsonList(j['data'], Artwork.fromJson),
        categories = jsonList(j['categories'], (c) => (slug: c['slug'] as String, label: c['label'] as String)),
        meta = PageMeta.fromJson(jsonMap(j['meta']));

  final List<Artwork> items;
  final List<({String slug, String label})> categories;
  final PageMeta meta;
}
