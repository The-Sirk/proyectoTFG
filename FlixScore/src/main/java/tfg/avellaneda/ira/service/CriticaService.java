package tfg.avellaneda.ira.service;

import java.util.List;
import java.util.Date;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.Comparator;
import java.util.Map;
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
        // Nueva Validación de campos obligatorios:
        // Lanzar excepción si cualquiera de los campos obligatorios está
        // ausente/inválido.
        if (critica.getPeliculaID() == 0 ||
                (critica.getUsuarioUID() == null || critica.getUsuarioUID().trim().isEmpty()) ||
                critica.getPuntuacion() == 0 ||
                (critica.getComentario() == null || critica.getComentario().trim().isEmpty())) {

            // Creamos un mensaje de error más específico
            String mensajeError = "Los siguientes campos de la crítica son obligatorios y faltan: ";
            boolean tieneError = false;

            if (critica.getPeliculaID() == 0) {
                mensajeError += "ID de Película, ";
                tieneError = true;
            }
            if (critica.getUsuarioUID() == null || critica.getUsuarioUID().trim().isEmpty()) {
                mensajeError += "ID de Usuario, ";
                tieneError = true;
            }
            if (critica.getPuntuacion() == 0) {
                mensajeError += "Puntuación, ";
                tieneError = true;
            }
            if (critica.getComentario() == null || critica.getComentario().trim().isEmpty()) {
                mensajeError += "Comentario, ";
                tieneError = true;
            }

            // Si hay errores, lanza la excepción con el mensaje específico
            if (tieneError) {
                mensajeError = mensajeError.substring(0, mensajeError.length() - 2) + ".";
                logger.error("Intento de crear crítica con campos obligatorios vacíos: {}", mensajeError);
                throw new IllegalArgumentException(mensajeError);
            }
        }

        try {
            // Asigna la fecha de creación
            critica.setFechaCreacion(new Date());

            DocumentReference docRef = repo.addCritica(critica).get();

            // Recupera el documento creado para devolverlo
            DocumentSnapshot document = docRef.get().get();
            if (document.exists()) {
                ModeloCritica creada = document.toObject(ModeloCritica.class);
                logger.info("Critica creada correctamente con ID {}", creada.getDocumentID());
                return creada;
            } else {
                logger.error("Critica añadida sin recuperar", critica);
                throw new RuntimeException("Crítica creada pero no se pudo recuperar inmediatamente.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al añadir la crítica: {}", e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al añadir la crítica: {}", e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        } catch (Exception e) {
            throw (e instanceof RuntimeException) ? (RuntimeException) e
                    : new RuntimeException("Error inesperado al añadir la crítica.", e);
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
     * * @param cantidad Cantidad de criticas que se desea recibir. Debe ser > 0.
     * 
     * @return Lista de ModeloCritica.
     * @throws IllegalArgumentException si la cantidad es menor o igual a cero.
     * @throws RuntimeException         si la operación falla.
     */
    public List<ModeloCritica> getCriticasRecientes(int cantidad) {

        if (cantidad <= 0) {
            logger.error("Intento de obtener críticas recientes con cantidad inválida: {}", cantidad);
            throw new IllegalArgumentException("La cantidad de críticas a obtener debe ser mayor que cero.");
        }

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

    /**
     * Actualiza únicamente el comentario y/o la puntuación de una crítica.
     *
     * @param documentId ID de la crítica a actualizar.
     * @param comentario Nuevo texto del comentario (null si no se desea cambiar).
     * @param puntuacion Nueva puntuación (null si no se desea cambiar). Debe estar
     *                   entre 1 y 10.
     * @throws RuntimeException si la crítica no existe, si los datos son inválidos
     *                          o si hay un error de base de datos.
     */
    public void editarCritica(String documentId, String comentario, Integer puntuacion) {
        try {
            // Recuperar la crítica
            DocumentSnapshot doc = repo.getCriticaById(documentId).get();
            if (!doc.exists()) {
                logger.warn("Intento de editar crítica inexistente: {}", documentId);
                throw new RuntimeException("Crítica no encontrada con ID: " + documentId);
            }

            ModeloCritica critica = doc.toObject(ModeloCritica.class);

            // Validar y actualizar campos si se proporcionan
            if (comentario != null) {
                if (comentario.trim().isEmpty()) {
                    throw new RuntimeException("El comentario no puede estar vacío.");
                }
                critica.setComentario(comentario.trim());
            }

            if (puntuacion != null) {
                if (puntuacion < 1 || puntuacion > 10) {
                    throw new RuntimeException("La puntuación debe estar entre 1 y 10.");
                }
                critica.setPuntuacion(puntuacion);
            }

            // Persistir los cambios
            repo.updateCritica(documentId, critica).get();
            logger.info("Crítica {} actualizada: comentario={}, puntuacion={}", documentId, comentario, puntuacion);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            throw new RuntimeException("Error al actualizar la crítica en la base de datos.", e.getCause());
        }
    }
}
