package tfg.avellaneda.ira.repositories;

import org.springframework.stereotype.Repository;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;

import tfg.avellaneda.ira.model.ModeloUsuario;

/**
 * Repositorio REST para gestionar los usuarios.
 * 
 * @author Israel
 * 
 *         TODO: Añadir manejo de excepciones personalizado.
 */

@Repository
public class UsuarioRepository {

    private Firestore db = FirestoreClient.getFirestore();

    public ApiFuture<DocumentReference> addUsuario(ModeloUsuario usuario) {
        return db.collection("usuarios").add(usuario);
    }

    /*
     * Establece o sobrescribe un documento con un ID específico.
     * Si el ID existe, lo actualiza (reemplaza). Si no existe, lo crea.
     * Este método se usa cuando el documentId viene en la request.
     */
    public ApiFuture<WriteResult> setUsuario(String documentId, ModeloUsuario usuario) {
        return db.collection("usuarios").document(documentId).set(usuario);
    }

    public ApiFuture<DocumentSnapshot> getUsuarioById(String usuarioId) {
        return db.collection("usuarios").document(usuarioId).get();
    }

    public ApiFuture<QuerySnapshot> listarUsuarios() {
        return db.collection("usuarios").get();
    }

    public ApiFuture<QuerySnapshot> getUsuarioByNick(String nick) {
        return db.collection("usuarios")
                .whereEqualTo("nick", nick)
                .get();
    }

    public ApiFuture<WriteResult> updateUsuario(String usuarioId, ModeloUsuario usuario) {
        return db.collection("usuarios").document(usuarioId).set(usuario);
    }

    public ApiFuture<WriteResult> deleteUsuario(String usuarioId) {
        return db.collection("usuarios").document(usuarioId).delete();
    }

}
