package tfg.avellaneda.ira.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.MovieSalida;
import tfg.avellaneda.ira.service.BuscarPeliculasEnTMDb; 
import java.util.List;

/**
 * Endpoints para búsqueda de películas por nombre o ID
 * @author Adrián
 */
@RestController
public class BuscaPelicula {

    private final BuscarPeliculasEnTMDb buscarPeliculasEnTMDb;

    public BuscaPelicula(BuscarPeliculasEnTMDb buscarPeliculasEnTMDb) {
        this.buscarPeliculasEnTMDb = buscarPeliculasEnTMDb;
    }
    
    /**
     * Endpoint de búsqueda de película por nombre.
     * @param nombre Nombre de la película a buscar
     * @return List de MovieSalida con todas las peliculas coincidentes
     */
    @GetMapping("/peliculasPorNombre")
    public Mono<List<MovieSalida>> getMoviesByName(@RequestParam String nombre) {
        return buscarPeliculasEnTMDb.buscarPeliculaPorNombre(nombre);
    }
    
    /**
     * Endpoint de búsqueda de película por ID
     * @param id ID de la película a buscar
     * @return List de MovieSalida con la pelicula buscada
     */
    @GetMapping("/peliculasPorId")
    public Mono<List<MovieSalida>> getMoviesByID(@RequestParam String id) {
        return buscarPeliculasEnTMDb.buscarPeliculaPorId(id);
    }
}