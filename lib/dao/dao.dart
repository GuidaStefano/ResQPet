abstract interface class Dao<T, IdType> {                                                                                         
  Future<T> create(T data);                                                                                                         
  Future<T?> findById(IdType id);                                                                                                 
  Future<T> update(T data);                                                                                                       
  Future<bool> deleteById(IdType id);                                                                                             
  Future<List<T>> findAll();                                                                                                      
  Stream<List<T>> findAllStream();                                                                                                
}   