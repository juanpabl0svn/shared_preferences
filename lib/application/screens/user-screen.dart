import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/models/state-result.dart';
import 'package:myapp/infraestructure/providers/user.provider.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProvider);
    final bool hasNoData = state.list.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isLoading ? "Cargando..." : "Usuarios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => ref.read(userProvider.notifier).cleanAndGetFromCache(),
          ),
        ],
      ),
      body: _buildBody(state, hasNoData),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading
            ? null
            : () => hasNoData
                ? ref.read(userProvider.notifier).fetchUsersFromApi()
                : ref.read(userProvider.notifier).deleteData(),
        child: Icon(hasNoData ? Icons.search : Icons.delete),
      ),
    );
  }

  Widget _buildBody(StateResult state, bool hasNoData) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (hasNoData) {
      return const Center(child: Text('No hay datos guardados'));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        itemCount: state.list.length,
        itemBuilder: (context, index) {
          final user = state.list[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.name[0].toUpperCase()),
              ),
              title: Text(
                user.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(user.email),
            ),
          );
        },
      );
    }
  }
}
