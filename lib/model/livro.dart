class Livro {
  final String? id;
  final String titulo;
  final String autor;

  const Livro({this.id, required this.titulo, required this.autor});

  factory Livro.fromJson(String id, Map<String, dynamic> json) {
    return Livro(
      id: id,
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'titulo': titulo, 'autor': autor};
  }
}
