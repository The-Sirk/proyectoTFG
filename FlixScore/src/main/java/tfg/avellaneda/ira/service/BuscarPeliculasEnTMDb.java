package tfg.avellaneda.ira.service;

import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Flux;
import java.util.List;
import tfg.avellaneda.ira.model.MovieSalida;
import tfg.avellaneda.ira.model.TmdbResponse;
import tfg.avellaneda.ira.model.MovieEntrada; 

/**
 * Lógica de negocio para la búsqueda y procesamiento de películas de TMDb.
 * Depende de TmdbService para la conexión HTTP.
 * * @author Adrián
 */
@Service
public class BuscarPeliculasEnTMDb {

    private final TmdbService tmdbService;

    public BuscarPeliculasEnTMDb(TmdbService tmdbService) {
        this.tmdbService = tmdbService;
    }

    /**
     * Busca películas por nombre y las procesa (filtra + completa detalles).
     * @param nombrePelicula El nombre de la película a buscar.
     * @return Un Mono con la lista de MovieSalida.
     */
    public Mono<List<MovieSalida>> buscarPeliculaPorNombre(String nombrePelicula) {
        // Usa el método base de TmdbService para construir la URL y hacer la llamada
        Mono<TmdbResponse> responseMono = tmdbService.getBaseRequest()
                .uri(uriBuilder -> uriBuilder
                        .path("/search/movie")
                        .queryParam("api_key", tmdbService.getApiKey())
                        .queryParam("query", nombrePelicula)
                        .queryParam("language", "es-ES")
                        .build())
                .retrieve()
                .bodyToMono(TmdbResponse.class);

        return responseMono
                .flatMapMany(response -> Flux.fromIterable(response.getResults()))
                .filter(movie -> !movie.isAdult()) // Evitamos el cine Nopor (Lógica de negocio)
                // Limitar concurrencia a 5 para no saturar TMDb (Lógica de procesamiento)
                .flatMap(this::completarDetalles, 5)
                .collectList();
    }

    /**
     * Busca una película por ID.
     * El método devuelve solo una película (Mono<MovieSalida>),
     * pero la envuelve en una lista para mantener la firma original.
     * @param idPelicula El ID de la película a buscar.
     * @return Un Mono con la lista de MovieSalida (contendrá 0 o 1 elemento).
     */
    public Mono<List<MovieSalida>> buscarPeliculaPorId(String idPelicula) {
        
        Mono<MovieEntrada> movieMono = tmdbService.getBaseRequest()
                .uri(uriBuilder -> uriBuilder
                        .path("/movie/{id}")
                        .queryParam("api_key", tmdbService.getApiKey())
                        .queryParam("language", "es-ES")
                        .build(idPelicula))
                .retrieve()
                // Si la búsqueda por ID falla (ej. 404), devuelve un Mono vacío en lugar de un error.
                .onStatus(status -> status.is4xxClientError() || status.is5xxServerError(), 
                          clientResponse -> Mono.empty())
                .bodyToMono(MovieEntrada.class);
        
        // Enriquecemos la película encontrada y la devolvemos envuelta en una lista
        return movieMono
                .flatMap(this::completarDetalles)
                .map(List::of) // Envuelve la MovieSalida individual en una lista para coincidir con el controlador.
                .defaultIfEmpty(List.of()); // Devuelve una lista vacía si la película no se encontró (404)
    }

    // Lógica de enriquecimiento de datos
    private Mono<MovieSalida> completarDetalles(MovieEntrada movie) {
        // Llama al servicio base para la sub-petición
        return tmdbService.getBaseRequest()
                .uri(uriBuilder -> uriBuilder
                        .path("/movie/{id}")
                        .queryParam("api_key", tmdbService.getApiKey())
                        .queryParam("language", "en-US")
                        .build(movie.getId()))
                .retrieve()
                .bodyToMono(MovieEntrada.class)
                .map(enMovie -> {
                    // Lógica de mapeo de DTO
                    MovieSalida dto = new MovieSalida();
                    dto.setId(movie.getId());
                    dto.setTitle(movie.getTitle() != null && !movie.getTitle().isEmpty() ? movie.getTitle() : enMovie.getTitle());
                    dto.setOriginalTitle(enMovie.getOriginalTitle());
                    dto.setOverview(movie.getOverview() != null && !movie.getOverview().isEmpty() ? movie.getOverview() : enMovie.getOverview());
                    dto.setReleaseDate(enMovie.getReleaseDate());
                    dto.setPopularity(movie.getPopularity());
                    dto.setVoteAverage(movie.getVoteAverage());
                    dto.setVoteCount(movie.getVoteCount());
                    dto.setPosterPath(enMovie.getPosterPath());
                    dto.setBackdropPath(enMovie.getBackdropPath());
                    dto.setOriginalLanguage(enMovie.getOriginalLanguage());
                    dto.setGenreIds(movie.getGenreIds()); 
                    return dto;
                });
    }
}