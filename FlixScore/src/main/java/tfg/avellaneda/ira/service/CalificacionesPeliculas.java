package tfg.avellaneda.ira.service;

import tfg.avellaneda.ira.model.ModeloCritica;
import com.google.firebase.FirebaseApp;
import com.google.cloud.firestore.Firestore;
import com.google.api.core.ApiFutures;
import com.google.cloud.firestore.WriteResult;
import com.google.cloud.firestore.DocumentSnapshot;
import tfg.avellaneda.ira.interfaces.FirebaseCallback;
import com.google.firebase.cloud.FirestoreClient;


/**
 * Servicio para manejar la lógica de negocio de calificación de películas
 * y la persistencia en Firebase Firestore usando el Admin SDK.
 * @author Adrián
 */
public class CalificacionesPeliculas {
    
    private final Firestore db;
    
    private static final String COLECCION_CRITICAS = "criticas";

    /**
     * Constructor que inicializa las instancias de Firebase a través del Admin SDK.
     */
    public CalificacionesPeliculas() {
        // Obtenemos la instancia de la aplicación Firebase ya inicializada (Configuración externa)
        FirebaseApp app = FirebaseApp.getInstance(); 
        
        this.db = FirestoreClient.getFirestore(app);
    }
    
    
    /**
     * Método principal para registrar la puntuación y el comentario de una película.
     * @param usuarioUID ID del usuario que hace la critica.
     * @param peliculaID El ID de la película a puntuar.
     * @param puntuacion La puntuación dada (de 1 a 10).
     * @param comentario Los comentarios del usuario.
     * @param callback Interfaz para manejar el resultado de la operación (éxito/fracaso).
     */
    public void puntuarPelicula(String usuarioUID, int peliculaID, int puntuacion, String comentario, FirebaseCallback<Boolean> callback){

        // Validación (Usamos rango 0 a 10 por convención)
        if (puntuacion < 0 || puntuacion > 10) {
             String errorMsg = "La puntuación debe estar entre 0 y 10.";
             System.err.println(errorMsg);
             callback.onError(errorMsg);
             callback.onResult(false);
             return;
        }
        
        // Crear el objeto ModeloCritica
        ModeloCritica nuevaCritica = new ModeloCritica(usuarioUID, peliculaID, puntuacion, comentario);

        // Generar el ID del documento
        String documentId = usuarioUID + "_" + peliculaID;

        // Guardar/Actualizar la crítica en Firestore (USANDO ApiFutures para callbacks)
        ApiFutures.addCallback(
            db.collection(COLECCION_CRITICAS).document(documentId).set(nuevaCritica),
            new com.google.api.core.ApiFutureCallback<WriteResult>() {
                @Override
                public void onSuccess(WriteResult result) {
                    System.out.println("Crítica registrada/actualizada con éxito para película ID: " + peliculaID);
                    callback.onResult(true);
                }
                
                @Override
                public void onFailure(Throwable t) {
                    String errorMsg = "Error al registrar la crítica en Firebase: " + t.getMessage();
                    System.err.println(errorMsg);
                    callback.onError(errorMsg);
                    callback.onResult(false);
                }
            },
            Runnable::run
        );
    }
    
    /**
     * Método para obtener una crítica específica.
     * @param usuarioUID ID del usuario.
     * @param peliculaID ID de la película.
     * @param callback callback de retorno.
     */
    public void obtenerCriticaPorUsuarioYPelicula(String usuarioUID, int peliculaID, FirebaseCallback<ModeloCritica> callback) {
        String documentId = usuarioUID + "_" + peliculaID;

        // Utilizamos ApiFutures.addCallback para un manejo asíncrono más limpio
        ApiFutures.addCallback(
            db.collection(COLECCION_CRITICAS).document(documentId).get(),
            new com.google.api.core.ApiFutureCallback<DocumentSnapshot>() {
                @Override
                public void onSuccess(DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists()) {
                        // con toObject() mapeamos el documento con nuestro modelo
                        ModeloCritica critica = documentSnapshot.toObject(ModeloCritica.class);
                        callback.onResult(critica);
                    } else {
                        callback.onResult(null);
                    }
                }

                @Override
                public void onFailure(Throwable t) {
                    String errorMsg = "Error al obtener la crítica: " + t.getMessage();
                    callback.onError(errorMsg);
                    callback.onResult(null);
                }
            },
            Runnable::run
        );
    }
}