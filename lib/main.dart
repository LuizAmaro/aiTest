import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TransacaoAdapter());
  await Hive.openBox<Transacao>('transacoes');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TransacoesScreen(),
    );
  }
}

@HiveType(typeId: 0)
class Transacao {
  @HiveField(0)
  late String data;
  @HiveField(1)
  late String tipo;
  @HiveField(2)
  late double valor;
  @HiveField(3)
  late String idCredor;
  @HiveField(4)
  late String idDevedor;

  Transacao({
    required this.data,
    required this.tipo,
    required this.valor,
    required this.idCredor,
    required this.idDevedor,
  });
}

class TransacaoAdapter extends TypeAdapter<Transacao> {
  @override
  final int typeId = 0;

  @override
  Transacao read(BinaryReader reader) {
    return Transacao(
      data: reader.read(),
      tipo: reader.read(),
      valor: reader.read(),
      idCredor: reader.read(),
      idDevedor: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Transacao obj) {
    writer.write(obj.data);
    writer.write(obj.tipo);
    writer.write(obj.valor);
    writer.write(obj.idCredor);
    writer.write(obj.idDevedor);
  }
}

class TransacoesScreen extends StatelessWidget {
  final transactionBox = Hive.box<List<String>>('transacoes');

   TransacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Transações'),
      ),
      body: ValueListenableBuilder(
        valueListenable: transactionBox.listenable(),
        builder: (context, Box<List<String>> box, _) {
          final transactions = box.get('transactions', defaultValue: <String>[]);
          return ListView.builder(
            itemCount: transactions?.length,
            itemBuilder: (context, index) {
              final transactionFields = transactions![index].split('|');
              return ListTile(
                title: Text('Data: ${transactionFields[0]}, Tipo: ${transactionFields[1]}, Valor: ${transactionFields[2]}'),
                subtitle: Text('Credor: ${transactionFields[3]}, Devedor: ${transactionFields[4]}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NovaTransacaoScreen(context: context),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NovaTransacaoScreen extends StatefulWidget {
  final BuildContext context;

  NovaTransacaoScreen({super.key, required this.context});

  @override
  _NovaTransacaoScreenState createState() => _NovaTransacaoScreenState();
}

class _NovaTransacaoScreenState extends State<NovaTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _tipoController = TextEditingController();
  final _valorController = TextEditingController();
  final _idCredorController = TextEditingController();
  final _idDevedorController = TextEditingController();
  final transactionBox = Hive.box<List<String>>('transacoes');

  void _salvarTransacao() {
    final novaTransacao = [
      _dataController.text,
      _tipoController.text,
      _valorController.text,
      _idCredorController.text,
      _idDevedorController.text,
    ].join('|');
    transactionBox.put('transactions', [...?transactionBox.get('transactions', defaultValue: <String>[]), novaTransacao]);
    Navigator.of(widget.context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Transação'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a data da transação';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _tipoController,
              decoration: const InputDecoration(labelText: 'Tipo de transação'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o tipo da transação';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o valor da transação';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _idCredorController,
              decoration: const InputDecoration(labelText: 'Credor'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o credor da transação';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _idDevedorController,
              decoration: const InputDecoration(labelText: 'Devedor'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o devedor da transação';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _salvarTransacao();
                }
              },
              child: const Text('Salvar Transação'),
            ),
          ],
        ),
      ),
    );
  }
}



