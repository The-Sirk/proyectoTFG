package tfg.avellaneda.ira.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.api.core.ApiFuture;
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

    /**
     * Inyectamos tanto el repositorio como el mapper para convertir objetos a JSON.
     * OJO! El mapper funciona con los getters y setters de las clases modelo.
     * En este caso Lombok los genera automáticamente.
     */
    @Autowired
    CriticaRepository repo;
    
    @Autowired
    ObjectMapper mapper;

    public String getCriticaById(String criticaId) {
        try {
            ModeloCritica critica = repo.getCriticaById(criticaId)
                    .get()
                    .toObject(ModeloCritica.class);
            return mapper.writeValueAsString(critica);

        } catch (Exception e) {
            System.out.println("Error al obtener la crítica: " + e.getMessage());
            return null;
        }
    }

    public String getCriticasByUserId(String userId) {
        try {
            List<ModeloCritica> criticas = repo.getCriticaByUserId(userId)
                    .get()
                    .toObjects(ModeloCritica.class);
            return mapper.writeValueAsString(criticas);

        } catch (Exception e) {
            System.out.println("Error al obtener las críticas del usuario: " + e.getMessage());
            return null;
        }
    }

    public String getCriticasByPeliculaId(String peliculaId) {
        try {
            List<ModeloCritica> criticas = repo.getCriticaByPeliculaId(peliculaId)
                    .get()
                    .toObjects(ModeloCritica.class);
            return mapper.writeValueAsString(criticas);

        } catch (Exception e) {
            System.out.println("Error al obtener las críticas de la película: " + e.getMessage());
            return null;
        }
    }
    public String addCritica(ModeloCritica critica) {
        try {
            ApiFuture<DocumentReference> futureDocRef = repo.addCritica(critica);
            DocumentReference docRef = futureDocRef.get();
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();
            if (document.exists()) {
                ModeloCritica creada = document.toObject(ModeloCritica.class);
                return mapper.writeValueAsString(creada);
            } else {
                return null;
            }
        } catch (Exception e) {
            System.out.println("Error al añadir la crítica: " + e.getMessage());
            return null;
        }

    }

    public String getAll() {
        try {
            List<ModeloCritica> criticas = repo.getAll()
                    .get()
                    .toObjects(ModeloCritica.class);
            return mapper.writeValueAsString(criticas);

        } catch (Exception e) {
            System.out.println("Error al obtener las críticas: " + e.getMessage());
            return null;
        }
    }

}
