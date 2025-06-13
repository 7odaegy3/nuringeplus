import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../3_home/data/models/procedure_model.dart';
import '../../data/repositories/procedures_list_repo.dart';
import 'procedures_list_state.dart';

class ProceduresListCubit extends Cubit<ProceduresListState> {
  final ProceduresListRepo _repo;

  ProceduresListCubit({ProceduresListRepo? repo})
    : _repo = repo ?? ProceduresListRepo(),
      super(ProceduresListInitial());

  Future<void> fetchProcedures(int categoryId) async {
    try {
      emit(ProceduresListLoading());

      // Get category name and procedures in parallel
      final results = await Future.wait([
        _repo.getCategoryNameById(categoryId),
        _repo.getProceduresByCategoryId(categoryId),
      ]);

      final categoryName = results[0] as String;
      final procedures = results[1] as List<ProcedureModel>;

      emit(
        ProceduresListSuccess(
          procedures: procedures,
          categoryName: categoryName,
          categoryId: categoryId,
        ),
      );
    } catch (e) {
      emit(ProceduresListFailure(e.toString()));
    }
  }
}
