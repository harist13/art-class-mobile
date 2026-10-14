import 'artwork.dart';
import 'json.dart';
import 'program.dart';
import 'testimonial.dart';

class Contact {
  Contact.fromJson(Json j)
      : whatsappDisplay = j['whatsapp_display'] as String?,
        whatsappUrl = j['whatsapp_url'] as String?,
        email = j['email'] as String?,
        instagram = j['instagram'] as String?,
        instagramUrl = j['instagram_url'] as String?,
        address = j['address'] as String?;

  final String? whatsappDisplay;
  final String? whatsappUrl;
  final String? email;
  final String? instagram;
  final String? instagramUrl;
  final String? address;
}

/// Isi halaman depan website (GET /site).
class Site {
  Site.fromJson(Json j)
      : name = j['name'] as String,
        tagline = j['tagline'] as String? ?? '',
        description = j['description'] as String? ?? '',
        contact = Contact.fromJson(jsonMap(j['contact'])),
        hours = jsonList(j['hours'], (h) => (day: h['day'] as String, time: h['time'] as String)),
        vision = jsonMap(j['about'])['vision'] as String?,
        mission = jsonStrings(jsonMap(j['about'])['mission']),
        stats = jsonList(jsonMap(j['about'])['stats'], (s) => (value: '${s['value']}', label: s['label'] as String)),
        testimonials = jsonList(j['testimonials'], Testimonial.fromJson),
        faq = jsonList(j['faq'], (f) => (q: f['q'] as String, a: f['a'] as String)),
        programs = jsonList(j['programs'], Program.fromJson),
        holidayClasses = jsonList(j['holiday_classes'], HolidayClass.fromJson),
        galleryPreview = jsonList(j['gallery_preview'], Artwork.fromJson);

  final String name;
  final String tagline;
  final String description;
  final Contact contact;
  final List<({String day, String time})> hours;
  final String? vision;
  final List<String> mission;
  final List<({String value, String label})> stats;
  final List<Testimonial> testimonials;
  final List<({String q, String a})> faq;
  final List<Program> programs;
  final List<HolidayClass> holidayClasses;
  final List<Artwork> galleryPreview;

  /// Nama tampilan sebuah slug kategori galeri.
  String categoryLabel(String? slug) {
    if (slug == null) return 'Karya murid';
    if (slug == 'kegiatan') return 'Kegiatan';
    for (final p in programs) {
      if (p.slug == slug) return p.name;
    }
    return slug[0].toUpperCase() + slug.substring(1);
  }
}
