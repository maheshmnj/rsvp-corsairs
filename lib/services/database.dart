import 'dart:io';

import 'package:rsvp/constants/const.dart';
import 'package:rsvp/services/auth/authentication.dart';
import 'package:rsvp/utils/logger.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  static final _supabase = AuthService.instance().supabaseClient;
  static const String _bucketName = 'event-covers';
  static const Logger _logger = Logger('DatabaseService');

  static Future<PostgrestResponse> findRowByColumnValue(String columnValue,
      {String columnName = Constants.ID_COLUMN,
      String tableName = Constants.EVENTS_TABLE_NAME}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq(columnName, columnValue)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findRowBy2ColumnValues(
    String column1Value,
    String column2Value, {
    String column1Name = Constants.ID_COLUMN,
    String column2Name = Constants.USER_EMAIL_COLUMN,
    String tableName = Constants.EVENTS_TABLE_NAME,
    bool ascending = false,
  }) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq(column1Name, column1Value)
        .eq(column2Name, column2Value)
        .order(Constants.CREATED_AT_COLUMN, ascending: ascending)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findRowsContaining(String columnValue,
      {String columnName = Constants.ID_COLUMN,
      String tableName = Constants.EVENTS_TABLE_NAME}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .ilike(columnName, "%$columnValue%")
        //TODO
        .execute();
    return response;
  }

  /// returns data from two table joined on the basis of a column
  /// associated via foreign key
  static Future<PostgrestResponse> findRowsByInnerJoinOnColumn({
    String table1 = Constants.EVENTS_TABLE_NAME,
    bool ascending = false,
    String table2 = Constants.USER_TABLE_NAME,
  }) async {
    try {
      final response = await _supabase
          .from(table1)
          .select('*, $table2!inner(*)')
          .order(Constants.CREATED_AT_COLUMN, ascending: ascending)
          .execute();
      return response;
    } on PostgrestException catch (_) {
      _logger.e('Error: $_');
      rethrow;
    }
  }

  /// returns data from two table joined on the basis of a column
  /// associated via foreign key
  static Future<PostgrestResponse> findRowsByInnerJoinOn1ColumnValue({
    String table1 = Constants.EVENTS_TABLE_NAME,
    bool ascending = false,
    String column = Constants.USER_ID_COLUMN,
    String value = '',
    String table2 = Constants.ATTENDEES_TABLE_NAME,
    String table3 = Constants.USER_TABLE_NAME,
  }) async {
    try {
      final response = await _supabase
          .from(table1)
          .select('*, $table2!inner(*),$table3!inner(*)')
          .eq(column, value)
          .order(Constants.CREATED_AT_COLUMN, ascending: ascending)
          .execute();
      return response;
    } on PostgrestException catch (_) {
      _logger.e('Error: $_');
      rethrow;
    }
  }

  static Future<PostgrestResponse> findMyEvents({
    String table1 = Constants.EVENTS_TABLE_NAME,
    bool ascending = false,
    String column = Constants.USER_ID_COLUMN,
    String value = '',
    String table2 = Constants.USER_TABLE_NAME,
    String table3 = Constants.ATTENDEES_TABLE_NAME,
  }) async {
    try {
      final response = await _supabase
          .from(table1)
          .select('*, $table2!inner(*)')
          .eq(column, value)
          .order(Constants.CREATED_AT_COLUMN, ascending: ascending)
          .execute();
      return response;
    } on PostgrestException catch (_) {
      _logger.e('Error: $_');
      rethrow;
    }
  }

  /// ```
  /// final response = await _supabase
  ///      .from('$table1')
  ///      .select('*, $table2!inner(*)')
  ///      .eq('$table2.$innerJoinColumn1', '$value1')
  ///      .eq('$table2.$innerJoinColumn2', '$value2')
  ///      .order('created_at', ascending: ascending)
  ///      .execute();
  ///  return response;
  /// ```
  static Future<PostgrestResponse> findRowsByInnerJoinOn2ColumnValue(
      String innerJoinColumn1,
      String value1,
      String innerJoinColumn2,
      String value2,
      {String table1 = Constants.EVENTS_TABLE_NAME,
      bool ascending = false,
      String table2 = Constants.USER_TABLE_NAME}) async {
    final response = await _supabase
        .from(table1)
        .select('*, $table2!inner(*)')
        .eq('$table2.$innerJoinColumn1', value1)
        .eq('$table2.$innerJoinColumn2', value2)
        // .order('created_at', ascending: ascending)
        .execute();
    return response;
  }

  // static Future<PostgrestResponse> exploreWords(
  //     // String innerJoinColumn1,
  //     //       String value1, String innerJoinColumn2, String value2,
  //     //       {String table1 = '$EDIT_HISTORY_TABLE',
  //     //       String table2 = '$USER_TABLE_NAME'}

  //     ) async {
  //   final response = await _supabase
  //       .from('$EVENTS_TABLE_NAME')
  //       .select()
  //       .select('*, $WORD_STATE_TABLE_NAME!inner(*)')
  //       // .eq('$table2.$innerJoinColumn1', '$value1')
  //       // .eq('state', 'known')
  //       // .order('created_at', ascending: ascending)
  //       .execute();
  //   return response;
  // }

  static Future<PostgrestResponse> findAll(
      {String tableName = Constants.EVENTS_TABLE_NAME}) async {
    final response = await _supabase.from(tableName).select().execute();
    return response;
  }

  // static Future<PostgrestResponse> findAllFromTwoTables(
  //     {String tableName = EVENTS_TABLE_NAME, required String userId}) async {
  //   final response = await findRowsByInnerJoinOnColumn(
  //     table1: EVENTS_TABLE_NAME,
  //     table2: USER_TABLE_NAME,
  //   );
  //   return response;
  // }

  static Future<PostgrestResponse> findLimitedWords(
      {String tableName = Constants.EVENTS_TABLE_NAME, int page = 0}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .range(page * 20, (page + 1) * 20);
    return response;
  }

  static Future<PostgrestResponse> findRecentlyUpdatedRow(
      String innerJoinColumn, String value,
      {String table1 = Constants.EVENTS_TABLE_NAME,
      bool ascending = false,
      String table2 = Constants.USER_TABLE_NAME}) async {
    final response = await _supabase
        .from(table1)
        .select('*, $table2!inner(*)')
        .order('created_at', ascending: ascending)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findSingleRowByColumnValue(
      String columnValue,
      {String columnName = Constants.ID_COLUMN,
      String tableName = Constants.EVENTS_TABLE_NAME}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq(columnName, columnValue)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findRowWithInnerjoinColumnValue(
    String columnValue, {
    String columnName = Constants.ID_COLUMN,
    String table1 = Constants.EVENTS_TABLE_NAME,
    String table2 = Constants.USER_TABLE_NAME,
    String table3 = Constants.USER_TABLE_NAME,
  }) async {
    try {
      final response = await _supabase
          .from(table1)
          .select('*, $table2!inner(*), $table3!inner(*)')
          .eq(columnName, columnValue)
          .execute();
      return response;
    } catch (_) {
      _logger.e('Error: $_');
      rethrow;
    }
  }

  static Future<PostgrestResponse> insertIntoTable(Map<String, dynamic> data,
      {String table = Constants.EVENTS_TABLE_NAME}) async {
    try {
      final response = await _supabase.from(table).insert(data).execute();
      return response;
    } on PostgrestException catch (_) {
      _logger.e('Error: ${_.details}');
      rethrow;
    }
  }

  /// Upsert will update the data if it exists, otherwise it will insert it.
  /// conflict column refers to the columns which should be unique across all the rows
  /// it is responsible to determine whether insert or update is called.
  static Future<PostgrestResponse> upsertIntoTable(Map<String, dynamic> data,
      {String table = Constants.EVENTS_TABLE_NAME,
      String conflictColumn = Constants.ID_COLUMN}) async {
    final response = await _supabase
        .from(table)
        .upsert(data, onConflict: 'id')
        .onError((error, stackTrace) {
      throw error!;
    });
    return response;
  }

  /// updates a row in the table
  ///
  static Future<PostgrestResponse> updateRow(
      {required String colValue,
      required Map<String, dynamic> data,
      String columnName = Constants.ID_COLUMN,
      String tableName = Constants.EVENTS_TABLE_NAME}) async {
    try {
      final response = await _supabase
          .from(tableName)
          .update(data)
          .eq(columnName, colValue)
          .execute();
      return response;
    } on PostgrestException catch (_) {
      _logger.e('Error: ${_.details}');
      rethrow;
    }
  }

  /// updates a value in a column
  /// update `ColumnName` to `columnValue` in `tableName where
  /// `searchColumn` = `searchValue`
  static Future<PostgrestResponse> updateColumn(
      {required String searchColumn,
      required String searchValue,
      required String columnName,
      required dynamic columnValue,
      required String tableName}) async {
    try {
      final response = await _supabase
          .from(tableName)
          .update({columnName: columnValue})
          .eq(searchColumn, searchValue)
          .execute();
      return response;
    } on PostgrestException catch (_) {
      _logger.e('error updating column: ${_.details}');
      rethrow;
    }
  }

  static Future<PostgrestResponse> upsertRow(Map<String, dynamic> data,
      {String tableName = Constants.EVENTS_TABLE_NAME}) async {
    final response = await _supabase.from(tableName).upsert(data);
    return response;
  }

  static Future<PostgrestResponse> deleteRow(String columnValue,
      {String columnName = Constants.ID_COLUMN,
      String tableName = Constants.EVENTS_TABLE_NAME}) async {
    final response =
        await _supabase.from(tableName).delete().eq(columnName, columnValue);
    return response;
  }

  static Future<PostgrestResponse> deleteRowBy2ColumnValue(
      String column1Value, String column2Value,
      {String column1Name = Constants.ID_COLUMN,
      String column2Name = Constants.ID_COLUMN,
      String tableName = Constants.EVENTS_TABLE_NAME}) async {
    // delete row based on two columns
    final response = await _supabase.from(tableName).delete().match(
        {column1Name: column1Value, column2Name: column2Value}).execute();
    return response;
  }

  static Future<Response> uploadImage(File imageFile,
      {String tableName = Constants.EVENTS_TABLE_NAME}) async {
    Response response = Response.init();
    try {
      // final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toUtc().toIso8601String()}.$fileExt';
      await _supabase.storage.from(_bucketName).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      final String imageUrlResponse =
          _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      response.message = 'image uploaded successfully';
      response.data = imageUrlResponse;
    } on StorageException catch (error) {
      response.didSucced = false;
      response.message = 'Failed to upload image';
      response.data = 'error: ${error.message}';
    } catch (error) {
      response.didSucced = false;
      response.message = 'Failed to upload image';
      response.data = error;
    }
    return response;
  }

  static Future<Response> deleteImage(List<String> path) async {
    try {
      final resp = await _supabase.storage.from(_bucketName).remove(path);
      return Response(
          didSucced: true, message: 'image deleted successfully', data: resp);
    } on StorageException catch (error) {
      _logger.e(error.message);
      return Response(
          didSucced: false,
          message: 'Failed to delete image',
          data: 'error: ${error.message}');
    }
  }
}

class Response {
  RequestState? state;
  bool didSucced;
  String message;
  int? status;
  Object? data;

  Response.init(
      {this.didSucced = true,
      this.state = RequestState.none,
      this.message = 'Success',
      this.status,
      this.data});

  Response(
      {required this.didSucced,
      required this.message,
      this.status,
      this.data,
      this.state});

  Response copyWith(
      {bool? didSucced,
      String? message,
      int? status,
      Object? data,
      RequestState? state}) {
    return Response(
        didSucced: didSucced ?? this.didSucced,
        message: message ?? this.message,
        status: status ?? this.status,
        data: data ?? this.data,
        state: state ?? this.state);
  }
}
