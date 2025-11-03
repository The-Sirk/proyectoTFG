package tfg.avellaneda.ira.service;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;

import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.repositories.CriticaRepository;

/**
 * TODO: Añadir manejo de excepciones personalizado.
 * TODO: Añadir respuestas personalizadas, no solo String o null en caso de error.
 * de momento nos vale así para ir avanzando y probar la app.
 */

/**
 * Servicio para gestionar las críticas de películas.
 * Proporciona métodos para crear, recuperar por usuario y por película.
 * 
 * @author Israel
 */

@Service
public class CriticaService {

    @Autowired
    CriticaRepository repo;
    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    public Optional<ModeloCritica> getCriticaById(String documentID) {
        try {
            DocumentSnapshot document = repo.getCriticaById(documentID).get();

            if (document.exists()) {
                return Optional.ofNullable(document.toObject(ModeloCritica.class));
            } else {
                return Optional.empty(); // Usuario no encontrado
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener la critica {}: {}", documentID, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener la critica {}: {}", documentID, e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        }
    }

    public List<ModeloCritica> getCriticasByUserId(String userId) {
        try {
            logger.info("Desde Service getCriticasByUserId {}", userId);
            return repo.getCriticaByUserId(userId)
            .get()
            .toObjects(ModeloCritica.class);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener las criticas por userId {}: {}", userId, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener las criticas por userId {}: {}", userId, e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        }
    }

    public List<ModeloCritica> getCriticasByPeliculaId(int peliculaId) {
        try {
            return repo.getCriticaByPeliculaId(peliculaId)
            .get()
            .toObjects(ModeloCritica.class);

        } catch (Exception e) {
            System.out.println("Error al obtener las críticas de la película: " + e.getMessage());
            return null;
        }
    }

    public ModeloCritica addCritica(ModeloCritica critica) {
        try {
            
            DocumentReference docRef = repo.addCritica(critica).get();
            
            DocumentSnapshot document = docRef.get().get();
            if (document.exists()) {
                ModeloCritica creada = document.toObject(ModeloCritica.class);
                logger.info("Critica creada correctamente con ID {}", creada.getDocumentID());
                return creada;
            } else {
                logger.error("Critica añadida sin recuperar", critica);
                throw new RuntimeException("Critica creada per sin recuperar");
            }
        } catch (Exception e) {
            System.out.println("Error al añadir la crítica: " + e.getMessage());
            return null;
        }

    }

    public List<ModeloCritica> getAll() {
        try {
            return repo.getAll()
            .get()
            .toObjects(ModeloCritica.class);

        } catch (Exception e) {
            System.out.println("Error al obtener las críticas: " + e.getMessage());
            return null;
        }
    }

}
