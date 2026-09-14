import 'package:biblioteca_firebase/model/livro.dart';
import 'package:biblioteca_firebase/service/livro_service.dart';
import 'package:flutter/material.dart';

class TelaLivros extends StatefulWidget {
  const TelaLivros({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TelaLivrosState();
  }
}

class TelaLivrosState extends State<TelaLivros> {
  final _service = LivroService();
  final _form = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();

  List<Livro> _livros = [];

  String? _idEdicao;
  bool _ocupado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      final livros = await _service.listar();
      setState(() {
        _livros = livros;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      setState(() {
        _ocupado = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;

    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      final livro = Livro(
        id: _idEdicao,
        titulo: _tituloController.text,
        autor: _autorController.text,
      );

      if (_idEdicao == null) {
        await _service.criar(livro);
      } else {
        await _service.atualizar(_idEdicao!, livro);
      }

      _limpar();
      await _carregar();
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      setState(() {
        _ocupado = false;
      });
    }
  }

  Future<void> _excluir(Livro livro) async {
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      await _service.excluir(livro.id!);
      await _carregar();
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      setState(() {
        _ocupado = false;
      });
    }
  }

  void _limpar() {
    _form.currentState?.reset();
    _tituloController.clear();
    _autorController.clear();
    setState(() {
      _idEdicao = null;
      _erro = null;
    });
  }

  String? _obrigatorio(String? texto) {
    if (texto == null || texto.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _ocupado,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_ocupado) const LinearProgressIndicator(),
              Text(_idEdicao == null ? 'Novo Livro' : 'Editar Livro'),
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(labelText: 'Titulo'),
                      validator: _obrigatorio,
                    ),
                    TextFormField(
                      controller: _autorController,
                      decoration: const InputDecoration(labelText: 'Autor'),
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: _ocupado ? null : _salvar,
                          child: const Text('Salvar'),
                        ),
                        TextButton(
                          onPressed: _ocupado ? null : _limpar,
                          child: const Text('Limpar / Cancelar'),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    OutlinedButton.icon(
                      onPressed: _ocupado ? null : _carregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Atualizar lista'),
                    ),
                    if (_erro != null)
                      Text(_erro!, style: const TextStyle(color: Colors.red)),
                    if (!_ocupado && _erro == null && _livros.isEmpty)
                      const Text('Nenhum livro cadastrado'),
                    for (final livro in _livros)
                      Card(
                        child: ListTile(
                          title: Text(livro.titulo),
                          subtitle: Text(livro.autor),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: _ocupado
                                    ? null
                                    : () {
                                        _form.currentState?.reset();
                                        _tituloController.text = livro.titulo;
                                        _autorController.text = livro.autor;
                                        setState(() {
                                          _idEdicao = livro.id;
                                        });
                                      },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                tooltip: 'Excluir',
                                onPressed: _ocupado
                                    ? null
                                    : () => _excluir(livro),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
