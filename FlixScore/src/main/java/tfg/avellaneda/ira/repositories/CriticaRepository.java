package tfg.avellaneda.ira.repositories;

import com.google.firebase.cloud.FirestoreClient;
import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.service.UsuarioService;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.Query.Direction;
import com.google.cloud.firestore.QuerySnapshot;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import com.google.api.core.ApiFuture;

/**
 * Repositorio para la gestión de críticas en Firestore.
 * Proporciona métodos para crear y recuperar criticas por usuario o película.
 * El repositorio es lo mas limpio posible, sin logica ninguna pues es el
 * Service quien tiene que hacerlo.
 * 
 * TODO: Hay que consensuar donde y como crear la db de Firestore para poder
 * inyectarla aquí y no tener que crear una nueva instancia cada vez.
 * TODO: Añadir manejo de excepciones personalizado.
 * 
 * @author Israel
 * 
 * @author Adrián
 *         Se añade la capacidad de ordenar las criticas por fecha
 */

@Repository
public class CriticaRepository {

    private Firestore db = FirestoreClient.getFirestore();

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    /**
     * Persiste una nueva crítica en la colección "criticas".
     *
     * @param critica datos de la crítica a guardar
     * @return ApiFuture con la referencia al documento recién creado
     */
    public ApiFuture<DocumentReference> addCritica(ModeloCritica critica) {
        return db.collection("criticas").add(critica);
    }

    /**
     * Obtiene una crítica a partir de su documentId.
     *
     * @param documentID identificador único de la crítica
     * @return ApiFuture con el snapshot del documento solicitado
     */
    public ApiFuture<DocumentSnapshot> getCriticaById(String documentID) {
        return db.collection("criticas").document(documentID).get();
    }

    /**
     * Devuelve todas las críticas realizadas por un usuario concreto.
     *
     * @param UserId UID del usuario cuyas críticas se desean
     * @return ApiFuture con el conjunto de documentos que coinciden
     */
    public ApiFuture<QuerySnapshot> getCriticaByUserId(String UserId) {
        logger.info("Desde Criticas Repositorio {}", UserId);
        return db.collection("criticas")
                .whereEqualTo("usuarioUID", UserId)
                .get();
    }

    /**
     * Devuelve todas las críticas asociadas a una película determinada.
     *
     * @param PeliculaId ID de la película (TMDb) sobre la que se han escrito
     *                   críticas
     * @return ApiFuture con el conjunto de documentos que coinciden
     */
    public ApiFuture<QuerySnapshot> getCriticaByPeliculaId(int PeliculaId) {
        return db.collection("criticas")
                .whereEqualTo("peliculaID", PeliculaId)
                .get();
    }

    /**
     * Devuelve la totalidad de las críticas existentes en la base de datos.
     *
     * @return ApiFuture con el conjunto completo de documentos de la colección
     *         "criticas"
     */
    public ApiFuture<QuerySnapshot> getAll() {
        return db.collection("criticas").get();
    }

    /**
     * Recupera las ultimas críticas grabadas en la base de datos. Se selecciona la
     * cantidad en parámetro.
     * 
     * @param limite Cantidad de críticas que se desea recuperar.
     * @return ApiFuture<QuerySnapshot> que representa el resultado de la consulta
     *         asíncrona a Firestore.
     */
    public ApiFuture<QuerySnapshot> getRecientes(int limite) {
        return db.collection("criticas")
                // Ordena por el campo 'fechaCreacion' de forma descendente (más reciente
                // primero)
                .orderBy("fechaCreacion", Direction.DESCENDING)
                // Limita el número de documentos
                .limit(limite)
                .get();
    }

    /**
     * Actualiza una crítica.
     * 
     * @param documentID id del documento a sobrescribir
     * @param critica    objeto con los datos nuevos (incluido el mismo documentID)
     * @return ApiFuture<WriteResult> resultado de la escritura
     */
    public ApiFuture<com.google.cloud.firestore.WriteResult> updateCritica(String documentID, ModeloCritica critica) {
        return db.collection("criticas").document(documentID).set(critica);
    }
}