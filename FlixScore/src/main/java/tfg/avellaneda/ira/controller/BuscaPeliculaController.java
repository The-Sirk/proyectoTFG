package tfg.avellaneda.ira.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.MovieSalida;
import tfg.avellaneda.ira.service.BuscarPeliculasEnTMDb;
import java.util.List;

/**
 * Endpoints para búsqueda de películas por nombre o ID
 * 
 * @author Adrián
 *         Traduzco los métodos, ya que toda la app se ha hecho en castellano
 */

@RestController
@Tag(name = "Búsqueda en TMDb", description = "Endpoints para buscar películas utilizando el servicio externo TMDb.")
public class BuscaPeliculaController {

    private final BuscarPeliculasEnTMDb buscarPeliculasEnTMDb;

    public BuscaPeliculaController(BuscarPeliculasEnTMDb buscarPeliculasEnTMDb) {
        this.buscarPeliculasEnTMDb = buscarPeliculasEnTMDb;
    }

    /**
     * Endpoint de búsqueda de película por nombre.
     * 
     * @param nombre Nombre de la película a buscar
     * @return List de MovieSalida con todas las peliculas coincidentes
     */
    @Operation(summary = "Busca películas por nombre", description = "Realiza una búsqueda de películas por su título a través del servicio TMDb. Devuelve una lista de coincidencias.", responses = {
            @ApiResponse(responseCode = "200", description = "Búsqueda exitosa. Devuelve la lista de películas encontradas.", content = @Content(schema = @Schema(implementation = MovieSalida.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o fallo en la comunicación con TMDb.")
    })
    @GetMapping("/tmdb/v1/peliculasPorNombre")
    public Mono<List<MovieSalida>> getPeliculasPorNombre(
            @Parameter(description = "Nombre o parte del nombre de la película a buscar.") @RequestParam String nombre) {
        return buscarPeliculasEnTMDb.buscarPeliculaPorNombre(nombre);
    }

    /**
     * Endpoint de búsqueda de película por ID
     * 
     * @param id ID de la película a buscar
     * @return List de MovieSalida con la pelicula buscada
     */
    @Operation(summary = "Busca una película por ID", description = "Recupera los detalles de una película específica utilizando su ID en TMDb.", responses = {
            @ApiResponse(responseCode = "200", description = "Película encontrada exitosamente. Devuelve una lista con un único elemento (o vacío si no existe).", content = @Content(schema = @Schema(implementation = MovieSalida.class))),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o fallo en la comunicación con TMDb.")
    })
    @GetMapping("/tmdb/v1/peliculasPorId")
    public Mono<List<MovieSalida>> getMoviesByID(
            @Parameter(description = "ID único (TMDb ID) de la película a buscar.") @RequestParam String id) {
        return buscarPeliculasEnTMDb.buscarPeliculaPorId(id);
    }
}