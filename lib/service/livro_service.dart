import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biblioteca_firebase/model/livro.dart';

class LivroService {
  static const _baseUrl =
      'https://biblioteca-55fd8-default-rtdb.firebaseio.com/';

  static const _prazo = Duration(seconds: 15);

  static const _headers = {
    'Content-Type': 'application-json; charset=UTF-8',
    'Accept': 'application/json',
  };

  Uri _uri([String? id]) {
    final caminho = id == null ? '/livros.json' : '/livros/$id.json';
    return Uri.parse('$_baseUrl$caminho');
  }

  void _verificar(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Firebase: HTTP ${response.statusCode}');
    }
  }

  Future<List<Livro>> listar() async {
    final resposta = await http.get(_uri(), headers: _headers).timeout(_prazo);
    _verificar(resposta);
    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (dados == null) return [];
    if (dados is! Map) {
      throw const FormatException('Esperado objeto por chaves');
    }

    final mapa = Map<String, dynamic>.from(dados);
    final livros = mapa.entries
        .map(
          (item) => Livro.fromJson(
            item.key,
            Map<String, dynamic>.from(item.value as Map),
          ),
        )
        .toList();

    livros.sort((a, b) => a.titulo.compareTo(b.titulo));

    return livros;
  }

  Future<String> criar(Livro livro) async {
    final response = await http
        .post(_uri(), headers: _headers, body: jsonEncode(livro.toJson()))
        .timeout(_prazo);
    _verificar(response);
    final dados = jsonDecode(utf8.decode(response.bodyBytes));
    return dados['name'];
  }

  Future<void> atualizar(String id, Livro livro) async {
    final response = await http
        .patch(_uri(id), headers: _headers, body: jsonEncode(livro.toJson()))
        .timeout(_prazo);
    _verificar(response);
  }

  Future<void> excluir(String id) async {
    final response = await http
        .delete(_uri(id), headers: _headers)
        .timeout(_prazo);
    _verificar(response);
  }
}
