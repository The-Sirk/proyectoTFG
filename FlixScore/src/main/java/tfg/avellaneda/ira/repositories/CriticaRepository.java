package tfg.avellaneda.ira.repositories;
import com.google.firebase.cloud.FirestoreClient;
import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.service.UsuarioService;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

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

 
 @Repository
public class CriticaRepository {

    private Firestore db = FirestoreClient.getFirestore();


    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    public ApiFuture<DocumentReference> addCritica(ModeloCritica critica) {
        return db.collection("criticas").add(critica);
    }

    public ApiFuture<DocumentSnapshot> getCriticaById(String documentID) {
        return db.collection("criticas").document(documentID).get();
    }
    
    public ApiFuture<QuerySnapshot> getCriticaByUserId(String UserId) {
        logger.info("Desde Criticas Repositorio {}", UserId);
        return db.collection("criticas")
                .whereEqualTo("usuarioUID", UserId)
                .get();
    }

    public ApiFuture<QuerySnapshot> getCriticaByPeliculaId(int PeliculaId) {
        return db.collection("criticas")
                .whereEqualTo("peliculaID", PeliculaId)
                .get();
    }

    public ApiFuture<QuerySnapshot> getAll() {
        return db.collection("criticas").get();
    }
}