package tfg.avellaneda.ira.repositories;
import com.google.firebase.cloud.FirestoreClient;
import tfg.avellaneda.ira.model.ModeloCritica;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.api.core.ApiFuture;

/**
 * Repositorio para la gestión de críticas en Firestore.
 * Proporciona métodos para crear y recuperar criticas por usuario o película.
 * El repositorio es lo mas limpio posible, sin logica ninguna pues es el Service quien tiene que hacerlo.
 * 
 * TODO: Hay que consensuar donde y como crear la db de Firestore para poder inyectarla aquí y no tener que crear una nueva instancia cada vez.
 * TODO: Añadir manejo de excepciones personalizado.
 * @author Israel
 */

public class CriticaRepository {

    private Firestore db = FirestoreClient.getFirestore();

    public ApiFuture<DocumentReference> addCritica(ModeloCritica critica) {
        return db.collection("criticas").add(critica);
    }

    public ApiFuture<DocumentSnapshot> getCriticaById(String criticaId) {
        return db.collection("criticas").document(criticaId).get();
    }
    
    public ApiFuture<QuerySnapshot> getCriticaByUserId(String UserId) {
        return db.collection("criticas")
                .whereEqualTo("usuarioUID", UserId)
                .get();
    }

    public ApiFuture<QuerySnapshot> getCriticaByPeliculaId(String PeliculaId) {
        return db.collection("criticas")
                .whereEqualTo("peliculaID", PeliculaId)
                .get();
    }
}