package tfg.avellaneda.ira.service;

import java.util.List;
import java.util.Date;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.Comparator;
import java.util.Map;
import java.util.Comparator;
import java.util.stream.Stream;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;

import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.repositories.CriticaRepository;
import tfg.avellaneda.ira.model.ModeloPeliculaMedia;

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
 * 
 * @author Adrián
 *         Añadido método para el listado de las últimas criticas (se permite
 *         elegir la cantidad por parámetro)
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

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    @Autowired
    ObjectMapper mapper;

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

            critica.setFechaCreacion(new Date());

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

    /**
     * Obtiene las críticas más recientes.
     * 
     * @param cantidad Cantidad de criticas que se desea recibir
     * @return Lista de ModeloCritica.
     * @throws RuntimeException si la operación falla.
     */
    public List<ModeloCritica> getCriticasRecientes(int cantidad) {
        try {
            // Llama al método del repositorio con un límite dado
            return repo.getRecientes(cantidad)
                    .get()
                    .toObjects(ModeloCritica.class);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener las críticas recientes: {}", e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener las críticas recientes: {}", e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        }
    }

    /**
     * Recupera las críticas más recientes, asegurando que solo haya una crítica por
     * película
     * (la más reciente para esa película).
     * * @param limite Cantidad máxima de críticas distintas a devolver.
     * 
     * @return Lista de ModeloCritica, una por película, ordenadas por la fecha de
     *         creación.
     */
    public List<ModeloCritica> getCriticasRecientesDistintaPelicula(int limite) {
        List<ModeloCritica> todasCriticas = getAll();

        if (todasCriticas == null || todasCriticas.isEmpty()) {
            return List.of();
        }

        // Agrupa por peliculaID y encuentra la crítica con la fechaCreacion más
        // reciente
        List<ModeloCritica> criticasUnicas = todasCriticas.stream()
                .collect(Collectors.groupingBy(
                        ModeloCritica::getPeliculaID,
                        Collectors.maxBy(Comparator.comparing(ModeloCritica::getFechaCreacion,
                                Comparator.nullsLast(Comparator.naturalOrder())))))
                .values().stream()
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());

        criticasUnicas.sort(Comparator.comparing(ModeloCritica::getFechaCreacion,
                Comparator.nullsLast(Comparator.naturalOrder())).reversed());

        if (limite > 0) {
            return criticasUnicas.stream().limit(limite).collect(Collectors.toList());
        }

        return criticasUnicas;
    }

    /**
     * Calcula la puntuación media de todas las críticas por película, las ordena de
     * mayor a menor
     * y limita la cantidad de resultados devueltos.
     * * @param limite Cantidad máxima de resultados a devolver (si es 0 o negativo,
     * devuelve todos)
     * 
     * @return Lista de ModeloPeliculaMedia, ordenadas por la puntuación media de
     *         forma descendente.
     */
    public List<ModeloPeliculaMedia> getPuntuacionesMediasOrdenadas(int limite) {
        List<ModeloCritica> todasCriticas = getAll();

        if (todasCriticas == null || todasCriticas.isEmpty()) {
            return List.of();
        }

        // Agrupar por peliculaID y calcular la puntuación media
        Map<Integer, Double> mediasPorPelicula = todasCriticas.stream()
                .collect(Collectors.groupingBy(
                        ModeloCritica::getPeliculaID,
                        Collectors.averagingDouble(ModeloCritica::getPuntuacion)));

        // Convertir el Map a una lista de ModeloPeliculaMedia, ordenar y aplicar el
        // límite
        Stream<ModeloPeliculaMedia> streamResultados = mediasPorPelicula.entrySet().stream()
                .map(entry -> ModeloPeliculaMedia.of(entry.getKey(), entry.getValue()))
                // Ordenar la lista por puntuacion media de mayor a menor
                .sorted(Comparator.comparingDouble(ModeloPeliculaMedia::getPuntuacionMedia).reversed());

        // Aplicar el límite si es positivo
        if (limite > 0) {
            streamResultados = streamResultados.limit(limite);
        }

        return streamResultados.collect(Collectors.toList());
    }

}
