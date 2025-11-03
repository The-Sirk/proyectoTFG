package tfg.avellaneda.ira.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.model.ModeloPeliculaMedia;
import tfg.avellaneda.ira.service.CriticaService;
import tfg.avellaneda.ira.service.UsuarioService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Controlador REST para gestionar las críticas de películas.
 * Proporciona endpoints para crear, recuperar por usuario y por película.
 * 
 * @author Israel
 * 
 *         TODO: Añadir manejo de excepciones personalizado.
 */

@RestController
@RequestMapping("/api/v1/criticas/")
@Tag(name = "Críticas", description = "Gestión de críticas y puntuaciones de películas")
public class CriticaController {

    @Autowired
    CriticaService criticaService;

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    @Operation(summary = "Busca críticas por ID de TMDb, usuario, película, o devuelve todas", description = "Permite buscar una crítica específica por su ID, todas las críticas de un usuario o todas las de una película. Si no se especifica ningún parámetro, devuelve todas las críticas.", responses = {
            @ApiResponse(responseCode = "200", description = "Operación exitosa. Devuelve la lista de críticas o la crítica individual.", content = @Content(schema = @Schema(implementation = ModeloCritica.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor durante la comunicación con la base de datos.")
    })
    @GetMapping
    public Flux<ModeloCritica> getCriticas(
            @Parameter(description = "ID del documento de la crítica a buscar (excluyente con userId y peliculaId)") @RequestParam(required = false) String id,
            @Parameter(description = "UID del usuario cuyas críticas se quieren recuperar") @RequestParam(required = false) String userId,
            @Parameter(description = "ID de la película cuyas críticas se quieren recuperar") @RequestParam(required = false) String peliculaId) {

        if (id != null) {
            return Mono.fromCallable(() -> criticaService.getCriticaById(id))
                    .filter(java.util.Optional::isPresent)
                    .map(java.util.Optional::get)
                    .flux()
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener critica", e));
                    });
        } else if (userId != null) {
            logger.info("Desde Controller {}", userId);
            return Mono.fromCallable(() -> criticaService.getCriticasByUserId(userId))
                    .flatMapMany(Flux::fromIterable)
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener criticas de usuario", e));
                    });
        } else if (peliculaId != null) {
            return Mono.fromCallable(() -> criticaService.getCriticasByPeliculaId(Integer.parseInt(peliculaId)))
                    .flatMapMany(Flux::fromIterable)
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener criticas de pelicula", e));
                    });
        } else {
            return Mono.fromCallable(() -> criticaService.getAll())
                    .flatMapMany(Flux::fromIterable)
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener todos los usuarios", e));
                    });
        }
    }

    @Operation(summary = "Crea una nueva crítica", description = "Añade una nueva crítica a la base de datos. La fecha de creación es generada automáticamente por el sistema.", responses = {
            @ApiResponse(responseCode = "200", description = "Crítica creada y devuelta exitosamente.", content = @Content(schema = @Schema(implementation = ModeloCritica.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor al intentar guardar la crítica.")
    })
    @PostMapping
    public Mono<ModeloCritica> addCritica(@RequestBody ModeloCritica critica) {
        return Mono.fromCallable(() -> criticaService.addCritica(critica))
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al añadir usuario", e));
                });
    }

    /**
     * Endpoint para obtener las ultimas películas valoradas.
     * 
     * @return Flux de ModeloCritica, ordenado por fecha de creación (más reciente a
     *         mas antigua).
     */
    @Operation(summary = "Obtiene las críticas más recientes (pueden repetirse películas)", description = "Devuelve una lista de las últimas críticas creadas, ordenadas por fecha. Se puede limitar la cantidad de resultados.", responses = {
            @ApiResponse(responseCode = "200", description = "Lista de críticas recientes obtenida con éxito.", content = @Content(schema = @Schema(implementation = ModeloCritica.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
    })
    @GetMapping("/recientes")
    public Flux<ModeloCritica> getCriticasRecientes(
            @Parameter(description = "Cantidad máxima de críticas a devolver.") @RequestParam(required = true) int cantidad) {
        return Mono.fromCallable(() -> criticaService.getCriticasRecientes(cantidad))
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR,
                            "Error al obtener las " + cantidad + " críticas más recientes.", e));
                });
    }

    /**
     * Endpoint para obtener las críticas más recientes, sin repetir película.
     * * @param cantidad Cantidad máxima de críticas a devolver.
     * 
     * @return Flux de ModeloCritica, con una sola crítica (la más reciente) por
     *         cada película.
     */
    @Operation(summary = "Obtiene la crítica más reciente por cada película", description = "Devuelve una lista de críticas, donde solo aparece la crítica más reciente para cada película. La lista está ordenada por fecha.", responses = {
            @ApiResponse(responseCode = "200", description = "Lista de críticas recientes por película obtenida con éxito.", content = @Content(schema = @Schema(implementation = ModeloCritica.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
    })
    @GetMapping("/recientesYDistintas")
    public Flux<ModeloCritica> getCriticasRecientesDistintas(
            @Parameter(description = "Cantidad máxima de resultados (películas distintas) a devolver. Por defecto es 0 (devuelve todas).") @RequestParam(required = true) int cantidad) {

        return Mono.fromCallable(() -> criticaService.getCriticasRecientesDistintaPelicula(cantidad))
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR,
                            "Error al obtener las críticas recientes distintas por película.", e));
                });
    }

    /**
     * Endpoint para obtener las películas ordenadas por su puntuación media, con un
     * límite de cantidad.
     * * @param cantidad Cantidad de películas del ranking a devolver.
     * 
     * @return Flux de ModeloPeliculaMedia, ordenado por puntuación media
     *         descendente.
     */
    @Operation(summary = "Obtiene el ranking de películas por puntuación media", description = "Calcula la puntuación media de todas las críticas por película y devuelve el ranking ordenado de mayor a menor media. Se puede limitar la cantidad de resultados.", responses = {
            @ApiResponse(responseCode = "200", description = "Ranking obtenido con éxito.", content = @Content(schema = @Schema(implementation = ModeloPeliculaMedia.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor al calcular el ranking.")
    })
    @GetMapping("/ranking")
    public Flux<ModeloPeliculaMedia> getRankingPeliculas(
            @Parameter(description = "Cantidad máxima de películas del ranking a devolver.") @RequestParam(required = true) int cantidad) {

        return Mono.fromCallable(() -> criticaService.getPuntuacionesMediasOrdenadas(cantidad))
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR,
                            "Error al calcular y obtener el ranking de películas por puntuación media.", e));
                });
    }

}
