package tfg.avellaneda.ira.interfaces;

/**
 * Interfaz para manejar resultados asíncronos de Firebase.
 * Se usa para Admin SDK.
 * @author Adrián
 */
public interface FirebaseCallback<T> {
    void onResult(T result);
    void onError(String error);
}
