import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Asegurarse de que el provider tenga acceso al context
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
          )
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasNoData
              ? const Center(child: Text('No hay datos guardados'))
              : ListView.builder(
                  itemCount: state.list.length,
                  itemBuilder: (context, index) {
                    final user = state.list[index];
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading
            ? null
            : () => {
                  if (hasNoData)
                    {
                      ref.read(userProvider.notifier).fetchUsersFromApi(),
                    }
                  else
                    {
                      ref.read(userProvider.notifier).deleteData(),
                    }
                },
        child: Icon(hasNoData ? Icons.search : Icons.delete),
      ),
    );
  }
}
